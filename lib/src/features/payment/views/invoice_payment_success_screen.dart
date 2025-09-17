import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../controllers/payment_controller.dart';
import '../models/invoice_model.dart';
import '../models/payment_transaction_model.dart';
import 'invoice_detail_screen.dart';

class InvoicePaymentSuccessScreen extends StatelessWidget {
  const InvoicePaymentSuccessScreen({
    super.key,
    required this.transaction,
    required this.invoice
  });

  final PaymentTransactionModel transaction;
  final InvoiceModel invoice;

  @override
  Widget build(BuildContext context) {
    final darkMode = THelperFunctions.isDarkMode(context);
    final controller = Get.find<PaymentController>();

    return Scaffold(
      backgroundColor: darkMode ? TColors.black : TColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Success Animation Container
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Success Title
              Text(
                'Payment Successful!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: darkMode ? Colors.white : Colors.black,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Success Subtitle
              Text(
                'Your invoice has been paid successfully',
                style: TextStyle(
                  fontSize: 16,
                  color: darkMode ? Colors.grey[400] : Colors.grey[600],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Transaction Details Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: darkMode ? Colors.grey[900] : Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: darkMode ? Colors.grey[800]! : Colors.grey[200]!,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: TColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Iconsax.receipt_1_bold,
                            color: TColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Payment Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: darkMode ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Transaction ID
                    _DetailRow(
                      label: 'Transaction ID',
                      value: transaction.transactionId.isNotEmpty
                          ? transaction.transactionId.substring(0, 16) + '...'
                          : 'N/A',
                      darkMode: darkMode,
                    ),

                    const SizedBox(height: 16),

                    // Invoice Number
                    _DetailRow(
                      label: 'Invoice',
                      value: '#${invoice.invoiceId.substring(0, 8).toUpperCase()}',
                      darkMode: darkMode,
                    ),

                    const SizedBox(height: 16),

                    // Amount
                    _DetailRow(
                      label: 'Amount Paid',
                      value: 'RM${transaction.amount.toStringAsFixed(2)}',
                      darkMode: darkMode,
                      isAmount: true,
                    ),

                    const SizedBox(height: 16),

                    // Payment Method
                    _DetailRow(
                      label: 'Payment Method',
                      value: _getPaymentMethodName(transaction.paymentMethod),
                      darkMode: darkMode,
                    ),

                    const SizedBox(height: 16),

                    // Date
                    _DetailRow(
                      label: 'Payment Date',
                      value: _formatDate(transaction.transactionDateTime),
                      darkMode: darkMode,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Invoice Summary Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: TColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: TColors.primary.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Iconsax.document_text_bold,
                          color: TColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Invoice Summary',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: darkMode ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Show first few items
                    ...invoice.items.take(3).map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: item.type == 'service'
                                  ? Colors.blue.withOpacity(0.1)
                                  : Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Icon(
                              item.type == 'service' ? Iconsax.setting_2_bold : Iconsax.box_bold,
                              size: 12,
                              color: item.type == 'service' ? Colors.blue : Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.description,
                              style: TextStyle(
                                fontSize: 14,
                                color: darkMode ? Colors.grey[300] : Colors.grey[700],
                              ),
                            ),
                          ),
                          Text(
                            'RM${item.itemTotal.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: TColors.primary,
                            ),
                          ),
                        ],
                      ),
                    )),

                    if (invoice.items.length > 3) ...[
                      const SizedBox(height: 8),
                      Text(
                        '... and ${invoice.items.length - 3} more items',
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: darkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Action Buttons
              Column(
                children: [
                  // View Invoice Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.to(() => InvoiceDetailScreen(invoiceId: invoice.invoiceId));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Iconsax.document_text_bold, size: 18),
                          const SizedBox(width: 8),
                          const Text(
                            'View Invoice',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Download Receipt Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () async {
                        await controller.exportInvoiceReceipt(transaction, invoice);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: TColors.primary,
                        side: const BorderSide(color: TColors.primary),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.download,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Download Receipt',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Done Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: TextButton(
                      onPressed: () {
                        // Navigate back to home or appointments list
                        Get.offAll(() => InvoiceDetailScreen(invoiceId: invoice.invoiceId));
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: darkMode ? Colors.grey[400] : Colors.grey[600],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  String _getPaymentMethodName(String method) {
    switch (method.toLowerCase()) {
      case 'stripe':
        return 'Stripe';
      case 'paypal':
        return 'PayPal';
      case 'razorpay':
        return 'RazorPay';
      default:
        return 'Card Payment';
    }
  }

  String _formatDate(DateTime dateTime) {
    if (dateTime.year == 0) {
      return DateTime.now().toString().split('.')[0];
    }
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool darkMode;
  final bool isAmount;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.darkMode,
    this.isAmount = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: darkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isAmount ? FontWeight.bold : FontWeight.w500,
            color: isAmount
                ? TColors.primary
                : (darkMode ? Colors.white : Colors.black),
          ),
        ),
      ],
    );
  }
}