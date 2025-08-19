import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../models/payment_transaction_model.dart';
import '../models/subscription_plan_model.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final darkMode = THelperFunctions.isDarkMode(context);

    // Get arguments passed from payment controller
    final arguments = Get.arguments as Map<String, dynamic>?;
    final PaymentTransactionModel transaction =
        arguments?['transaction'] ?? PaymentTransactionModel.empty();
    final SubscriptionPlanModel plan =
        arguments?['plan'] ?? SubscriptionPlanModel.empty();

    return Scaffold(
      backgroundColor: darkMode ? TColors.black : TColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 60),

              // Success Animation Container
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Success Title
              Text(
                'Payment Successful!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: darkMode ? Colors.white : Colors.black,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Success Subtitle
              Text(
                'Your subscription has been activated successfully',
                style: TextStyle(
                  fontSize: 16,
                  color: darkMode ? Colors.grey[400] : Colors.grey[600],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Transaction Details Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: darkMode ? Colors.grey[900] : Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: darkMode ? Colors.grey[800]! : Colors.grey[200]!,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: TColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Iconsax.receipt_1_bold,
                            color: TColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Transaction Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: darkMode ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Transaction ID
                    _DetailRow(
                      label: 'Transaction ID',
                      value: transaction.transactionId.isNotEmpty
                          ? transaction.transactionId.substring(0, 16) + '...'
                          : 'N/A',
                      darkMode: darkMode,
                    ),

                    const SizedBox(height: 16),

                    // Plan Name
                    _DetailRow(
                      label: 'Plan',
                      value: plan.name.isNotEmpty ? plan.name : 'Premium Plan',
                      darkMode: darkMode,
                    ),

                    const SizedBox(height: 16),

                    // Amount
                    _DetailRow(
                      label: 'Amount',
                      value: plan.price > 0 ? plan.formattedPrice : 'RM29',
                      darkMode: darkMode,
                      isAmount: true,
                    ),

                    const SizedBox(height: 16),

                    // Payment Method
                    _DetailRow(
                      label: 'Payment Method',
                      value: _getPaymentMethodName(transaction.paymentMethod),
                      darkMode: darkMode,
                    ),

                    const SizedBox(height: 16),

                    // Date
                    _DetailRow(
                      label: 'Date',
                      value: _formatDate(transaction.transactionDateTime),
                      darkMode: darkMode,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Plan Benefits
              if (plan.features.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: TColors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: TColors.primary.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Iconsax.crown_1_bold,
                            color: TColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Your Benefits',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: darkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...plan.features.take(3).map((feature) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              feature,
                              style: TextStyle(
                                fontSize: 14,
                                color: darkMode ? Colors.grey[300] : Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],

              const Spacer(),

              // Action Buttons
              Column(
                children: [
                  // Continue Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to home or main app screen
                        Get.offAllNamed('/home');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Download Receipt Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () {
                        // TODO: Implement download receipt functionality
                        Get.snackbar(
                          'Info',
                          'Receipt download feature coming soon',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: TColors.primary,
                        side: const BorderSide(color: TColors.primary),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.download,
                            size: 18,
                            color: TColors.primary,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Download Receipt',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getPaymentMethodName(String method) {
    switch (method.toLowerCase()) {
      case 'stripe':
        return 'Stripe';
      case 'paypal':
        return 'PayPal';
      case 'razorpay':
        return 'RazorPay';
      default:
        return 'Card Payment';
    }
  }

  String _formatDate(DateTime dateTime) {
    if (dateTime.year == 0) {
      return DateTime.now().toString().split('.')[0];
    }
    return dateTime.toString().split('.')[0];
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool darkMode;
  final bool isAmount;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.darkMode,
    this.isAmount = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: darkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isAmount ? FontWeight.bold : FontWeight.w500,
            color: isAmount
                ? TColors.primary
                : (darkMode ? Colors.white : Colors.black),
          ),
        ),
      ],
    );
  }
}