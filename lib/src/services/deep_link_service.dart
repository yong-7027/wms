import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:get/get.dart';

import '../features/payment/controllers/payment_controller.dart';
import '../features/payment/views/invoice_detail_screen.dart';

class DeepLinkService extends GetxService {
  static DeepLinkService get instance => Get.find();

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri?>? _linkSubscription;

  final RxString currentDeepLink = ''.obs;
  final RxBool isProcessingDeepLink = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeDeepLinkListener();
    _getInitialAppLink();
  }

  @override
  void onClose() {
    _linkSubscription?.cancel();
    super.onClose();
  }

  /// 初始化Deep Link监听器
  void _initializeDeepLinkListener() {
    _linkSubscription = _appLinks.uriLinkStream.listen(
          (Uri? uri) {
        if (uri != null) {
          _processDeepLink(uri);
        }
      },
      onError: (err) {
        print('Deep link error: $err');
      },
    );
  }

  /// 获取初始深度链接（冷启动/热启动）
  Future<void> _getInitialAppLink() async {
    try {
      final Uri? initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _processDeepLink(initialUri);
      }
    } catch (e) {
      print('Failed to get initial app link: $e');
    }
  }

  /// 统一处理所有 deep link
  Future<void> _processDeepLink(Uri uri) async {
    try {
      isProcessingDeepLink.value = true;
      currentDeepLink.value = uri.toString();

      print('Processing deep link: ${uri.toString()}');
      print('Scheme: ${uri.scheme}, Host: ${uri.host}, Path: ${uri.path}');

      // 处理 wms scheme
      if (uri.scheme == 'wms') {
        await _handleWmsScheme(uri);
      }
      // 处理包名 scheme
      else if (uri.scheme == 'com.example.wms') {
        await _handlePackageScheme(uri);
      }
      // 处理其他 scheme（如 http/https）
      else {
        print('Unhandled scheme: ${uri.scheme}');
      }

    } catch (e) {
      print('Error processing deep link: $e');
      Get.snackbar(
        'Error',
        'Failed to process link: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isProcessingDeepLink.value = false;
    }
  }

  /// 处理 wms:// 开头的 deep link
  Future<void> _handleWmsScheme(Uri uri) async {
    switch (uri.host) {
      case 'payment':
        await _handlePaymentDeepLink(uri);
        break;
      case 'invoice':
        await _handleInvoiceDeepLink(uri);
        break;
      default:
        print('Unknown wms host: ${uri.host}');
    }
  }

  /// 处理包名 scheme 的 deep link
  Future<void> _handlePackageScheme(Uri uri) async {
    final pathSegments = uri.pathSegments;
    if (pathSegments.isEmpty) return;

    switch (pathSegments[0]) {
      case 'invoice':
        await _handleInvoicePackageLink(uri);
        break;
      default:
        print('Unknown package scheme path: ${pathSegments[0]}');
    }
  }

  /// 处理 wms://invoice/ 开头的链接
  Future<void> _handleInvoiceDeepLink(Uri uri) async {
    final pathSegments = uri.pathSegments;
    if (pathSegments.isEmpty) {
      throw Exception('No invoice ID provided');
    }

    final invoiceId = pathSegments.first;
    print('Navigating to invoice: $invoiceId');

    // 导航到发票详情页面
    Get.to(() => InvoiceDetailScreen(invoiceId: invoiceId,));
  }

  /// 处理 com.example.wms://invoice/ 开头的链接
  Future<void> _handleInvoicePackageLink(Uri uri) async {
    final pathSegments = uri.pathSegments;
    if (pathSegments.length < 2) {
      throw Exception('Invalid invoice package link');
    }

    final invoiceId = pathSegments[1];
    print('Navigating to invoice via package link: $invoiceId');

    // 导航到发票详情页面
    Get.to(() => InvoiceDetailScreen(invoiceId: invoiceId,));
  }

  /// 处理支付相关的 deep link
  Future<void> _handlePaymentDeepLink(Uri uri) async {
    final pathSegments = uri.pathSegments;
    if (pathSegments.isEmpty) return;

    switch (pathSegments.first) {
      case 'paypal-success':
        await _handlePayPalSuccess(uri);
        break;
      case 'paypal-cancel':
        await _handlePayPalCancel(uri);
        break;
      default:
        print('Unknown payment path: ${pathSegments.first}');
    }
  }

  /// 处理 PayPal 成功回调
  Future<void> _handlePayPalSuccess(Uri uri) async {
    print('Handling PayPal success callback');

    try {
      final paymentController = Get.find<PaymentController>();
      paymentController.handlePayPalDeepLinkSuccess(uri);
    } catch (e) {
      print('Payment controller not available: $e');
      // 可以在这里存储 deep link 数据，等 PaymentController 初始化后再处理
      _storePendingDeepLink(uri);
    }
  }

  /// 处理 PayPal 取消回调
  Future<void> _handlePayPalCancel(Uri uri) async {
    print('Handling PayPal cancel callback');

    try {
      final paymentController = Get.find<PaymentController>();
      paymentController.handlePayPalDeepLinkCancel(uri);
    } catch (e) {
      print('Payment controller not available: $e');
    }
  }

  /// 存储待处理的 deep link（用于控制器尚未初始化的情况）
  void _storePendingDeepLink(Uri uri) {
    // 可以实现将 deep link 数据存储到本地，等相应的 controller 初始化后再处理
    print('Storing pending deep link: $uri');
  }
}