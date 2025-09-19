import 'dart:convert';
import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../../common/loaders/loaders.dart';
import '../../../data/repository/payment/payment_repository.dart';
import '../../../utils/helpers/export_helper.dart';
import '../models/invoice_model.dart';
import '../models/payment_transaction_model.dart';
import '../views/invoice_payment_success_screen.dart';
import 'invoice_controller.dart';

class PaymentController extends GetxController {
  static PaymentController get instance => Get.find();
  final paymentRepo = Get.put(PaymentRepository());
  final invoiceController = Get.put(InvoiceController());

  // Observable variables
  final RxString selectedPaymentMethod = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isProcessingPayment = false.obs;

  // 支付状态追踪
  final RxString paymentStatus = ''.obs;
  final RxString currentPaymentIntentId = ''.obs;
  final RxString currentPayPalOrderId = ''.obs;
  final RxString currentInvoiceId = ''.obs;

  // Deep Link 监听
  // final AppLinks _appLinks = AppLinks();
  // StreamSubscription<Uri?>? _linkSubscription;

  static const String baseUrl = 'https://api-lk2drcb6aa-uc.a.run.app';
  static const String createPaymentIntentUrl = '$baseUrl/createPaymentIntent';
  static const String verifyPaymentUrl = '$baseUrl/verifyPayment';
  static const String createPayPalOrderUrl = '$baseUrl/createPayPalOrder';
  static const String capturePayPalOrderUrl = '$baseUrl/capturePayPalOrder';
  static const String verifyPayPalPaymentUrl = '$baseUrl/verifyPayPalPayment';

  @override
  void onInit() {
    super.onInit();
    // _initializeDeepLinkListener();
    // _getInitialAppLink();
  }

  // @override
  // void onClose() {
  //   _linkSubscription?.cancel();
  //   super.onClose();
  // }

  /// 获取初始深度链接（冷启动/热启动）
  // Future<void> _getInitialAppLink() async {
  //   try {
  //     final Uri? initialUri = await _appLinks.getInitialLink();
  //     if (initialUri != null) {
  //       _handleDeepLink(initialUri);
  //     }
  //   } catch (e) {
  //     print('Failed to get initial app link: $e');
  //   }
  // }

  /// 初始化Deep Link监听器（使用 app_links）
  // void _initializeDeepLinkListener() {
  //   _linkSubscription = _appLinks.uriLinkStream.listen(
  //         (Uri? uri) {
  //       if (uri != null) {
  //         _handleDeepLink(uri);
  //       }
  //     },
  //     onError: (err) {
  //       print('Deep link error: $err');
  //     },
  //   );
  // }

  /// 处理深度链接
  // void _handleDeepLink(Uri uri) {
  //   print('Received deep link: ${uri.toString()}');
  //   print('Scheme: ${uri.scheme}, Host: ${uri.host}, Path: ${uri.path}');
  //
  //   if (uri.scheme == 'wms' && uri.host == 'payment') {
  //     if (uri.pathSegments.isNotEmpty) {
  //       switch (uri.pathSegments.first) {
  //         case 'paypal-success':
  //           _handlePayPalDeepLinkSuccess(uri);
  //           break;
  //         case 'paypal-cancel':
  //           _handlePayPalDeepLinkCancel(uri);
  //           break;
  //       }
  //     }
  //   }
  // }

  /// 处理PayPal成功回调
  void handlePayPalDeepLinkSuccess(Uri uri) async {
    try {
      final userId = uri.queryParameters['userId'];
      final invoiceId = uri.queryParameters['invoiceId'];
      final amountStr = uri.queryParameters['amount'];

      if (userId == null || invoiceId == null || amountStr == null) {
        throw Exception('Missing required parameters from PayPal callback');
      }

      final amount = double.tryParse(amountStr);
      if (amount == null) {
        throw Exception('Invalid amount from PayPal callback');
      }

      paymentStatus.value = 'Processing PayPal payment...';
      isProcessingPayment.value = true;

      // 1. 先捕获PayPal支付
      final captureResult = await _capturePayPalPayment(
          currentPayPalOrderId.value);

      if (captureResult == null || captureResult['status'] != 'COMPLETED') {
        throw Exception('PayPal payment capture failed');
      }

      final captureId = captureResult['captureId'];
      if (captureId == null) {
        throw Exception('No capture ID received from PayPal');
      }

      // 2. 检查支付记录是否已存在（防止重复处理）
      final paymentExists = await paymentRepo.paymentExists(captureId);
      if (paymentExists) {
        print('Payment already processed: $captureId');
        _navigateToExistingPaymentSuccess(captureId, invoiceId);
        return;
      }

      // 3. 处理支付成功
      await _handleInvoicePaymentSuccess(captureId, invoiceId);
    } catch (e) {
      _handlePaymentError('PayPal callback error: $e');
    } finally {
      isProcessingPayment.value = false;
    }
  }

