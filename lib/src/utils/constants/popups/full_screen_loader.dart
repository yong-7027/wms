import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/loaders/animation_loader.dart';
import '../../helpers/helper_functions.dart';
import '../colors.dart';

class TFullScreenLoader {
  static void openLoadingDialog(String text, String animation) {
    showDialog(
        context: Get.overlayContext!,  // Use Get.overlayContext for overlay dialogs
        barrierDismissible: false,  // The dialogs can't be dismissed by tapping outside it
        builder: (_) => PopScope(
          canPop: false,  // Disable popping with the back button
          child: Container(
            color: THelperFunctions.isDarkMode(Get.context!) ? TColors.dark : TColors.white,
            width: double.infinity,
            height: double.infinity,
            child: Column(
              children: [
                const SizedBox(height: 250,),
                TAnimationLoaderWidget(text: text, animation: animation),
              ],
            ),
          ),
        )
    );
  }

  /// Stop the currently open loading dialogs
  /// This method doesn't return anything
  static stopLoading() {
    Navigator.of(Get.overlayContext!).pop();  // Close the dialogs using the navigator
  }
}