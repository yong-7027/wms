import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../../common/loaders/loaders.dart';
import '../../features/payment/models/invoice_model.dart';
import '../../features/payment/models/payment_transaction_model.dart';
import '../constants/colors.dart';

class ReceiptData {
  final InvoiceModel invoice;
  final PaymentTransactionModel transaction;
  final String companyName;
  final String companyAddress;
  final String companyPhone;
  final String companyEmail;
  final String? logoPath;

  ReceiptData({
    required this.invoice,
    required this.transaction,
    this.companyName = 'Workshop Management System',
    this.companyAddress = 'Bukit Mertajam, Penang, Malaysia',
    this.companyPhone = '+60 12-345 6789',
    this.companyEmail = 'info@wms.com',
    this.logoPath,
  });
}

class ExportHelper {
  ExportHelper._();

  /// 简单的拒绝次数记录
  static final Map<Permission, int> _denialCount = {};

  /// Export receipt as PDF
  static Future<void> exportReceipt({
    required ReceiptData receiptData,
  }) async {
    try {
      // Request storage permission with proper dialog
      final hasPermission = await _requestStoragePermissionWithDialog();
      if (!hasPermission) {
        return; // User denied permission or dialog was cancelled
      }

      TLoaders.customToast(message: 'Generating receipt...');
      await _exportReceiptAsPDF(receiptData);
    } catch (e) {
      TLoaders.errorSnackBar(
        title: 'Export Failed',
        message: 'Failed to generate receipt: ${e.toString()}',
      );
    }
  }

  /// Request storage permission with user dialog
  static Future<bool> _requestStoragePermissionWithDialog() async {
    if (Platform.isIOS) {
      // iOS doesn't need explicit permission for app documents
      return true;
    }

    if (Platform.isAndroid) {
      // Get Android version
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      Permission targetPermission;

      // Android 13+ (API 33+) uses different permissions
      if (sdkInt >= 33) {
        targetPermission = Permission.photos;
      } else if (sdkInt >= 30) {
        targetPermission = Permission.manageExternalStorage;
      } else {
        targetPermission = Permission.storage;
      }

      // Check current permission status
      PermissionStatus status = await targetPermission.status;

      if (status.isGranted) {
        return true;
      }

      // Show explanation dialog first
      bool shouldRequest = await _showPermissionExplanationDialog();
      if (!shouldRequest) {
        return false;
      }

      // Request permission
      status = await targetPermission.request();

      if (status.isGranted) {
        return true;
      } else {
        final shouldOpenSettings = await _checkIfShouldOpenSettings(targetPermission);
        await _showPermissionDeniedDialog(shouldOpenSettings);
        return false;
      }
    }

    return false;
  }

  /// 检查是否需要引导用户去设置
  static Future<bool> _checkIfShouldOpenSettings(Permission permission) async {
    final status = await permission.status;
    if (status.isPermanentlyDenied) {
      return true;
    }
    return status.isDenied && await _hasBeenDeniedBefore(permission);
  }

  static Future<bool> _hasBeenDeniedBefore(Permission permission) async {
    final status = await permission.status;
    if (status.isDenied) {
      _denialCount[permission] = (_denialCount[permission] ?? 0) + 1;
      return _denialCount[permission]! > 1;
    }
    return false;
  }

  /// Show permission explanation dialog
  static Future<bool> _showPermissionExplanationDialog() async {
    return await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Storage Permission Required'),
        content: const Text(
          'This app needs storage permission to save the receipt to your device. '
              'The receipt will be saved to your Downloads folder and you can share it with other apps.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: TColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: const Text(
              'Grant Permission',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    ) ??
        false;
  }

