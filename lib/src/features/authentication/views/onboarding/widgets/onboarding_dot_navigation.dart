import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/device/device_utility.dart';
import '../../../controllers/onboarding_controller.dart';

class OnBoardingDotNavigation extends StatelessWidget {
  OnBoardingDotNavigation({
    super.key,
  });

  final controller = OnBoardingController.instance;

  @override
  Widget build(BuildContext context) {

    return Positioned(
      bottom: TDeviceUtils.getBottomNavigationBarHeight(),
      child: Obx(() => AnimatedSmoothIndicator(
        activeIndex: controller.currentPageIndex.value, // 使用 .value 获取 Rx<int> 的值
        onDotClicked: controller.dotNavigationClick,
        count: 3,
        effect: WormEffect(
          activeDotColor: TColors.secondary,
          dotHeight: 5.0,
        ),
      )),
    );
  }
}
