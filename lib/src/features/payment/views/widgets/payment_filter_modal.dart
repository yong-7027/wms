import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/constants/colors.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../controllers/payment_history_controller.dart';

class PaymentFilterModal extends StatelessWidget {
  final PaymentHistoryController controller;

  const PaymentFilterModal({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final darkMode = THelperFunctions.isDarkMode(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: darkMode ? TColors.dark : TColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: TColors.grey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filters',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: darkMode ? TColors.white : TColors.dark,
                  ),
                ),
                TextButton(
                  onPressed: () => controller.clearTempFilters(),
                  child: Text('Clear All', style: TextStyle(color: TColors.primary)),
                ),
              ],
            ),
          ),

          const Divider(),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Payment Status Section
                  Text(
                    'Payment Status',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: darkMode ? TColors.white : TColors.dark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Obx(() => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: controller.paymentStatuses.map((status) {
                      final isSelected = controller.tempSelectedPaymentStatus.value == status;
                      return GestureDetector(
                        onTap: () => controller.tempSelectedPaymentStatus.value = status,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? TColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? TColors.primary : TColors.grey,
                            ),
                          ),
                          child: Text(
                            status == 'all' ? 'All Statuses' : THelperFunctions.titleCase(status),
                            style: TextStyle(
                              color: isSelected ? TColors.white : (darkMode ? TColors.grey : TColors.darkGrey),
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  )),

                  const SizedBox(height: 24),

                  // Time Range Section
                  Text(
                    'Time Range',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: darkMode ? TColors.white : TColors.dark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Obx(() => Column(
                    children: controller.timeRanges.map((range) {
                      final isSelected = controller.tempSelectedTimeRange.value == range;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          _getTimeRangeLabel(range),
                          style: TextStyle(
                            color: darkMode ? TColors.white : TColors.dark,
                          ),
                        ),
                        leading: Radio<String>(
                          value: range,
                          groupValue: controller.tempSelectedTimeRange.value,
                          activeColor: TColors.primary,
                          onChanged: (value) async {
                            if (value == 'custom') {
                              final dateRange = await showDateRangePicker(
                                context: context,
                                firstDate: DateTime.now().subtract(Duration(days: 365)),
                                lastDate: DateTime.now(),
                              );
                              if (dateRange != null) {
                                controller.tempCustomDateRange.value = dateRange;
                                controller.tempSelectedTimeRange.value = 'custom';
                              }
                            } else {
                              controller.tempSelectedTimeRange.value = value!;
                            }
                          },
                        ),
                      );
                    }).toList(),
                  )),

                  // Custom Date Range Display
                  Obx(() {
                    if (controller.tempSelectedTimeRange.value == 'custom' &&
                        controller.tempCustomDateRange.value != null) {
                      return Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: TColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.date_range, color: TColors.primary, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              '${_formatDateShort(controller.tempCustomDateRange.value!.start)} - ${_formatDateShort(controller.tempCustomDateRange.value!.end)}',
                              style: TextStyle(
                                color: TColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox();
                  }),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Action Buttons
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: darkMode ? TColors.white : TColors.dark,
                      side: BorderSide(color: darkMode ? TColors.grey : TColors.darkGrey),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      controller.applyTempFilters();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColors.primary,
                      foregroundColor: TColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Apply Filters',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeRangeLabel(String timeRange) {
    switch (timeRange) {
      case 'today': return 'Today';
      case 'this_week': return 'This Week';
      case 'this_month': return 'This Month';
      case 'last_3_months': return 'Last 3 Months';
      case 'custom': return 'Custom Range';
      default: return 'All Time';
    }
  }

  String _formatDateShort(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
