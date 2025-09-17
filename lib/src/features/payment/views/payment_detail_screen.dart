import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../models/payment_transaction_model.dart';

class PaymentDetailScreen extends StatelessWidget {
  final PaymentTransactionModel transaction;

  const PaymentDetailScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final darkMode = THelperFunctions.isDarkMode(context);

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
        actions: [
          IconButton(
            onPressed: () => _shareTransactionDetails(context, transaction),
            icon: Icon(
              Icons.share,
              color: TColors.primary,
            ),
          ),
        ],
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
                color: darkMode ? TColors.darkGrey : TColors.white,
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
                    'Status',
                    transaction.status.toUpperCase(),
                    _getStatusIcon(transaction.status),
                    darkMode,
                    isLast: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Service Details Card (Mock data for car service)
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: darkMode ? TColors.darkGrey : TColors.white,
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
                      'Service Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: darkMode ? TColors.white : TColors.dark,
                      ),
                    ),
                  ),
                  _buildDetailRow(
                    context,
                    'Service Type',
                    _getServiceTypeFromAmount(transaction.amount),
                    Icons.car_repair,
                    darkMode,
                  ),
                  _buildDetailRow(
                    context,
                    'Vehicle',
                    'Toyota Camry 2020',
                    Icons.directions_car,
                    darkMode,
                  ),
                  _buildDetailRow(
                    context,
                    'Service Duration',
                    '2 hours 15 minutes',
                    Icons.schedule,
                    darkMode,
                  ),
                  _buildDetailRow(
                    context,
                    'Technician',
                    'John Smith',
                    Icons.person,
                    darkMode,
                    isLast: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _downloadReceipt(context, transaction),
                    icon: const Icon(Icons.download),
                    label: const Text('Download Receipt'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColors.primary,
                      foregroundColor: TColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _contactSupport(context, transaction),
                    icon: const Icon(Icons.support_agent),
                    label: const Text('Contact Support'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: TColors.primary,
                      side: BorderSide(color: TColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Additional Actions
            if (transaction.status == 'completed')
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () => _requestRefund(context, transaction),
                  icon: const Icon(Icons.undo),
                  label: const Text('Request Refund'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
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

  List<Color> _getStatusGradient(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return [Colors.green.shade400, Colors.green.shade600];
      case 'pending':
        return [Colors.orange.shade400, Colors.orange.shade600];
      case 'failed':
        return [Colors.red.shade400, Colors.red.shade600];
      case 'refunded':
        return [Colors.blue.shade400, Colors.blue.shade600];
      default:
        return [Colors.grey.shade400, Colors.grey.shade600];
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      case 'refunded':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
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

  String _getServiceTypeFromAmount(double amount) {
    if (amount < 30) return 'Car Wash';
    if (amount < 60) return 'Oil Change';
    if (amount < 100) return 'Tire Service';
    if (amount < 150) return 'Battery Service';
    if (amount < 200) return 'Engine Service';
    return 'Full Service Package';
  }

  void _copyToClipboard(BuildContext context, String text) {
    // Implement clipboard copy
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied to clipboard'),
        backgroundColor: TColors.primary,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareTransactionDetails(BuildContext context, PaymentTransactionModel transaction) {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Share functionality would be implemented here'),
        backgroundColor: TColors.primary,
      ),
    );
  }

  void _downloadReceipt(BuildContext context, PaymentTransactionModel transaction) {
    // Implement download receipt
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Receipt download started'),
        backgroundColor: TColors.primary,
      ),
    );
  }

  void _contactSupport(BuildContext context, PaymentTransactionModel transaction) {
    // Implement contact support
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Contact Support'),
        content: Text('Would you like to contact support regarding transaction ${transaction.transactionId}?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // Open support chat or email
            },
            child: Text('Contact'),
          ),
        ],
      ),
    );
  }

  void _requestRefund(BuildContext context, PaymentTransactionModel transaction) {
    // Implement refund request
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Request Refund'),
        content: Text('Are you sure you want to request a refund for this transaction?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Refund request submitted'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: Text('Request Refund'),
          ),
        ],
      ),
    );
  }
}