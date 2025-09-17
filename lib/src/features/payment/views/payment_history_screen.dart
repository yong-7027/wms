import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../controllers/payment_history_controller.dart';
import '../models/payment_transaction_model.dart';
import 'payment_detail_screen.dart';
import 'widgets/payment_filter_modal.dart';

class PaymentHistoryScreen extends StatelessWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PaymentHistoryController());
    final darkMode = THelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: darkMode ? TColors.dark : TColors.light,
      appBar: AppBar(
        title: Text(
          'Payment History',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: darkMode ? TColors.white : TColors.dark,
          ),
        ),
        backgroundColor: darkMode ? TColors.dark : TColors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showFilterModal(context, controller),
            icon: Icon(
              Icons.filter_list,
              color: TColors.primary,
            ),
          ),
          IconButton(
            onPressed: controller.refreshData,
            icon: Icon(
              Icons.refresh,
              color: TColors.primary,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: darkMode ? TColors.darkGrey : TColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              onChanged: (value) => controller.searchQuery.value = value,
              decoration: InputDecoration(
                hintText: 'Search by transaction ID or payment method...',
                hintStyle: TextStyle(color: darkMode ? TColors.darkGrey : TColors.grey),
                prefixIcon: Icon(Icons.search, color: TColors.primary),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),

          // Filter Chips
          Container(
            height: 50,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Obx(() => ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip(
                  'Status: ${THelperFunctions.titleCase(controller.selectedPaymentStatus.value)}',
                  controller.selectedPaymentStatus.value != 'all',
                      () => _showStatusFilter(context, controller),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Time: ${THelperFunctions.titleCase(controller.selectedTimeRange.value)}',
                  controller.selectedTimeRange.value != 'all',
                      () => _showTimeRangeFilter(context, controller),
                ),
                const SizedBox(width: 8),
                if (controller.selectedPaymentStatus.value != 'all' ||
                    controller.selectedTimeRange.value != 'all')
                  _buildClearFiltersChip(() => controller.clearFilters()),
              ],
            )),
          ),

          const SizedBox(height: 16),

          // Transaction List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(
                  child: CircularProgressIndicator(color: TColors.primary),
                );
              }

              if (controller.filteredTransactions.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 80,
                        color: darkMode ? TColors.darkGrey : TColors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No transactions found',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: darkMode ? TColors.white : TColors.dark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Try adjusting your filters or check back later',
                        style: TextStyle(
                          color: darkMode ? TColors.darkGrey : TColors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async => controller.refreshData(),
                color: TColors.primary,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.filteredTransactions.length,
                  itemBuilder: (context, index) {
                    final transaction = controller.filteredTransactions[index];
                    return _buildTransactionCard(context, transaction, darkMode);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isActive ? TColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? TColors.primary : TColors.grey,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? TColors.white : TColors.grey,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildClearFiltersChip(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.red, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.clear, color: Colors.red, size: 16),
            const SizedBox(width: 4),
            Text(
              'Clear',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard(BuildContext context, PaymentTransactionModel transaction, bool darkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Get.to(() => PaymentDetailScreen(transaction: transaction)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        transaction.transactionId,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: darkMode ? TColors.white : TColors.dark,
                        ),
                      ),
                    ),
                    _buildStatusBadge(transaction.status, darkMode),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.attach_money,
                      color: TColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${transaction.currency} ${transaction.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: TColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      _getPaymentMethodIcon(transaction.paymentMethod),
                      color: darkMode ? TColors.grey : TColors.darkGrey,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      transaction.paymentMethod,
                      style: TextStyle(
                        color: darkMode ? TColors.grey : TColors.darkGrey,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.access_time,
                      color: darkMode ? TColors.grey : TColors.darkGrey,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(transaction.transactionDateTime),
                      style: TextStyle(
                        color: darkMode ? TColors.grey : TColors.darkGrey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, bool darkMode) {
    Color backgroundColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'completed':
        backgroundColor = Colors.green.withOpacity(0.2);
        textColor = Colors.green;
        break;
      case 'pending':
        backgroundColor = Colors.orange.withOpacity(0.2);
        textColor = Colors.orange;
        break;
      case 'failed':
        backgroundColor = Colors.red.withOpacity(0.2);
        textColor = Colors.red;
        break;
      case 'refunded':
        backgroundColor = Colors.blue.withOpacity(0.2);
        textColor = Colors.blue;
        break;
      default:
        backgroundColor = Colors.grey.withOpacity(0.2);
        textColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
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

  // String _getTimeRangeLabel(String timeRange) {
  //   switch (timeRange) {
  //     case 'today': return 'Today';
  //     case 'this_week': return 'This Week';
  //     case 'this_month': return 'This Month';
  //     case 'last_3_months': return 'Last 3 Months';
  //     case 'custom': return 'Custom';
  //     default: return 'All Time';
  //   }
  // }

  void _showFilterModal(BuildContext context, PaymentHistoryController controller) {
    // Initialize temp filters with current values
    controller.initTempFilters();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PaymentFilterModal(controller: controller),
    );
  }

  void _showStatusFilter(BuildContext context, PaymentHistoryController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Payment Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: controller.paymentStatuses.map((status) {
            return ListTile(
              title: Text(status == 'all' ? 'All Statuses' : THelperFunctions.titleCase(status)),
              leading: Radio<String>(
                value: status,
                groupValue: controller.selectedPaymentStatus.value,
                onChanged: (value) {
                  controller.selectedPaymentStatus.value = value!;
                  Get.back();
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showTimeRangeFilter(BuildContext context, PaymentHistoryController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Time Range'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: controller.timeRanges.map((range) {
            return ListTile(
              title: Text(range == 'all' ? 'All Time' : THelperFunctions.titleCase(range)),
              leading: Radio<String>(
                value: range,
                groupValue: controller.selectedTimeRange.value,
                onChanged: (value) async {
                  if (value == 'custom') {
                    Get.back();
                    final dateRange = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime.now().subtract(Duration(days: 365)),
                      lastDate: DateTime.now(),
                    );
                    if (dateRange != null) {
                      controller.customDateRange.value = dateRange;
                      controller.selectedTimeRange.value = 'custom';
                    }
                  } else {
                    controller.selectedTimeRange.value = value!;
                    Get.back();
                  }
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}