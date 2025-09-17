import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../../payment/views/payment_method_selection_screen.dart';
import '../models/invoice_model.dart';
import '../controllers/invoice_controller.dart';

class InvoiceDetailScreen extends StatelessWidget {
  final String invoiceId;

  const InvoiceDetailScreen({super.key, required this.invoiceId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(InvoiceController());
    final darkMode = THelperFunctions.isDarkMode(context);

    // Load invoice data
    controller.loadInvoiceDetails(invoiceId);

    return Scaffold(
      backgroundColor: darkMode ? TColors.black : TColors.white,
      appBar: AppBar(
        backgroundColor: TColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Invoice Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                TColors.primary,
                TColors.primary.withOpacity(0.8),
              ],
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: TColors.primary));
        }

        final invoice = controller.currentInvoice.value;
        if (invoice.invoiceId.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Iconsax.document_text_bold,
                  size: 64,
                  color: darkMode ? TColors.grey : TColors.darkGrey,
                ),
                const SizedBox(height: 16),
                Text(
                  'Invoice not found',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: darkMode ? TColors.white : TColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'The requested invoice could not be loaded',
                  style: TextStyle(
                    color: darkMode ? TColors.grey : TColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Invoice Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      TColors.primary.withOpacity(0.1),
                      TColors.primary.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: TColors.primary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Invoice',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: darkMode ? TColors.white : TColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '#${invoice.invoiceId.substring(0, 8).toUpperCase()}',
                              style: TextStyle(
                                fontSize: 16,
                                color: darkMode ? TColors.grey : TColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: _getStatusColor(invoice.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _getStatusColor(invoice.status).withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            _getStatusText(invoice.status),
                            style: TextStyle(
                              color: _getStatusColor(invoice.status),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _InfoCard(
                            icon: Iconsax.calendar_1_bold,
                            label: 'Issue Date',
                            value: _formatDate(invoice.issuedAt),
                            darkMode: darkMode,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _InfoCard(
                            icon: Iconsax.clock_bold,
                            label: 'Due Date',
                            value: _formatDate(invoice.dueAt),
                            darkMode: darkMode,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Invoice Items
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: darkMode ? TColors.darkContainer : TColors.lightContainer,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: darkMode ? TColors.darkerGrey : TColors.borderPrimary,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: TColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Iconsax.receipt_item_bold,
                            color: TColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Invoice Items',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: darkMode ? TColors.white : TColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Items List
                    ...invoice.items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: item.type == 'service'
                                  ? Colors.blue.withOpacity(0.1)
                                  : Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              item.type == 'service' ? Iconsax.setting_2_bold : Iconsax.box_bold,
                              size: 14,
                              color: item.type == 'service' ? Colors.blue : Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.description,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: darkMode ? TColors.white : TColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  '${item.quantity} x RM${item.unitPrice.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: darkMode ? TColors.grey : TColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'RM${item.itemTotal.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: darkMode ? TColors.white : TColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    )).toList(),

                    const Divider(height: 32),

                    // Totals
                    Column(
                      children: [
                        _TotalRow(
                          label: 'Subtotal',
                          value: 'RM${invoice.subtotal.toStringAsFixed(2)}',
                          darkMode: darkMode,
                        ),
                        const SizedBox(height: 8),
                        _TotalRow(
                          label: 'Tax (${(invoice.taxRate * 100).toStringAsFixed(0)}%)',
                          value: 'RM${invoice.taxAmount.toStringAsFixed(2)}',
                          darkMode: darkMode,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: TColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: _TotalRow(
                            label: 'Total Amount',
                            value: 'RM${invoice.totalAmount.toStringAsFixed(2)}',
                            darkMode: darkMode,
                            isTotal: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Action Buttons
              if (invoice.status == 'unpaid') ...[
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to payment method selection
                      Get.to(() => PaymentMethodScreen(invoiceId: invoice.invoiceId));
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
                        const Icon(Iconsax.card_bold, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          'Pay Now - RM${invoice.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else if (invoice.status == 'paid') ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: invoice.pdfUrl != null ? () {
                          // Download receipt logic
                          controller.downloadReceipt(invoice.invoiceId);
                        } : null,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: TColors.primary,
                          side: const BorderSide(color: TColors.primary),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.download, size: 18),
                            const SizedBox(width: 8),
                            const Text(
                              'Download Receipt',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.green.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green, size: 16),
                            const SizedBox(width: 8),
                            const Text(
                              'Paid',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ] else if (invoice.status == 'overdue') ...[
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.to(() => PaymentMethodScreen(invoiceId: invoice.invoiceId));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColors.warning,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Iconsax.warning_2_bold, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          'Pay Overdue - RM${invoice.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'unpaid':
        return TColors.warning;
      case 'overdue':
        return TColors.error;
      case 'void':
        return TColors.darkGrey;
      default:
        return TColors.primary;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return 'PAID';
      case 'unpaid':
        return 'UNPAID';
      case 'overdue':
        return 'OVERDUE';
      case 'void':
        return 'VOID';
      default:
        return status.toUpperCase();
    }
  }

  String _formatDate(DateTime date) {
    if (date.year == 0) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool darkMode;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.darkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: darkMode ? TColors.darkContainer : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: darkMode ? TColors.darkerGrey : TColors.borderPrimary,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: TColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: darkMode ? TColors.grey : TColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: darkMode ? TColors.white : TColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final String value;
  final bool darkMode;
  final bool isTotal;

  const _TotalRow({
    required this.label,
    required this.value,
    required this.darkMode,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: darkMode ? TColors.white : TColors.textPrimary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: FontWeight.bold,
            color: isTotal ? TColors.primary : (darkMode ? TColors.white : TColors.textPrimary),
          ),
        ),
      ],
    );
  }
}