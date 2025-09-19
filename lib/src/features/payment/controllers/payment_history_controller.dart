import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/repository/payment/payment_repository.dart';
import '../models/payment_transaction_model.dart';

class PaymentHistoryController extends GetxController {
  final paymentRepo = Get.put(PaymentRepository());

  final RxList<PaymentTransactionModel> userTransactions = <PaymentTransactionModel>[].obs;
  final RxList<PaymentTransactionModel> userRefunds = <PaymentTransactionModel>[].obs;
  final RxList<PaymentTransactionModel> filteredTransactions = <PaymentTransactionModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedPaymentStatus = 'all'.obs;
  final RxString selectedTimeRange = 'all'.obs;
  final Rx<DateTimeRange?> customDateRange = Rx<DateTimeRange?>(null);

  // Temporary filters for modal
  final RxString tempSelectedPaymentStatus = 'all'.obs;
  final RxString tempSelectedTimeRange = 'all'.obs;
  final Rx<DateTimeRange?> tempCustomDateRange = Rx<DateTimeRange?>(null);

  final List<String> paymentStatuses = [
    'all',
    'succeeded',
    'pending',
    'failed',
    'refunded'
  ];

  final List<String> timeRanges = [
    'all',
    'today',
    'this_week',
    'this_month',
    'last_3_months',
    'custom'
  ];

  @override
  void onInit() {
    super.onInit();
    fetchTransactions();

    // Listen to filter changes
    ever(searchQuery, (_) => applyFilters());
    ever(selectedPaymentStatus, (_) => applyFilters());
    ever(selectedTimeRange, (_) => applyFilters());
    ever(customDateRange, (_) => applyFilters());
  }

  Future<void> fetchTransactions() async {
    try {
      isLoading.value = true;

      // Fetch both payments and refunds
      final payments = await paymentRepo.fetchUserTransactions();
      final refunds = await paymentRepo.getUserRefundRequests();

      userTransactions.value = payments;
      userRefunds.value = refunds;

      applyFilters();
    } catch (e) {
      print('Error fetching transactions: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilters() {
    List<PaymentTransactionModel> filtered = [];

    // Combine payments and refunds for filtering
    List<PaymentTransactionModel> allTransactions = [
      ...userTransactions,
      ...userRefunds,
    ];

    filtered = List.from(allTransactions);

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((transaction) {
        return transaction.transactionId.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
            transaction.paymentMethod.toLowerCase().contains(searchQuery.value.toLowerCase());
      }).toList();
    }

    // Apply payment status filter
    if (selectedPaymentStatus.value != 'all') {
      filtered = filtered.where((transaction) =>
      transaction.status == selectedPaymentStatus.value).toList();
    }

    // Apply time range filter
    if (selectedTimeRange.value != 'all') {
      filtered = _applyTimeFilter(filtered);
    }

    // Sort by date (newest first)
    filtered.sort((a, b) => b.transactionDateTime.compareTo(a.transactionDateTime));

    filteredTransactions.value = filtered;
  }

  List<PaymentTransactionModel> _applyTimeFilter(List<PaymentTransactionModel> transactions) {
    final now = DateTime.now();

    switch (selectedTimeRange.value) {
      case 'today':
        return transactions.where((t) =>
            t.transactionDateTime.isAfter(DateTime(now.year, now.month, now.day))).toList();

      case 'this_week':
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        return transactions.where((t) =>
            t.transactionDateTime.isAfter(DateTime(weekStart.year, weekStart.month, weekStart.day))).toList();

      case 'this_month':
        return transactions.where((t) =>
            t.transactionDateTime.isAfter(DateTime(now.year, now.month, 1))).toList();

      case 'last_3_months':
        final threeMonthsAgo = DateTime(now.year, now.month - 3, now.day);
        return transactions.where((t) =>
            t.transactionDateTime.isAfter(threeMonthsAgo)).toList();

      case 'custom':
        if (customDateRange.value != null) {
          return transactions.where((t) =>
          t.transactionDateTime.isAfter(customDateRange.value!.start) &&
              t.transactionDateTime.isBefore(customDateRange.value!.end.add(Duration(days: 1)))).toList();
        }
        return transactions;

      default:
        return transactions;
    }
  }

  // Get refunds for a specific payment
  List<PaymentTransactionModel> getRefundsForPayment(String paymentId) {
    return userRefunds.where((refund) => refund.originalPaymentId == paymentId).toList();
  }

  // Check if a payment has refunds
  bool hasRefunds(String paymentId) {
    return userRefunds.any((refund) => refund.originalPaymentId == paymentId);
  }

  // Get refund count for a payment
  int getRefundCount(String paymentId) {
    return userRefunds.where((refund) => refund.originalPaymentId == paymentId).length;
  }

  // Check if payment is eligible for refund (within 2 weeks)
  bool isEligibleForRefund(PaymentTransactionModel payment) {
    if (payment.status != 'succeeded') return false;

    final now = DateTime.now();
    final twoWeeksAgo = now.subtract(const Duration(days: 14));

    return payment.transactionDateTime.isAfter(twoWeeksAgo);
  }

  // Check if payment has pending refund
  bool hasPendingRefund(String paymentId) {
    return userRefunds.any((refund) =>
    refund.originalPaymentId == paymentId &&
        refund.refundStatus == 'processing');
  }

  void clearFilters() {
    selectedPaymentStatus.value = 'all';
    selectedTimeRange.value = 'all';
    customDateRange.value = null;
    applyFilters();
  }

  void clearTempFilters() {
    tempSelectedPaymentStatus.value = 'all';
    tempSelectedTimeRange.value = 'all';
    tempCustomDateRange.value = null;
  }

  void initTempFilters() {
    tempSelectedPaymentStatus.value = selectedPaymentStatus.value;
    tempSelectedTimeRange.value = selectedTimeRange.value;
    tempCustomDateRange.value = customDateRange.value;
  }

  void applyTempFilters() {
    selectedPaymentStatus.value = tempSelectedPaymentStatus.value;
    selectedTimeRange.value = tempSelectedTimeRange.value;
    customDateRange.value = tempCustomDateRange.value;
    applyFilters();
  }

  Future<void> refreshData() async {
    await fetchTransactions();
  }
}