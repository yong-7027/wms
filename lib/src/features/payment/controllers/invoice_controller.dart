import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../common/loaders/loaders.dart';
import '../models/invoice_model.dart';
import '../../../utils/constants/firebase_field_names.dart';

class InvoiceController extends GetxController {
  static InvoiceController get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Observable variables
  final RxBool isLoading = false.obs;
  final Rx<InvoiceModel> currentInvoice = InvoiceModel.empty().obs;
  final RxList<InvoiceModel> invoices = <InvoiceModel>[].obs;

  /// Load specific invoice details
  Future<void> loadInvoiceDetails(String invoiceId) async {
    try {
      isLoading.value = true;

      final doc = await _db
          .collection('invoices')
          .doc(invoiceId)
          .get();

      if (doc.exists) {
        currentInvoice.value = InvoiceModel.fromSnapshot(doc);
      } else {
        throw Exception('Invoice not found');
      }
    } catch (e) {
      print('Error loading invoice details: $e');
      Get.snackbar(
        'Error',
        'Failed to load invoice details: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Load all invoices for a specific user
  Future<void> loadUserInvoices(String userId) async {
    try {
      isLoading.value = true;

      final querySnapshot = await _db
          .collection('invoices')
          .where(FirebaseFieldNames.userId, isEqualTo: userId)
          .orderBy(FirebaseFieldNames.createdAt, descending: true)
          .get();

      invoices.value = querySnapshot.docs
          .map((doc) => InvoiceModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      print('Error loading user invoices: $e');
      Get.snackbar(
        'Error',
        'Failed to load invoices: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Load invoices for specific appointment
  Future<void> loadAppointmentInvoices(String appointmentId) async {
    try {
      isLoading.value = true;

      final querySnapshot = await _db
          .collection('invoices')
          .where(FirebaseFieldNames.appointmentId, isEqualTo: appointmentId)
          .orderBy(FirebaseFieldNames.createdAt, descending: true)
          .get();

      invoices.value = querySnapshot.docs
          .map((doc) => InvoiceModel.fromSnapshot(doc))
          .toList();

      if (invoices.isNotEmpty) {
        currentInvoice.value = invoices.first;
      }
    } catch (e) {
      print('Error loading appointment invoices: $e');
      Get.snackbar(
        'Error',
        'Failed to load invoice: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Update invoice status
  Future<void> updateInvoiceStatus(String invoiceId, String status) async {
    try {
      await _db
          .collection('invoices')
          .doc(invoiceId)
          .update({
        FirebaseFieldNames.status: status,
      });

      // Update local invoice if it's the current one
      if (currentInvoice.value.invoiceId == invoiceId) {
        currentInvoice.value = currentInvoice.value.copyWith(status: status);
      }

      // Update in the list too
      final index = invoices.indexWhere((invoice) => invoice.invoiceId == invoiceId);
      if (index != -1) {
        invoices[index] = invoices[index].copyWith(status: status);
      }

      Get.snackbar(
        'Success',
        'Invoice status updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
      );
    } catch (e) {
      print('Error updating invoice status: $e');
      Get.snackbar(
        'Error',
        'Failed to update invoice status: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    }
  }

  /// Mark invoice as paid and add PDF URL
  Future<void> markInvoiceAsPaid(String invoiceId, {String? pdfUrl}) async {
    try {
      final updateData = {
        FirebaseFieldNames.status: 'paid',
      };

      if (pdfUrl != null) {
        updateData[FirebaseFieldNames.pdfUrl] = pdfUrl;
      }

      await _db
          .collection('invoices')
          .doc(invoiceId)
          .update(updateData);

      // Update local invoice
      if (currentInvoice.value.invoiceId == invoiceId) {
        currentInvoice.value = currentInvoice.value.copyWith(
          status: 'paid',
          pdfUrl: pdfUrl,
        );
      }

      // Update in the list too
      final index = invoices.indexWhere((invoice) => invoice.invoiceId == invoiceId);
      if (index != -1) {
        invoices[index] = invoices[index].copyWith(
          status: 'paid',
          pdfUrl: pdfUrl,
        );
      }

      print('Invoice marked as paid successfully');
    } catch (e) {
      print('Error marking invoice as paid: $e');
      throw e;
    }
  }

  /// Download receipt
  Future<void> downloadReceipt(String invoiceId) async {
    try {
      final invoice = currentInvoice.value.invoiceId == invoiceId
          ? currentInvoice.value
          : invoices.firstWhere((inv) => inv.invoiceId == invoiceId);

      if (invoice.pdfUrl == null || invoice.pdfUrl!.isEmpty) {
        Get.snackbar(
          'Error',
          'Receipt not available for download',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange[100],
          colorText: Colors.orange[800],
        );
        return;
      }

      final Uri uri = Uri.parse(invoice.pdfUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        Get.snackbar(
          'Success',
          'Receipt download started',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[100],
          colorText: Colors.green[800],
        );
      } else {
        throw Exception('Could not launch download URL');
      }
    } catch (e) {
      print('Error downloading receipt: $e');
      Get.snackbar(
        'Error',
        'Failed to download receipt: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    }
  }

  /// Get invoice by ID
  Future<InvoiceModel?> getInvoiceById(String invoiceId) async {
    try {
      final doc = await _db
          .collection('invoices')
          .doc(invoiceId)
          .get();

      if (doc.exists) {
        return InvoiceModel.fromSnapshot(doc);
      }
      return null;
    } catch (e) {
      print('Error getting invoice by ID: $e');
      return null;
    }
  }

  /// Check if invoice exists
  Future<bool> invoiceExists(String invoiceId) async {
    try {
      final doc = await _db
          .collection('invoices')
          .doc(invoiceId)
          .get();
      return doc.exists;
    } catch (e) {
      print('Error checking if invoice exists: $e');
      return false;
    }
  }

  /// Get overdue invoices count for user
  Future<int> getOverdueInvoicesCount(String userId) async {
    try {
      final querySnapshot = await _db
          .collection('invoices')
          .where(FirebaseFieldNames.userId, isEqualTo: userId)
          .where(FirebaseFieldNames.status, isEqualTo: 'overdue')
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      print('Error getting overdue invoices count: $e');
      return 0;
    }
  }

  /// Get unpaid invoices total for user
  Future<double> getUnpaidInvoicesTotal(String userId) async {
    try {
      final querySnapshot = await _db
          .collection('invoices')
          .where(FirebaseFieldNames.userId, isEqualTo: userId)
          .where(FirebaseFieldNames.status, whereIn: ['unpaid', 'overdue'])
          .get();

      double total = 0.0;
      for (final doc in querySnapshot.docs) {
        final invoice = InvoiceModel.fromSnapshot(doc);
        total += invoice.totalAmount;
      }

      return total;
    } catch (e) {
      print('Error getting unpaid invoices total: $e');
      return 0.0;
    }
  }

  /// Reset controller state
  void resetController() {
    currentInvoice.value = InvoiceModel.empty();
    invoices.clear();
    isLoading.value = false;
  }

  @override
  void onClose() {
    resetController();
    super.onClose();
  }
}