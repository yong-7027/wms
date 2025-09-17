import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/payment_transaction_model.dart';

class PaymentHistoryController extends GetxController {
  final RxList<PaymentTransactionModel> allTransactions = <PaymentTransactionModel>[].obs;
  final RxList<PaymentTransactionModel> filteredTransactions = <PaymentTransactionModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedServiceType = 'all'.obs;
  final RxString selectedPaymentStatus = 'all'.obs;
  final RxString selectedTimeRange = 'all'.obs;
  final Rx<DateTimeRange?> customDateRange = Rx<DateTimeRange?>(null);

  // Temporary filters
  final RxString tempSelectedServiceType = 'all'.obs;
  final RxString tempSelectedPaymentStatus = 'all'.obs;
  final RxString tempSelectedTimeRange = 'all'.obs;
  final Rx<DateTimeRange?> tempCustomDateRange = Rx<DateTimeRange?>(null);

  final List<String> serviceTypes = [
    'all',
    'Car Wash',
    'Oil Change',
    'Tire Service',
    'Battery Service',
    'Engine Service',
    'Brake Service'
  ];

  final List<String> paymentStatuses = [
    'all',
    'completed',
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
    _generateMockData();
    applyFilters();

    // Listen to filter changes
    ever(searchQuery, (_) => applyFilters());
    ever(selectedServiceType, (_) => applyFilters());
    ever(selectedPaymentStatus, (_) => applyFilters());
    ever(selectedTimeRange, (_) => applyFilters());
    ever(customDateRange, (_) => applyFilters());
  }

  void _generateMockData() {
    final now = DateTime.now();
    allTransactions.value = [
      PaymentTransactionModel(
        transactionId: 'TXN20240801001',
        invoiceId: '',
        amount: 25.99,
        currency: 'USD',
        paymentMethod: 'Credit Card',
        transactionDateTime: now.subtract(Duration(days: 1)),
        status: 'completed',
      ),
      PaymentTransactionModel(
        transactionId: 'TXN20240801002',
        invoiceId: '',
        amount: 89.50,
        currency: 'USD',
        paymentMethod: 'PayPal',
        transactionDateTime: now.subtract(Duration(days: 2)),
        status: 'completed',
      ),
      PaymentTransactionModel(
        transactionId: 'TXN20240801003',
        invoiceId: '',
        amount: 156.75,
        currency: 'USD',
        paymentMethod: 'Apple Pay',
        transactionDateTime: now.subtract(Duration(days: 5)),
        status: 'pending',
      ),
      PaymentTransactionModel(
        transactionId: 'TXN20240801004',
        invoiceId: '',
        amount: 42.30,
        currency: 'USD',
        paymentMethod: 'Credit Card',
        transactionDateTime: now.subtract(Duration(days: 7)),
        status: 'failed',
      ),
      PaymentTransactionModel(
        transactionId: 'TXN20240801005',
        invoiceId: '',
        amount: 78.90,
        currency: 'USD',
        paymentMethod: 'Google Pay',
        transactionDateTime: now.subtract(Duration(days: 12)),
        status: 'completed',
      ),
      PaymentTransactionModel(
        transactionId: 'TXN20240801006',
        invoiceId: '',
        amount: 234.50,
        currency: 'USD',
        paymentMethod: 'Bank Transfer',
        transactionDateTime: now.subtract(Duration(days: 18)),
        status: 'refunded',
      ),
      PaymentTransactionModel(
        transactionId: 'TXN20240801007',
        invoiceId: '',
        amount: 67.25,
        currency: 'USD',
        paymentMethod: 'Credit Card',
        transactionDateTime: now.subtract(Duration(days: 25)),
        status: 'completed',
      ),
      PaymentTransactionModel(
        transactionId: 'TXN20240801008',
        invoiceId: '',
        amount: 123.45,
        currency: 'USD',
        paymentMethod: 'PayPal',
        transactionDateTime: now.subtract(Duration(days: 35)),
        status: 'completed',
      ),
    ];
  }

  void applyFilters() {
    List<PaymentTransactionModel> filtered = List.from(allTransactions);

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

  void clearFilters() {
    selectedServiceType.value = 'all';
    selectedPaymentStatus.value = 'all';
    selectedTimeRange.value = 'all';
    customDateRange.value = null;
    applyFilters();
  }

  void clearTempFilters() {
    tempSelectedServiceType.value = 'all';
    tempSelectedPaymentStatus.value = 'all';
    tempSelectedTimeRange.value = 'all';
    tempCustomDateRange.value = null;
  }

  void initTempFilters() {
    tempSelectedServiceType.value = selectedServiceType.value;
    tempSelectedPaymentStatus.value = selectedPaymentStatus.value;
    tempSelectedTimeRange.value = selectedTimeRange.value;
    tempCustomDateRange.value = customDateRange.value;
  }

  void applyTempFilters() {
    selectedServiceType.value = tempSelectedServiceType.value;
    selectedPaymentStatus.value = tempSelectedPaymentStatus.value;
    selectedTimeRange.value = tempSelectedTimeRange.value;
    customDateRange.value = tempCustomDateRange.value;
    applyFilters();
  }

  void refreshData() {
    isLoading.value = true;
    // Simulate API call
    Future.delayed(Duration(seconds: 1), () {
      _generateMockData();
      applyFilters();
      isLoading.value = false;
    });
  }
}
