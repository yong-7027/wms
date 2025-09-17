import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'src/bindings/general_bindings.dart';
import 'src/features/authentication/views/onboarding/onboarding.dart';
import 'src/features/payment/views/invoice_detail_screen.dart';
import 'src/features/payment/views/payment_history_screen.dart';
import 'src/features/payment/views/payment_method_selection_screen.dart';
import 'src/utils/theme/theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: TAppTheme.lightTheme,
      darkTheme: TAppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialBinding: GeneralBindings(),
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 500),
      home: InvoiceDetailScreen(invoiceId: 'mqNUHuRdE3aCjKZYOouf'),
    );
  }
}
