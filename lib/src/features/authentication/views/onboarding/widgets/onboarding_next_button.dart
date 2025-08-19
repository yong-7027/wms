import 'package:flutter/material.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/device/device_utility.dart';
import '../../../controllers/onboarding_controller.dart';

class OnBoardingNextButton extends StatelessWidget {
  const OnBoardingNextButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      // 相对于 stack 绝对定位
      bottom: TDeviceUtils.getBottomNavigationBarHeight() + 50.0,
      child: OutlinedButton(
        onPressed: () => OnBoardingController.instance.nextPage(),
        style: ElevatedButton.styleFrom(
          side: const BorderSide(color: TColors.black),
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(20.0),
          foregroundColor: TColors.white,
        ),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: const BoxDecoration(
            color: TColors.black,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.arrow_forward_ios,
            color: TColors.white,
          ),
        ),
      ),
    );
  }
}
