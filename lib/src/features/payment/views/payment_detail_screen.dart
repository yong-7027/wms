import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../data/repository/payment/payment_repository.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../controllers/payment_history_controller.dart';
import '../models/payment_transaction_model.dart';
import 'refund_request_screen.dart';
import 'refund_detail_screen.dart';

class PaymentDetailScreen extends StatelessWidget {
  final PaymentTransactionModel transaction;

  const PaymentDetailScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final darkMode = THelperFunctions.isDarkMode(context);
    final controller = Get.find<PaymentHistoryController>();

    return Scaffold(
      backgroundColor: darkMode ? TColors.dark : TColors.light,
      appBar: AppBar(
        title: Text(
          'Transaction Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: darkMode ? TColors.white : TColors.dark,
          ),
        ),
        backgroundColor: darkMode ? TColors.dark : TColors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _getStatusGradient(transaction.status),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _getStatusColor(transaction.status).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    _getStatusIcon(transaction.status),
                    color: TColors.white,
                    size: 50,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    transaction.status.toUpperCase(),
                    style: const TextStyle(
                      color: TColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${transaction.currency} ${transaction.amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: TColors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Transaction Information Card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: darkMode ? TColors.black : TColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(darkMode ? 0.1 : 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Transaction Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: darkMode ? TColors.white : TColors.dark,
                      ),
                    ),
                  ),
                  _buildDetailRow(
                    context,
                    'Transaction ID',
                    transaction.transactionId,
                    Icons.receipt_long,
                    darkMode,
                    copyable: true,
                  ),
                  _buildDetailRow(
                    context,
                    'Invoice ID',
                    transaction.invoiceId.isEmpty ? 'N/A' : transaction.invoiceId,
                    Icons.description,
                    darkMode,
                  ),
                  _buildDetailRow(
                    context,
                    'Amount',
                    '${transaction.currency} ${transaction.amount.toStringAsFixed(2)}',
                    Icons.attach_money,
                    darkMode,
                  ),
                  _buildDetailRow(
                    context,
                    'Payment Method',
                    transaction.paymentMethod,
                    _getPaymentMethodIcon(transaction.paymentMethod),
                    darkMode,
                  ),
                  _buildDetailRow(
                    context,
                    'Date & Time',
                    _formatFullDate(transaction.transactionDateTime),
                    Icons.access_time,
                    darkMode,
                  ),
                  _buildDetailRow(
                    context,
                    'Refund Window',
                    controller.isEligibleForRefund(transaction)
                        ? 'Available until ${_formatRefundDeadline(transaction.transactionDateTime)}'
                        : 'Expired (14 days limit)',
                    Icons.schedule,
                    darkMode,
                    isLast: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Refunds Section (if any)
            Obx(() {
              final refunds = controller.getRefundsForPayment(transaction.transactionId);
              if (refunds.isNotEmpty) {
                return Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: darkMode ? TColors.black : TColors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(darkMode ? 0.1 : 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Icon(Icons.undo, color: TColors.orange),
                            const SizedBox(width: 8),
                            Text(
                              'Related Refunds (${refunds.length})',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: darkMode ? TColors.white : TColors.dark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ...refunds.asMap().entries.map((entry) {
                        final index = entry.key;
                        final refund = entry.value;
                        final isLast = index == refunds.length - 1;

                        return _buildRefundRow(context, refund, darkMode, isLast);
                      }).toList(),
                    ],
                  ),
                );
              }
              return const SizedBox();
            }),

            if (controller.getRefundsForPayment(transaction.transactionId).isNotEmpty)
              const SizedBox(height: 24),

            // Action Buttons
            _buildActionButtons(context, controller, darkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
      BuildContext context,
      String label,
      String value,
      IconData icon,
      bool darkMode, {
        bool isLast = false,
        bool copyable = false,
      }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(
                icon,
                color: TColors.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Text(
                  label,
                  style: TextStyle(
                    color: darkMode ? TColors.grey : TColors.darkGrey,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        value,
                        style: TextStyle(
                          color: darkMode ? TColors.white : TColors.dark,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                    if (copyable) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _copyToClipboard(context, value),
                        child: Icon(
                          Icons.copy,
                          color: TColors.primary,
                          size: 16,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            color: darkMode ? TColors.dark : TColors.light,
            height: 1,
          ),
      ],
    );
  }

  Widget _buildRefundRow(BuildContext context, PaymentTransactionModel refund, bool darkMode, bool isLast) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: InkWell(
            onTap: () => Get.to(() => RefundDetailScreen(refund: refund)),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: darkMode ? TColors.darkerGrey.withOpacity(0.3) : TColors.lightGrey,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getRefundStatusColor(refund.refundStatus ?? 'processing').withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getRefundStatusColor(refund.refundStatus ?? 'processing').withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.undo,
                      color: _getRefundStatusColor(refund.refundStatus ?? 'processing'),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          refund.transactionId,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: darkMode ? TColors.white : TColors.dark,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${refund.currency} ${refund.amount.toStringAsFixed(2)} • ${_formatDate(refund.transactionDateTime)}',
                          style: TextStyle(
                            color: darkMode ? TColors.grey : TColors.darkGrey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getRefundStatusColor(refund.refundStatus ?? 'processing').withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      (refund.refundStatus ?? 'processing').toUpperCase(),
                      style: TextStyle(
                        color: _getRefundStatusColor(refund.refundStatus ?? 'processing'),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: darkMode ? TColors.grey : TColors.darkGrey,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (!isLast)
          Divider(
            color: darkMode ? TColors.dark : TColors.light,
            height: 1,
          ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, PaymentHistoryController controller, bool darkMode) {
    return Obx(() {
      if (transaction.status.toLowerCase() != 'succeeded') {
        return const SizedBox();
      }

      final isEligible = controller.isEligibleForRefund(transaction);
      final hasPending = controller.hasPendingRefund(transaction.transactionId);
      final rejectedRefunds = controller.getRefundsForPayment(transaction.transactionId)
          .where((refund) => refund.refundStatus == 'rejected').toList();

      if (!isEligible && rejectedRefunds.isEmpty && !hasPending) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: darkMode ? TColors.black : TColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: TColors.grey.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(Icons.schedule_outlined, color: TColors.grey, size: 32),
              const SizedBox(height: 8),
              Text(
                'Refund Window Expired',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: darkMode ? TColors.white : TColors.dark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Refund requests must be submitted within 14 days of payment',
                style: TextStyle(
                  color: darkMode ? TColors.grey : TColors.darkGrey,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      if (hasPending) {
        final pendingRefund = controller.getRefundsForPayment(transaction.transactionId)
            .firstWhere((refund) => refund.refundStatus == 'processing');

        return Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: TColors.refundProcessing.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: TColors.refundProcessing.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Icon(Icons.pending_actions, color: TColors.refundProcessing, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    'Refund Request Pending',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: TColors.refundProcessing,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'We\'re reviewing your refund request. This usually takes 3-5 business days.',
                    style: TextStyle(
                      color: darkMode ? TColors.grey : TColors.darkGrey,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _cancelRefund(context, pendingRefund),
                style: OutlinedButton.styleFrom(
                  foregroundColor: TColors.red,
                  side: BorderSide(color: TColors.red),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Cancel Refund Request',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      }

      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => Get.to(() => RefundRequestScreen(), arguments: transaction),
          icon: const Icon(Icons.undo),
          label: Text(rejectedRefunds.isNotEmpty ? 'Request Refund Again' : 'Request Refund'),
          style: ElevatedButton.styleFrom(
            backgroundColor: TColors.orange,
            foregroundColor: TColors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
    });
  }

  void _cancelRefund(BuildContext context, PaymentTransactionModel refund) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancel Refund Request'),
        content: Text('Are you sure you want to cancel this refund request? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Keep Request'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              try {
                final paymentRepo = PaymentRepository.instance;
                await paymentRepo.cancelRefundRequest(refund.transactionId);

                // Refresh the controller data
                final controller = Get.find<PaymentHistoryController>();
                await controller.refreshData();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Refund request cancelled successfully'),
                    backgroundColor: TColors.success,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to cancel refund request'),
                    backgroundColor: TColors.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: TColors.red),
            child: Text('Cancel Request'),
          ),
        ],
      ),
    );
  }

  List<Color> _getStatusGradient(String status) {
    switch (status.toLowerCase()) {
      case 'succeeded':
        return [TColors.paymentSucceeded.withOpacity(0.8), TColors.paymentSucceeded];
      case 'pending':
        return [TColors.paymentPending.withOpacity(0.8), TColors.paymentPending];
      case 'failed':
        return [TColors.paymentFailed.withOpacity(0.8), TColors.paymentFailed];
      case 'refunded':
        return [TColors.paymentRefunded.withOpacity(0.8), TColors.paymentRefunded];
      default:
        return [TColors.grey.withOpacity(0.8), TColors.grey];
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'succeeded':
        return TColors.paymentSucceeded;
      case 'pending':
        return TColors.paymentPending;
      case 'failed':
        return TColors.paymentFailed;
      case 'refunded':
        return TColors.paymentRefunded;
      default:
        return TColors.grey;
    }
  }

  Color _getRefundStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return TColors.refundApproved;
      case 'rejected':
        return TColors.refundRejected;
      case 'processing':
        return TColors.refundProcessing;
      case 'cancelled':
        return TColors.refundCancelled;
      default:
        return TColors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'succeeded':
        return Icons.check_circle;
      case 'pending':
        return Icons.schedule;
      case 'failed':
        return Icons.error;
      case 'refunded':
        return Icons.undo;
      default:
        return Icons.help;
    }
  }

  IconData _getPaymentMethodIcon(String paymentMethod) {
    switch (paymentMethod.toLowerCase()) {
      case 'credit card':
        return Icons.credit_card;
      case 'paypal':
        return Icons.payment;
      case 'apple pay':
        return Icons.phone_iphone;
      case 'google pay':
        return Icons.android;
      case 'bank transfer':
        return Icons.account_balance;
      case 'stripe':
        return Icons.credit_card;
      default:
        return Icons.payment;
    }
  }

  String _formatFullDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    final month = months[date.month - 1];
    final day = date.day.toString().padLeft(2, '0');
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$month $day, $year at $hour:$minute';
  }

  String _formatRefundDeadline(DateTime paymentDate) {
    final deadline = paymentDate.add(const Duration(days: 14));
    return _formatFullDate(deadline);
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '${difference}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied to clipboard'),
        backgroundColor: TColors.primary,
        duration: Duration(seconds: 2),
      ),
    );
  }
}