  /// Show permission denied dialog
  static Future<void> _showPermissionDeniedDialog(bool shouldOpenSettings) async {
    await Get.dialog(
      AlertDialog(
        title: const Text('Permission Required'),
        content: Text(
          shouldOpenSettings
              ? 'Storage permission has been permanently denied. Please go to app settings to enable it manually.'
              : 'Storage permission is required to save receipts. Please try again and grant the permission.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
          if (shouldOpenSettings)
            ElevatedButton(
              onPressed: () {
                Get.back();
                Future.delayed(const Duration(milliseconds: 300), () {
                  openAppSettings();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: TColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: const Text(
                'Open Settings',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// Export receipt as PDF with beautiful design
  static Future<void> _exportReceiptAsPDF(ReceiptData receiptData) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header with company info
                _buildHeader(receiptData),
                pw.SizedBox(height: 30),

                // Receipt title and number
                _buildReceiptTitle(receiptData),
                pw.SizedBox(height: 30),

                // Invoice and payment info
                _buildTransactionInfo(receiptData),
                pw.SizedBox(height: 30),

                // Items table
                _buildItemsTable(receiptData),
                pw.SizedBox(height: 30),

                // Payment summary
                _buildPaymentSummary(receiptData),
                pw.SizedBox(height: 30),

                // Footer
                pw.Spacer(),
                _buildFooter(),
              ],
            );
          },
        ),
      );

      // Save PDF
      await _savePDF(pdf, receiptData);
    } catch (e) {
      throw Exception('PDF generation failed: $e');
    }
  }

  /// Build header section
  static pw.Widget _buildHeader(ReceiptData receiptData) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              receiptData.companyName,
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue800,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              receiptData.companyAddress,
              style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
            ),
            pw.Text(
              receiptData.companyPhone,
              style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
            ),
            pw.Text(
              receiptData.companyEmail,
              style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
            ),
          ],
        ),
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: PdfColors.blue50,
            borderRadius: pw.BorderRadius.circular(8),
            border: pw.Border.all(color: PdfColors.blue200),
          ),
          child: pw.Text(
            'RECEIPT',
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800,
            ),
          ),
        ),
      ],
    );
  }

  /// Build receipt title section
  static pw.Widget _buildReceiptTitle(ReceiptData receiptData) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Receipt #${receiptData.transaction.transactionId.substring(0, 12).toUpperCase()}',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Invoice #${receiptData.invoice.invoiceId.substring(0, 8).toUpperCase()}',
                style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
              ),
            ],
          ),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: pw.BoxDecoration(
              color: PdfColors.green,
              borderRadius: pw.BorderRadius.circular(20),
            ),
            child: pw.Text(
              'PAID',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build transaction info section
  static pw.Widget _buildTransactionInfo(ReceiptData receiptData) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Payment Information',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey800,
                ),
              ),
              pw.SizedBox(height: 8),
              _buildInfoRow('Payment Date:', _formatDate(receiptData.transaction.transactionDateTime)),
              _buildInfoRow('Payment Method:', _getPaymentMethodName(receiptData.transaction.paymentMethod)),
              _buildInfoRow('Transaction ID:', receiptData.transaction.transactionId.substring(0, 20) + '...'),
              _buildInfoRow('Status:', receiptData.transaction.status.toUpperCase()),
            ],
          ),
        ),
        pw.SizedBox(width: 40),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Invoice Information',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey800,
                ),
              ),
              pw.SizedBox(height: 8),
              _buildInfoRow('Issue Date:', _formatDate(receiptData.invoice.issuedAt)),
              _buildInfoRow('Due Date:', _formatDate(receiptData.invoice.dueAt)),
              _buildInfoRow('Invoice ID:', receiptData.invoice.invoiceId.substring(0, 20) + '...'),
              _buildInfoRow('Items Count:', '${receiptData.invoice.items.length} items'),
            ],
          ),
        ),
      ],
    );
  }

  /// Build info row
  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 100,
            child: pw.Text(
              label,
              style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey600),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.normal),
            ),
          ),
        ],
      ),
    );
  }

  /// Build items table
  static pw.Widget _buildItemsTable(ReceiptData receiptData) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Invoice Items',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey800,
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          columnWidths: {
            0: const pw.FlexColumnWidth(3),
            1: const pw.FlexColumnWidth(1),
            2: const pw.FlexColumnWidth(1.5),
            3: const pw.FlexColumnWidth(1.5),
          },
          children: [
            // Header row
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.blue50),
              children: [
                _buildTableCell('Description', isHeader: true),
                _buildTableCell('Qty', isHeader: true),
                _buildTableCell('Unit Price', isHeader: true),
                _buildTableCell('Total', isHeader: true),
              ],
            ),
            // Data rows
            ...receiptData.invoice.items.map(
                  (item) => pw.TableRow(
                children: [
                  _buildTableCell('${item.description}\n(${item.type.toUpperCase()})'),
                  _buildTableCell('${item.quantity}'),
                  _buildTableCell('RM${item.unitPrice.toStringAsFixed(2)}'),
                  _buildTableCell('RM${item.itemTotal.toStringAsFixed(2)}'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build table cell
  static pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 12 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? PdfColors.blue800 : PdfColors.grey800,
        ),
      ),
    );
  }

  /// Build payment summary
  static pw.Widget _buildPaymentSummary(ReceiptData receiptData) {
    return pw.Container(
      width: double.infinity,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(12),
            decoration: const pw.BoxDecoration(
              color: PdfColors.blue50,
              borderRadius: pw.BorderRadius.only(
                topLeft: pw.Radius.circular(8),
                topRight: pw.Radius.circular(8),
              ),
            ),
            child: pw.Text(
              'Payment Summary',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue800,
              ),
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(12),
            child: pw.Column(
              children: [
                _buildSummaryRow('Subtotal:', 'RM${receiptData.invoice.subtotal.toStringAsFixed(2)}'),
                _buildSummaryRow('Tax (${(receiptData.invoice.taxRate * 100).toStringAsFixed(0)}%):', 'RM${receiptData.invoice.taxAmount.toStringAsFixed(2)}'),
                pw.Divider(color: PdfColors.grey300),
                _buildSummaryRow('Total Amount:', 'RM${receiptData.invoice.totalAmount.toStringAsFixed(2)}', isTotal: true),
                pw.SizedBox(height: 8),
                _buildSummaryRow('Amount Paid:', 'RM${receiptData.transaction.amount.toStringAsFixed(2)}', isPaid: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build summary row
  static pw.Widget _buildSummaryRow(String label, String amount, {bool isTotal = false, bool isPaid = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: isTotal || isPaid ? 14 : 12,
              fontWeight: isTotal || isPaid ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: isPaid ? PdfColors.green : PdfColors.grey800,
            ),
          ),
          pw.Text(
            amount,
            style: pw.TextStyle(
              fontSize: isTotal || isPaid ? 14 : 12,
              fontWeight: isTotal || isPaid ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: isPaid ? PdfColors.green : (isTotal ? PdfColors.blue800 : PdfColors.grey800),
            ),
          ),
        ],
      ),
    );
  }

  /// Build footer
  static pw.Widget _buildFooter() {
    return pw.Column(
      children: [
        pw.Divider(color: PdfColors.grey300),
        pw.SizedBox(height: 8),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Thank you for your business!',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.normal,
                color: PdfColors.blue800,
              ),
            ),
            pw.Text(
              'Generated on: ${_formatDate(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
            ),
          ],
        ),
      ],
    );
  }

  /// Save PDF file
  static Future<void> _savePDF(pw.Document pdf, ReceiptData receiptData) async {
    Directory? directory;

    if (Platform.isAndroid) {
      try {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } catch (e) {
        directory = await getExternalStorageDirectory();
      }
    } else {
      directory = await getApplicationDocumentsDirectory();
    }

    if (directory == null) {
      throw Exception('Could not access storage directory');
    }

    final fileName = _generateFileName(receiptData);
    final file = File('${directory.path}/$fileName');

    await file.writeAsBytes(await pdf.save());

    TLoaders.successSnackBar(
      title: 'Receipt Downloaded',
      message: 'Receipt saved successfully!',
    );

    // Share file
    await Share.shareXFiles([XFile(file.path)], text: 'Payment Receipt');
  }

  /// Generate file name
  static String _generateFileName(ReceiptData receiptData) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final receiptId = receiptData.transaction.transactionId.substring(0, 8);
    return 'receipt_${receiptId}_$timestamp.pdf';
  }

  /// Format date
  static String _formatDate(DateTime date) {
    if (date.year == 0) return 'N/A';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// Get payment method name
  static String _getPaymentMethodName(String method) {
    switch (method.toLowerCase()) {
      case 'stripe':
        return 'Credit/Debit Card (Stripe)';
      case 'paypal':
        return 'PayPal';
      case 'razorpay':
        return 'RazorPay';
      default:
        return 'Card Payment';
    }
  }
}