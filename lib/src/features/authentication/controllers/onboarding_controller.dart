import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:liquid_swipe/liquid_swipe.dart';

class OnBoardingController extends GetxController {
  static OnBoardingController get instance => Get.find();

  /// Variables
  final pageController = LiquidController();
  Rx<int> currentPageIndex = 0.obs;

  /// Update Current Index when Page Scroll
  void updatePageIndicator(int index) => currentPageIndex.value = index;

  /// Jump to the specific got selected page
  void dotNavigationClick(int index) {
    currentPageIndex.value = index;
    pageController.animateToPage(page: index);
  }

  /// Update Current Index & Jump to Next Page
  void nextPage() {
    if (currentPageIndex.value == 2) {
      final storage = GetStorage();
      storage.write('IsFirstTime', false);

      // Get.offAll(() => const LoginScreen());
    }
    else {
      int page = currentPageIndex.value + 1;
      pageController.animateToPage(page: page);
    }
  }

  /// Update Current Index & Jump to the Last Page
  void skipPage() {
    currentPageIndex.value = 2;
    pageController.jumpToPage(page: 2);
  }
}