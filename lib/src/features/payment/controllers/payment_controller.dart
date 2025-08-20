import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/subscription_plan_model.dart';
import '../models/payment_transaction_model.dart';

class PaymentController extends GetxController {
  static PaymentController get instance => Get.find();

  // Observable variables
  final RxString selectedPaymentMethod = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isProcessingPayment = false.obs;
  final Rx<SubscriptionPlanModel> selectedPlan = SubscriptionPlanModel.empty().obs;

  // FIXED: Correct Firebase Cloud Function URLs
  static const String baseUrl = 'https://us-central1-workshop-management-syst-b9cec.cloudfunctions.net/api';
  static const String createPaymentIntentUrl = '$baseUrl/createPaymentIntent';
  static const String webhookUrl = '$baseUrl/stripeWebhook';

  @override
  void onInit() {
    super.onInit();
    loadSubscriptionPlans();
    // Set default selected plan
    selectedPlan.value = SubscriptionPlanModel(
      planId: 'premium_monthly',
      name: 'Premium Plan',
      price: 29.0,
      currency: 'MYR',
      duration: 'monthly',
      features: ['Unlimited access', 'Premium support', 'Advanced features'],
    );
  }

  /// Load subscription plans
  void loadSubscriptionPlans() {
    try {
      isLoading.value = true;
      // Add your subscription plans logic here
    } finally {
      isLoading.value = false;
    }
  }

  /// Select payment method
  void selectPaymentMethod(String method) {
    selectedPaymentMethod.value = method;
  }

  /// Get formatted price
  String getFormattedPrice(double price) {
    return 'RM${price.toStringAsFixed(0)}';
  }

  /// Confirm payment
  Future<void> confirmPayment() async {
    if (selectedPaymentMethod.value.isEmpty) {
      Get.snackbar('Error', 'Please select a payment method');
      return;
    }

    switch (selectedPaymentMethod.value) {
      case 'stripe':
        await _processStripePayment();
        break;
      case 'paypal':
        _processPayPalPayment();
        break;
      case 'razorpay':
        _processRazorPayPayment();
        break;
      default:
        Get.snackbar('Error', 'Invalid payment method selected');
    }
  }

  /// Process Stripe Payment
  Future<void> _processStripePayment() async {
    try {
      isProcessingPayment.value = true;

      // Step 1: Create payment intent on your backend
      final paymentIntent = await _createPaymentIntent();

      if (paymentIntent == null) {
        throw Exception('Failed to create payment intent');
      }

      // Step 2: Initialize the payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent['client_secret'],
          merchantDisplayName: 'Workshop Management System',
          customerId: paymentIntent['customer_id'],
          customerEphemeralKeySecret: paymentIntent['ephemeral_key'],
          style: ThemeMode.system,
          billingDetails: const BillingDetails(
            address: Address(
              country: 'MY',
              city: '',
              line1: '',
              line2: '',
              postalCode: '',
              state: '',
            ),
          ),
        ),
      );

      // Step 3: Present the payment sheet
      await Stripe.instance.presentPaymentSheet();

      // Step 4: Payment successful
      await _handlePaymentSuccess(paymentIntent['id']);

    } catch (e) {
      _handlePaymentError(e.toString());
    } finally {
      isProcessingPayment.value = false;
    }
  }

  /// Create Payment Intent on Firebase Cloud Function
  Future<Map<String, dynamic>?> _createPaymentIntent() async {
    try {
      print('Making request to: $createPaymentIntentUrl'); // Debug log

      final response = await http.post(
        Uri.parse(createPaymentIntentUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'amount': (selectedPlan.value.price * 100).toInt(), // Amount in cents
          'currency': selectedPlan.value.currency.toLowerCase(),
          'planId': selectedPlan.value.planId,
          // Add user ID if available from your auth system
          // 'userId': FirebaseAuth.instance.currentUser?.uid,
        }),
      );

      print('Response status: ${response.statusCode}'); // Debug log
      print('Response body: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create payment intent: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error in _createPaymentIntent: $e'); // Debug log
      Get.snackbar('Error', 'Failed to initialize payment: $e');
      return null;
    }
  }

  /// Handle Payment Success
  Future<void> _handlePaymentSuccess(String paymentIntentId) async {
    try {
      // Create transaction record
      final transaction = PaymentTransactionModel(
        transactionId: paymentIntentId,
        amount: selectedPlan.value.price,
        currency: selectedPlan.value.currency,
        paymentMethod: 'stripe',
        transactionDateTime: DateTime.now(),
        status: 'completed',
      );

      // Save transaction to database (implement your database logic)
      // await _saveTransaction(transaction);

      // Navigate to success page
      Get.toNamed('/payment-success', arguments: {
        'transaction': transaction,
        'plan': selectedPlan.value,
      });

    } catch (e) {
      Get.snackbar('Error', 'Payment completed but failed to save record: $e');
    }
  }

  /// Handle Payment Error
  void _handlePaymentError(String error) {
    String errorMessage = 'Payment failed';

    if (error.contains('canceled')) {
      errorMessage = 'Payment was canceled';
    } else if (error.contains('failed')) {
      errorMessage = 'Payment failed. Please try again';
    } else if (error.contains('requires_payment_method')) {
      errorMessage = 'Please select a valid payment method';
    }

    Get.snackbar(
      'Payment Error',
      errorMessage,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red[100],
      colorText: Colors.red[800],
    );
  }

  /// Process PayPal Payment (placeholder)
  void _processPayPalPayment() {
    Get.snackbar('Info', 'PayPal integration coming soon');
  }

  /// Process RazorPay Payment (placeholder)
  void _processRazorPayPayment() {
    Get.snackbar('Info', 'RazorPay integration coming soon');
  }
}