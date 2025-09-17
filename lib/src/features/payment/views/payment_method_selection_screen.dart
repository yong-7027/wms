import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../controllers/invoice_controller.dart';
import '../controllers/payment_controller.dart';

class PaymentMethodScreen extends StatelessWidget {
  final String invoiceId;

  const PaymentMethodScreen({super.key, required this.invoiceId});

  @override
  Widget build(BuildContext context) {
    final paymentController = Get.put(PaymentController());
    final invoiceController = Get.put(InvoiceController());
    final darkMode = THelperFunctions.isDarkMode(context);

    // Load invoice details and set it in payment controller
    invoiceController.loadInvoiceDetails(invoiceId);

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

            // Invoice Summary
            Obx(() {
              final invoice = invoiceController.currentInvoice.value;
              if (invoice.invoiceId.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: darkMode ? TColors.darkContainer : TColors.lightContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(color: TColors.primary),
                  ),
                );
              }

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
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: TColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Iconsax.receipt_1_bold,
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
                                'Invoice #${invoice.invoiceId.substring(0, 8).toUpperCase()}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${invoice.items.length} item${invoice.items.length > 1 ? 's' : ''}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: darkMode ? Colors.grey[400] : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'RM${invoice.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: TColors.primary,
                          ),
                        ),
                      ],
                    ),

                    if (invoice.items.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Divider(color: TColors.primary, thickness: 0.5),
                      const SizedBox(height: 16),

                      // Show first few items
                      ...invoice.items.take(3).map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: item.type == 'service'
                                    ? Colors.blue.withOpacity(0.2)
                                    : Colors.orange.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Icon(
                                item.type == 'service' ? Iconsax.setting_2_bold : Iconsax.box_bold,
                                size: 12,
                                color: item.type == 'service' ? Colors.blue : Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.description,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: darkMode ? Colors.grey[300] : Colors.grey[700],
                                ),
                              ),
                            ),
                            Text(
                              'RM${item.itemTotal.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: darkMode ? Colors.grey[300] : Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      )),

                      if (invoice.items.length > 3)
                        Text(
                          '... and ${invoice.items.length - 3} more items',
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: darkMode ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                    ],
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
                      controller: paymentController,
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
                onPressed: paymentController.selectedPaymentMethod.value.isNotEmpty &&
                    !paymentController.isProcessingPayment.value &&
                    invoiceController.currentInvoice.value.invoiceId.isNotEmpty
                    ? () => paymentController.confirmInvoicePayment(invoiceId)
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
                child: paymentController.isProcessingPayment.value
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : Obx(() {
                  final invoice = invoiceController.currentInvoice.value;
                  return Text(
                    invoice.invoiceId.isNotEmpty
                        ? 'Pay RM${invoice.totalAmount.toStringAsFixed(2)}'
                        : 'Confirm payment',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }),
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