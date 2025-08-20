import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../controllers/payment_controller.dart';

class PaymentMethodScreen extends StatelessWidget {
  const PaymentMethodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PaymentController());
    final darkMode = THelperFunctions.isDarkMode(context);

    final paymentMethods = [
      {
        'id': 'stripe',
        'name': 'Pay via Stripe',
        'icon': 'assets/icons/stripe.png',
        'subtitle': 'Credit/Debit cards, Apple Pay, Google Pay',
      },
      {
        'id': 'paypal',
        'name': 'Pay via PayPal',
        'icon': 'assets/icons/paypal.png',
        'subtitle': 'Safe & secure payment',
      },
      {
        'id': 'razorpay',
        'name': 'Pay online',
        'icon': 'assets/icons/razorpay.png',
        'subtitle': 'Multiple payment options',
      },
    ];

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
          'Choose payment method',
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
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Select Payment Method',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select the payment method which you want to use',
              style: TextStyle(
                fontSize: 16,
                color: darkMode ? Colors.grey[400] : Colors.grey[600],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),

            // Selected Plan Summary
            Obx(() {
              final selectedPlan = controller.selectedPlan.value;
              if (selectedPlan.planId.isEmpty) return const SizedBox();

              return Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: TColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: TColors.primary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: TColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Iconsax.crown_1_bold,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedPlan.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${selectedPlan.formattedPrice}/${selectedPlan.displayDuration}',
                            style: TextStyle(
                              fontSize: 14,
                              color: darkMode ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      selectedPlan.formattedPrice,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: TColors.primary,
                      ),
                    ),
                  ],
                ),
              );
            }),

            // Payment Methods
            Expanded(
              child: ListView.builder(
                itemCount: paymentMethods.length,
                itemBuilder: (context, index) {
                  final method = paymentMethods[index];
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 200 + (index * 100)),
                    curve: Curves.easeOutCubic,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: _PaymentMethodCard(
                      id: method['id']!,
                      name: method['name']!,
                      subtitle: method['subtitle']!,
                      iconPath: method['icon']!,
                      darkMode: darkMode,
                      controller: controller,
                    ),
                  );
                },
              ),
            ),

            // Confirm Payment Button
            Obx(() => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: controller.selectedPaymentMethod.value.isNotEmpty &&
                    !controller.isProcessingPayment.value
                    ? controller.confirmPayment
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  disabledBackgroundColor: darkMode ? Colors.grey[800] : Colors.grey[200],
                ),
                child: controller.isProcessingPayment.value
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(TColors.primary),
                  ),
                )
                    : const Text(
                  'Confirm payment',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _PaymentMethodCard extends StatefulWidget {
  final String id;
  final String name;
  final String subtitle;
  final String iconPath;
  final bool darkMode;
  final PaymentController controller;

  const _PaymentMethodCard({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.iconPath,
    required this.darkMode,
    required this.controller,
  });

  @override
  State<_PaymentMethodCard> createState() => _PaymentMethodCardState();
}

class _PaymentMethodCardState extends State<_PaymentMethodCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _getPaymentIcon(String id) {
    switch (id) {
      case 'stripe':
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF635BFF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Iconsax.card_bold,
            color: Color(0xFF635BFF),
            size: 24,
          ),
        );
      case 'paypal':
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF00457C).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Iconsax.wallet_2_bold,
            color: Color(0xFF00457C),
            size: 24,
          ),
        );
      case 'razorpay':
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF528FF0).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Iconsax.money_2_bold,
            color: Color(0xFF528FF0),
            size: 24,
          ),
        );
      default:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: TColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Iconsax.card_bold,
            color: TColors.primary,
            size: 24,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSelected = widget.controller.selectedPaymentMethod.value == widget.id;
      final isProcessing = widget.controller.isProcessingPayment.value;

      return GestureDetector(
        onTapDown: (_) => !isProcessing ? _animationController.forward() : null,
        onTapUp: (_) {
          if (!isProcessing) {
            _animationController.reverse();
            widget.controller.selectPaymentMethod(widget.id);
          }
        },
        onTapCancel: () => _animationController.reverse(),
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isSelected
                      ? TColors.primary.withOpacity(0.05)
                      : (widget.darkMode ? Colors.grey[900] : Colors.grey[50]),
                  border: Border.all(
                    color: isSelected
                        ? TColors.primary
                        : (widget.darkMode ? Colors.grey[800]! : Colors.grey[200]!),
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isSelected
                      ? [
                    BoxShadow(
                      color: TColors.primary.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ]
                      : [],
                ),
                child: Opacity(
                  opacity: isProcessing ? 0.6 : 1.0,
                  child: Row(
                    children: [
                      _getPaymentIcon(widget.id),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: widget.darkMode ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.subtitle,
                              style: TextStyle(
                                fontSize: 14,
                                color: widget.darkMode ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? TColors.primary
                              : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? TColors.primary
                                : (widget.darkMode ? Colors.grey[600]! : Colors.grey[400]!),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.check,
                          color: isSelected
                              ? Colors.white
                              : Colors.transparent,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }
}