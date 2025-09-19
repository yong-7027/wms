import 'package:get/get.dart';
import '../../../common/loaders/loaders.dart';
import '../../../data/repository/payment/invoice_repository.dart';
import '../../../data/repository/payment/payment_repository.dart';
import '../../../utils/helpers/export_helper.dart';
import '../models/invoice_model.dart';

class InvoiceController extends GetxController {
  static InvoiceController get instance => Get.find();

  final invoiceRepo = Get.put(InvoiceRepository());
  final paymentRepo = Get.put(PaymentRepository());

  // Observable variables
  final RxBool isLoading = false.obs;
  final Rx<InvoiceModel> currentInvoice = InvoiceModel.empty().obs;
  final RxList<InvoiceModel> invoices = <InvoiceModel>[].obs;

  /// Load specific invoice details
  Future<void> loadInvoiceDetails(String invoiceId) async {
    try {
      isLoading.value = true;

      final invoice = await invoiceRepo.getInvoiceById(invoiceId);
      if (invoice != null) {
        currentInvoice.value = invoice;
      } else {
        throw Exception('Invoice not found');
      }
    } catch (e) {
      print('Error loading invoice details: $e');
      TLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to load invoice details',
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Load all invoices for a specific user
  Future<void> loadUserInvoices(String userId) async {
    try {
      isLoading.value = true;

      invoices.value = await invoiceRepo.getUserInvoices(userId);
    } catch (e) {
      print('Error loading user invoices: $e');
      TLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to load invoices',
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Load invoices for specific appointment
  Future<void> loadAppointmentInvoices(String appointmentId) async {
    try {
      isLoading.value = true;

      final appointmentInvoices = await invoiceRepo.getInvoicesByAppointmentId(appointmentId);
      invoices.value = appointmentInvoices;

      if (appointmentInvoices.isNotEmpty) {
        currentInvoice.value = appointmentInvoices.first;
      }
    } catch (e) {
      print('Error loading appointment invoices: $e');
      TLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to load invoice',
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Update invoice status
  Future<void> updateInvoiceStatus(String invoiceId, String status) async {
    try {
      await invoiceRepo.updateInvoiceStatus(invoiceId, status);

      // Update local invoice if it's the current one
      if (currentInvoice.value.invoiceId == invoiceId) {
        currentInvoice.value = currentInvoice.value.copyWith(status: status);
      }

      // Update in the list too
      final index = invoices.indexWhere((invoice) => invoice.invoiceId == invoiceId);
      if (index != -1) {
        invoices[index] = invoices[index].copyWith(status: status);
      }

      TLoaders.successSnackBar(
        title: 'Success',
        message: 'Invoice status updated successfully',
      );
    } catch (e) {
      print('Error updating invoice status: $e');
      TLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to update invoice status',
      );
    }
  }

  /// Mark invoice as paid and add PDF URL
  Future<void> markInvoiceAsPaid(String invoiceId, {String? pdfUrl}) async {
    try {
      await invoiceRepo.markInvoiceAsPaid(invoiceId, pdfUrl: pdfUrl);

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

  /// Download receipt - generate locally with payment transaction
  Future<void> downloadReceipt(String invoiceId) async {
    try {
      TLoaders.customToast(message: 'Preparing receipt...');

      // Get invoice details
      final invoice = currentInvoice.value.invoiceId == invoiceId
          ? currentInvoice.value
          : invoices.firstWhere((inv) => inv.invoiceId == invoiceId,
          orElse: () => InvoiceModel.empty());

      if (invoice.invoiceId.isEmpty) {
        // Try to fetch from database
        final fetchedInvoice = await invoiceRepo.getInvoiceById(invoiceId);
        if (fetchedInvoice == null) {
          throw Exception('Invoice not found');
        }
        currentInvoice.value = fetchedInvoice;
      }

      // Check if invoice is paid
      if (currentInvoice.value.status != 'paid') {
        TLoaders.warningSnackBar(
          title: 'Receipt Not Available',
          message: 'Receipt is only available for paid invoices',
        );
        return;
      }

      // Get payment transaction for this invoice
      final payments = await paymentRepo.fetchInvoicePayments(invoiceId);
      if (payments.isEmpty) {
        TLoaders.warningSnackBar(
          title: 'Payment Not Found',
          message: 'No payment record found for this invoice',
        );
        return;
      }

      // Use the latest successful payment
      final successfulPayment = payments.firstWhere(
            (payment) => payment.status == 'succeeded',
        orElse: () => payments.first,
      );

      // Generate and export receipt
      final receiptData = ReceiptData(
        invoice: currentInvoice.value,
        transaction: successfulPayment,
      );

      await ExportHelper.exportReceipt(receiptData: receiptData);

    } catch (e) {
      print('Error downloading receipt: $e');
      TLoaders.errorSnackBar(
        title: 'Download Failed',
        message: 'Failed to generate receipt: ${e.toString()}',
      );
    }
  }

  /// Get invoice by ID
  Future<InvoiceModel?> getInvoiceById(String invoiceId) async {
    try {
      return await invoiceRepo.getInvoiceById(invoiceId);
    } catch (e) {
      print('Error getting invoice by ID: $e');
      return null;
    }
  }

  /// Check if invoice exists
  Future<bool> invoiceExists(String invoiceId) async {
    try {
      return await invoiceRepo.invoiceExists(invoiceId);
    } catch (e) {
      print('Error checking if invoice exists: $e');
      return false;
    }
  }

  /// Get overdue invoices count for user
  Future<int> getOverdueInvoicesCount(String userId) async {
    try {
      return await invoiceRepo.getOverdueInvoicesCount(userId);
    } catch (e) {
      print('Error getting overdue invoices count: $e');
      return 0;
    }
  }

  /// Get unpaid invoices total for user
  Future<double> getUnpaidInvoicesTotal(String userId) async {
    try {
      return await invoiceRepo.getUnpaidInvoicesTotal(userId);
    } catch (e) {
      print('Error getting unpaid invoices total: $e');
      return 0.0;
    }
  }

  /// Create new invoice
  Future<String?> createInvoice(InvoiceModel invoice) async {
    try {
      final invoiceId = await invoiceRepo.createInvoice(invoice);

      // Refresh local data
      await loadAppointmentInvoices(invoice.appointmentId);

      TLoaders.successSnackBar(
        title: 'Success',
        message: 'Invoice created successfully',
      );

      return invoiceId;
    } catch (e) {
      print('Error creating invoice: $e');
      TLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to create invoice',
      );
      return null;
    }
  }

  /// Update existing invoice
  Future<void> updateInvoice(String invoiceId, InvoiceModel invoice) async {
    try {
      await invoiceRepo.updateInvoice(invoiceId, invoice);

      // Update local data
      if (currentInvoice.value.invoiceId == invoiceId) {
        currentInvoice.value = invoice.copyWith(invoiceId: invoiceId);
      }

      final index = invoices.indexWhere((inv) => inv.invoiceId == invoiceId);
      if (index != -1) {
        invoices[index] = invoice.copyWith(invoiceId: invoiceId);
      }

      TLoaders.successSnackBar(
        title: 'Success',
        message: 'Invoice updated successfully',
      );
    } catch (e) {
      print('Error updating invoice: $e');
      TLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to update invoice',
      );
    }
  }

  /// Delete invoice
  Future<void> deleteInvoice(String invoiceId) async {
    try {
      await invoiceRepo.deleteInvoice(invoiceId);

      // Remove from local data
      if (currentInvoice.value.invoiceId == invoiceId) {
        currentInvoice.value = InvoiceModel.empty();
      }

      invoices.removeWhere((invoice) => invoice.invoiceId == invoiceId);

      TLoaders.successSnackBar(
        title: 'Success',
        message: 'Invoice deleted successfully',
      );
    } catch (e) {
      print('Error deleting invoice: $e');
      TLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to delete invoice',
      );
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