  /// 导航到已存在的支付成功页面
  void _navigateToExistingPaymentSuccess(String transactionId,
      String invoiceId) async {
    try {
      final existingPayment = await paymentRepo.fetchPaymentByIntent(
          transactionId);
      final invoice = await invoiceController.getInvoiceById(invoiceId);

      if (existingPayment != null && invoice != null) {
        Get.snackbar(
          'Payment Already Processed',
          'This payment has already been processed',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue[100],
          colorText: Colors.blue[800],
        );

        Get.to(() =>
            InvoicePaymentSuccessScreen(
              transaction: existingPayment,
              invoice: invoice,
            ));
      } else {
        throw Exception('Payment or invoice record not found');
      }
    } catch (e) {
      _handlePaymentError('Error loading existing payment: $e');
    }
  }

  /// 捕获PayPal支付
  Future<Map<String, dynamic>?> _capturePayPalPayment(String orderId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      final idToken = await user.getIdToken();

      final response = await http.post(
        Uri.parse(capturePayPalOrderUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: json.encode({'orderId': orderId}),
      );

      print(
          'PayPal capture response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'PayPal capture failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error capturing PayPal payment: $e');
      return null;
    }
  }

  /// 处理PayPal取消回调
  void handlePayPalDeepLinkCancel(Uri uri) {
    paymentStatus.value = 'PayPal payment cancelled';
    isProcessingPayment.value = false;

    Get.snackbar(
      'Payment Cancelled',
      'You have cancelled the PayPal payment',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange[100],
      colorText: Colors.orange[800],
    );

    // 回到支付方式选择页面或发票详情页面
    Get.back();
  }

  /// Select payment method
  void selectPaymentMethod(String method) {
    selectedPaymentMethod.value = method;
  }

  /// Confirm invoice payment
  Future<void> confirmInvoicePayment(String invoiceId) async {
    if (selectedPaymentMethod.value.isEmpty) {
      Get.snackbar('Error', 'Please select a payment method');
      return;
    }

    currentInvoiceId.value = invoiceId;

    switch (selectedPaymentMethod.value) {
      case 'stripe':
        await _processStripeInvoicePayment(invoiceId);
        break;
      case 'paypal':
        await _processPayPalInvoicePayment(invoiceId);
        break;
      case 'razorpay':
        _processRazorPayInvoicePayment(invoiceId);
        break;
      default:
        Get.snackbar('Error', 'Invalid payment method selected');
    }
  }

  /// Process Stripe Invoice Payment
  Future<void> _processStripeInvoicePayment(String invoiceId) async {
    try {
      isProcessingPayment.value = true;
      paymentStatus.value = 'Creating payment intent...';

      final invoice = await invoiceController.getInvoiceById(invoiceId);
      if (invoice == null) {
        throw Exception('Invoice not found');
      }

      // Step 1: Create payment intent on your backend
      final paymentIntent = await _createInvoicePaymentIntent(invoice);

      if (paymentIntent == null) {
        throw Exception('Failed to create payment intent');
      }

      print("Payment Intent: $paymentIntent");
      currentPaymentIntentId.value = paymentIntent['id'];
      paymentStatus.value = 'Initializing payment sheet...';

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
          googlePay: const PaymentSheetGooglePay(
            merchantCountryCode: 'MY', // 商户所在国家代码，例如马来西亚是'MY'
            currencyCode: 'MYR',       // 交易的货币代码
            testEnv: true, // 测试环境
          ),
        ),
      );

      paymentStatus.value = 'Presenting payment sheet...';

      // Step 3: Present the payment sheet
      await Stripe.instance.presentPaymentSheet();

      // Step 4: 支付界面完成后，验证支付状态
      paymentStatus.value = 'Verifying payment...';
      await _verifyInvoicePaymentStatus(paymentIntent['id'], invoiceId);
    } catch (e) {
      // 检查是否是用户取消
      if (e.toString().contains('canceled') ||
          e.toString().contains('cancelled')) {
        paymentStatus.value = 'Payment cancelled by user';
        Get.snackbar(
          'Payment Cancelled',
          'You have cancelled the payment process',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange[100],
          colorText: Colors.orange[800],
        );
      } else {
        _handlePaymentError(e.toString());
      }
    } finally {
      isProcessingPayment.value = false;
    }
  }

  /// 验证发票支付状态
  Future<void> _verifyInvoicePaymentStatus(String paymentIntentId,
      String invoiceId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      final idToken = await user.getIdToken();

      final response = await http.post(
        Uri.parse(verifyPaymentUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: json.encode({
          'paymentIntentId': paymentIntentId,
          'invoiceId': invoiceId,
        }),
      );

      print(
          'Verify payment response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        final status = result['status'];

        if (status == 'succeeded') {
          await _handleInvoicePaymentSuccess(paymentIntentId, invoiceId);
        } else if (status == 'requires_payment_method') {
          throw Exception('Payment requires a valid payment method');
        } else if (status == 'canceled') {
          throw Exception('Payment was canceled');
        } else {
          // 支付可能还在处理中，等待 webhook
          paymentStatus.value = 'Payment processing...';
          await _waitForWebhookConfirmation(paymentIntentId, invoiceId);
        }
      } else {
        throw Exception('Failed to verify payment status');
      }
    } catch (e) {
      print('Error verifying payment: $e');
      // 即使验证失败，也可能支付已经成功，让 webhook 处理
      Get.snackbar(
        'Payment Status',
        'Payment submitted. We\'ll confirm the status shortly.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue[100],
        colorText: Colors.blue[800],
      );
    }
  }

  /// 等待 webhook 确认
  Future<void> _waitForWebhookConfirmation(String paymentIntentId,
      String invoiceId) async {
    // 这里可以实现轮询逻辑或者使用 Firebase Realtime Database/Firestore 监听
    // 暂时显示处理中状态
    await Future.delayed(Duration(seconds: 3));

    // 假设支付成功（实际应该从数据库验证）
    await _handleInvoicePaymentSuccess(paymentIntentId, invoiceId);
  }

  /// Create Payment Intent for Invoice
  Future<Map<String, dynamic>?> _createInvoicePaymentIntent(
      InvoiceModel invoice) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('User not logged in');
      }

      final idToken = await user.getIdToken();

      final response = await http.post(
        Uri.parse(createPaymentIntentUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: json.encode({
          'amount': (invoice.totalAmount * 100).toInt(), // Amount in cents
          'currency': 'myr',
          'invoiceId': invoice.invoiceId,
          'description': 'Invoice #${invoice.invoiceId.substring(0, 8)
              .toUpperCase()}',
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create payment intent: ${response
            .statusCode} - ${response.body}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to initialize payment: $e');
      return null;
    }
  }

  /// Handle Invoice Payment Success
  Future<void> _handleInvoicePaymentSuccess(String paymentIntentId,
      String invoiceId) async {
    try {
      paymentStatus.value = 'Payment successful!';

      // Get invoice details
      final invoice = await invoiceController.getInvoiceById(invoiceId);
      if (invoice == null) {
        throw Exception('Invoice not found');
      }

      // Create transaction record
      final transaction = PaymentTransactionModel(
        transactionId: paymentIntentId,
        invoiceId: invoiceId,
        amount: invoice.totalAmount,
        currency: 'MYR',
        paymentMethod: selectedPaymentMethod.value,
        transactionDateTime: DateTime.now(),
        status: 'success',
      );

      // Save transaction to database
      final transactionId = await paymentRepo.makeInvoicePayment(
          transaction: transaction,
          invoiceId: invoiceId
      );

      if (transactionId == null) {
        throw Exception('Failed to create payment record');
      }

      // Mark invoice as paid
      await invoiceController.markInvoiceAsPaid(invoiceId);

      // 显示成功消息
      Get.snackbar(
        'Payment Successful',
        'Your invoice payment has been processed successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
        duration: Duration(seconds: 3),
      );

      // Navigate to success page
      Get.to(() =>
          InvoicePaymentSuccessScreen(
              transaction: transaction,
              invoice: invoice
          ));
    } catch (e) {
      print('Error handling payment success: $e');
      Get.snackbar('Error', 'Payment completed but failed to save record: $e');
    }
  }

  /// Handle Payment Error
  void _handlePaymentError(String error) {
    String errorMessage = 'Payment failed';
    Color backgroundColor = Colors.red[100]!;
    Color textColor = Colors.red[800]!;

    if (error.contains('canceled') || error.contains('cancelled')) {
      errorMessage = 'Payment was canceled by user';
      backgroundColor = Colors.orange[100]!;
      textColor = Colors.orange[800]!;
    } else if (error.contains('failed')) {
      errorMessage = 'Payment failed. Please try again';
    } else if (error.contains('requires_payment_method')) {
      errorMessage = 'Please select a valid payment method';
    } else if (error.contains('network')) {
      errorMessage = 'Network error. Please check your connection';
    }

    paymentStatus.value = errorMessage;

    Get.snackbar(
      'Payment Error',
      errorMessage,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: backgroundColor,
      colorText: textColor,
      duration: Duration(seconds: 5),
    );
  }

  /// Process PayPal Invoice Payment
  Future<void> _processPayPalInvoicePayment(String invoiceId) async {
    try {
      isProcessingPayment.value = true;
      paymentStatus.value = 'Creating PayPal order...';

      final invoice = await invoiceController.getInvoiceById(invoiceId);
      if (invoice == null) {
        throw Exception('Invoice not found');
      }

      // Step 1: Create PayPal order
      final orderData = await _createPayPalInvoiceOrder(invoice);
      if (orderData == null) {
        throw Exception('Failed to create PayPal order');
      }

      currentPayPalOrderId.value = orderData['id'];
      final approvalUrl = orderData['approval_url'];

      if (approvalUrl == null) {
        throw Exception('No approval URL received from PayPal');
      }

      paymentStatus.value = 'Redirecting to PayPal...';

      // Step 2: Launch PayPal approval URL
      final Uri paypalUri = Uri.parse(approvalUrl);

      if (await canLaunchUrl(paypalUri)) {
        final result = await launchUrl(
          paypalUri,
          mode: LaunchMode.externalApplication,
        );

        if (!result) {
          throw Exception('Failed to launch PayPal');
        }
      } else {
        throw Exception('Cannot launch PayPal URL');
      }
    } catch (e) {
      if (e.toString().contains('canceled') ||
          e.toString().contains('cancelled')) {
        paymentStatus.value = 'PayPal payment cancelled by user';
        Get.snackbar(
          'Payment Cancelled',
          'You have cancelled the PayPal payment',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange[100],
          colorText: Colors.orange[800],
        );
      } else {
        _handlePaymentError(e.toString());
      }
      isProcessingPayment.value = false;
    }
  }

  /// Create PayPal Order for Invoice
  Future<Map<String, dynamic>?> _createPayPalInvoiceOrder(
      InvoiceModel invoice) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      final idToken = await user.getIdToken();

      final response = await http.post(
        Uri.parse(createPayPalOrderUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: json.encode({
          'amount': invoice.totalAmount,
          'currency': 'myr',
          'invoiceId': invoice.invoiceId,
          'description': 'Invoice #${invoice.invoiceId.substring(0, 8)
              .toUpperCase()}',
        }),
      );

      print('PayPal order response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Failed to create PayPal order: ${response.statusCode} - ${response
                .body}');
      }
    } catch (e) {
      print('Error in _createPayPalInvoiceOrder: $e');
      Get.snackbar('Error', 'Failed to initialize PayPal payment: $e');
      return null;
    }
  }

  /// Process RazorPay Invoice Payment (placeholder)
  void _processRazorPayInvoicePayment(String invoiceId) {
    Get.snackbar('Info', 'RazorPay integration coming soon');
  }

  /// 重置支付状态
  void resetPaymentStatus() {
    paymentStatus.value = '';
    currentPaymentIntentId.value = '';
    currentPayPalOrderId.value = '';
    currentInvoiceId.value = '';
    selectedPaymentMethod.value = '';
    isProcessingPayment.value = false;
  }

  /// 获取当前支付状态
  String getCurrentPaymentStatus() {
    return paymentStatus.value;
  }

  Future<void> downloadReceipt(PaymentTransactionModel transaction, InvoiceModel invoice) async {
    try {
      final receiptData = ReceiptData(
        invoice: invoice,
        transaction: transaction,
      );

      await ExportHelper.exportReceipt(receiptData: receiptData);
    } catch (e) {
      print('Error saving receipt: $e');
      TLoaders.errorSnackBar(
        title: 'Download Failed',
        message: 'Failed to download receipt: ${e.toString()}',
      );
    }
  }
}