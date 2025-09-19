import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:printing/printing.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'src/features/notification/controllers/fcm_service.dart';
import 'src/features/payment/controllers/payment_controller.dart';
import 'src/services/deep_link_service.dart';

void main() async {
  /// Widgets Binding
  // final WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();

  /// -- GetX Local Storage
  await GetStorage.init();

  /// -- Initialize Stripe
  Stripe.publishableKey = 'pk_test_51RxrvGFLRUQjWHbT4A7B9QNPwDdjKCbYAOZgvVQqXKdZp1Wg4vWgjCQXfDAnSSZCqIwwsBrhBndCz6nPS9oER7gU00oHcguBrs';
  Stripe.urlScheme = 'com.example.wms'; // For redirects

  await Stripe.instance.applySettings();

  /// -- Await Splash until other items load
  // FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  /// -- Initialize Firebase & Authentication Repository
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: 'AIzaSyBHtC38Hsw1D4PQue0wI_EeVLL9RO4Njq0',
          appId: '1:688733753327:web:67ed7ecda5a21c1526f01a',
          messagingSenderId: '688733753327',
          projectId: 'workshop-management-syst-b9cec',
          authDomain: 'workshop-management-syst-b9cec.firebaseapp.com',
          storageBucket: 'workshop-management-syst-b9cec.firebasestorage.app',
        )
    );
  } else {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
        // .then((FirebaseApp value) => Get.put(AuthenticationRepository())); // Get.put() 会将 AuthenticationRepository 放入 GetX 的依赖注入系统中，确保可以在应用的任何地方访问到 AuthenticationRepository 实例
  }

  /// -- 登录固定账号
  final auth = FirebaseAuth.instance;
  try {
    const email = 'testuser@example.com';
    const password = '123456';

    // 尝试登录
    final userCredential = await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    print('Logged in as: ${userCredential.user?.email}');
  } on FirebaseAuthException catch (e) {
    print('Login failed: ${e.message}');
  }

  // FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(true);
  // await FirebaseAppCheck.instance.activate(
  //   androidProvider: AndroidProvider.debug,
  // );

  /// -- Initialize FCM
  final fcmService = FCMService();
  await fcmService.initialize();

  Get.put(PaymentController());

  runApp(const App());
}