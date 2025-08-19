import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';

import '../../utils/constants/colors.dart';
import '../../utils/constants/sizes.dart';
import '../../utils/helpers/helper_functions.dart';

class TLoaders {
  TLoaders._();
  
  static hideSnackBar() => ScaffoldMessenger.of(Get.context!).hideCurrentSnackBar();

  static customToast({required message}) {
    ScaffoldMessenger.of(Get.context!).showSnackBar(
      SnackBar(
        elevation: 0,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.transparent,
        content: Container(
          padding: const EdgeInsets.all(12.0),
          margin: const EdgeInsets.symmetric(horizontal: 30),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: THelperFunctions.isDarkMode(Get.context!) ? TColors.darkGrey.withValues(alpha: 0.9) : TColors.grey.withValues(alpha: 0.9),
          ),
          child: Center(
            child: Text(message, style: Theme.of(Get.context!).textTheme.labelLarge,),
          ),
        ),
      ),
    );
  }

  /* -- SNACK-BARS -- */
  // successSnackBar
  static successSnackBar({required title, message = ''}) {
    Get.snackbar(
      title,
      message,
      isDismissible: true,
      shouldIconPulse: true,
      colorText: TColors.white,
      backgroundColor: TColors.success,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 5),
      margin: const EdgeInsets.all(TSizes.defaultSpace - 10),
      icon: const Icon(
        Iconsax.check_bold,
        color: TColors.white,
      ),
    );
  }

  // warningSnackBar
  static warningSnackBar({required title, message = ''}) {
    Get.snackbar(
      title,
      message,
      isDismissible: true,
      shouldIconPulse: true,
      colorText: TColors.white,
      backgroundColor: TColors.warning,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 5),
      margin: const EdgeInsets.all(TSizes.defaultSpace - 10),
      icon: const Icon(
        Iconsax.warning_2_bold,
        color: TColors.white,
      ),
    );
  }

  // errorSnackBar
  static errorSnackBar({required title, message = ''}) {
    Get.snackbar(
      title,
      message,
      isDismissible: true,
      shouldIconPulse: true,
      colorText: TColors.white,
      backgroundColor: TColors.error,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 5),
      margin: const EdgeInsets.all(TSizes.defaultSpace - 10),
      icon: const Icon(
        Iconsax.warning_2_bold,
        color: TColors.white,
      ),
    );
  }

  // modernSnackBar
  static modernSnackBar({required title, message = ''}) {
    Get.snackbar(
      title,
      message,
      isDismissible: true,
      shouldIconPulse: true,
      colorText: TColors.white,
      backgroundColor: TColors.info,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 5),
      margin: const EdgeInsets.all(TSizes.defaultSpace - 10),
      icon: const Icon(
        Icons.info,
        color: TColors.white,
      ),
    );
  }
}
