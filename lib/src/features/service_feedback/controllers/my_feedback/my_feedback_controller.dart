import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/repository/service_feedback/service_feedback_repository.dart';
import '../../../../utils/constants/colors.dart';
import '../../models/service_feedback_model.dart';
import '../../views/make_feedback/make_service_feedback.dart';

class MyServiceFeedbackController extends GetxController
    with GetSingleTickerProviderStateMixin {
  StreamSubscription<List<ServiceFeedbackModel>>? _pendingFeedbackSubscription;
  StreamSubscription<List<ServiceFeedbackModel>>?
  _submittedFeedbackSubscription;

  late TabController tabController;

  // Dependencies
  final ServiceFeedbackRepository _feedbackRepository =
      ServiceFeedbackRepository();
  // final AuthenticationRepository _authRepository = AuthenticationRepository.instance;

  // Reactive variables
  final RxBool isLoadingToFeedback = false.obs;
  final RxBool isLoadingMyFeedback = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  final RxList<ServiceFeedbackModel> toFeedbackList =
      <ServiceFeedbackModel>[].obs;
  final RxList<ServiceFeedbackModel> myFeedbackList =
      <ServiceFeedbackModel>[].obs;
  final RxList<ServiceFeedbackModel> allFeedbacks =
      <ServiceFeedbackModel>[].obs;

  final RxMap<String, bool> _expandedStates = <String, bool>{}.obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    loadFeedbackData();
  }

  @override
  void onClose() {
    _pendingFeedbackSubscription?.cancel();
    _submittedFeedbackSubscription?.cancel();
    tabController.dispose();
    _expandedStates.clear();
    super.onClose();
  }

  /// Load all feedback data and filter into respective lists
  Future<void> loadFeedbackData() async {
    try {
      isLoadingToFeedback.value = true;
      isLoadingMyFeedback.value = true;
      hasError.value = false;

      final userId = '3ohlF9J881SuN5qzzL43L8JQ9ex1';

      // Cancel existing subscriptions
      _pendingFeedbackSubscription?.cancel();
      _submittedFeedbackSubscription?.cancel();

      // Load pending feedbacks with real-time updates
      _pendingFeedbackSubscription = _feedbackRepository
          .getPendingFeedbacks(userId)
          .listen(
            (feedbacks) {
              toFeedbackList.value = feedbacks;
              isLoadingToFeedback.value = false;
            },
            onError: (error) {
              hasError.value = true;
              errorMessage.value = 'Failed to load pending feedback data.';
              isLoadingToFeedback.value = false;
            },
          );

      // Load submitted/disabled feedbacks with real-time updates
      _submittedFeedbackSubscription = _feedbackRepository
          .getMySubmittedFeedbacks(userId)
          .listen(
            (feedbacks) {
              myFeedbackList.value = feedbacks;
              isLoadingMyFeedback.value = false;
            },
            onError: (error) {
              hasError.value = true;
              errorMessage.value = 'Failed to load submitted feedback data.';
              isLoadingMyFeedback.value = false;
            },
          );
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      isLoadingToFeedback.value = false;
      isLoadingMyFeedback.value = false;
    }
  }

  // 检查反馈是否展开
  bool isFeedbackExpanded(String feedbackId) {
    return _expandedStates[feedbackId] ?? false;
  }

  // 切换反馈卡片的展开状态
  void toggleFeedbackExpansion(String feedbackId) {
    final currentState = _expandedStates[feedbackId] ?? false;
    _expandedStates[feedbackId] = !currentState;
  }

  /// Get remaining time to provide feedback (7 days from creation)
  Duration getRemainingTimeToFeedback(DateTime? createdAt) {
    if (createdAt == null) return Duration.zero;

    final sevenDaysAfter = createdAt.add(const Duration(days: 7));
    final now = DateTime.now();

    if (now.isAfter(sevenDaysAfter)) {
      return Duration.zero;
    }

    return sevenDaysAfter.difference(now);
  }

  /// Check if feedback period has expired
  bool isFeedbackExpired(DateTime? createdAt) {
    return getRemainingTimeToFeedback(createdAt).inSeconds <= 0;
  }

  /// Check if user can provide feedback (within 7 days and has edit attempts remaining)
  bool canProvideFeedback(DateTime? createdAt, int editRemaining) {
    if (editRemaining == 0) return false; // 没有剩余编辑次数
    if (isFeedbackExpired(createdAt)) return false; // 超过7天反馈期

    return true;
  }

  /// Check if feedback can be edited (within 24 hours from last update and has edit attempts remaining)
  bool canBeEdited(DateTime? updatedAt, int editRemaining) {
    if (editRemaining == 0 || updatedAt == null) return false;

    final now = DateTime.now();
    final difference = now.difference(updatedAt);

    return difference.inHours < 24;
  }

  /// Get remaining time to edit (24 hours from last update)
  Duration getRemainingTimeToEdit(DateTime? updatedAt, int editRemaining) {
    if (updatedAt == null || editRemaining == 0) return Duration.zero;

    final twentyFourHoursAfter = updatedAt.add(const Duration(hours: 24));
    final now = DateTime.now();

    if (now.isAfter(twentyFourHoursAfter)) {
      return Duration.zero;
    }

    return twentyFourHoursAfter.difference(now);
  }

  /// Format remaining time display
  String formatRemainingTime(Duration duration) {
    if (duration.inSeconds <= 0) return 'Expired';

    if (duration.inDays > 0) {
      return '${duration.inDays} day${duration.inDays > 1 ? 's' : ''} left';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hour${duration.inHours > 1 ? 's' : ''} left';
    } else {
      return '${duration.inMinutes} minute${duration.inMinutes > 1 ? 's' : ''} left';
    }
  }

  /// Refresh current tab data
  Future<void> refreshCurrentTab() async {
    await loadFeedbackData();
  }

  /// Navigate to make feedback page
  void navigateToMakeFeedback(ServiceFeedbackModel feedback) {
    // Navigate to make feedback page
    Get.to(() => MakeServiceFeedbackScreen(feedback: feedback));
    // Get.toNamed('/make-feedback', arguments: feedback);
  }

  /// Navigate to edit feedback page
  void navigateToEditFeedback(ServiceFeedbackModel feedback) {
    if (canEditFeedback(feedback)) {
      Get.toNamed('/edit-feedback', arguments: feedback);
    }
  }

  bool canEditFeedback(ServiceFeedbackModel feedback) {
    return canBeEdited(feedback.updatedAt, feedback.editRemaining);
  }

  /// Navigate to feedback details
  void navigateToFeedbackDetails(ServiceFeedbackModel feedback) {
    Get.toNamed('/feedback-details', arguments: feedback);
  }

  /// Get feedback count for tab badges
  int get toFeedbackCount => toFeedbackList.length;
  int get myFeedbackCount => myFeedbackList.length;

  /// Retry loading data
  void retryLoading() {
    hasError.value = false;
    errorMessage.value = '';
    loadFeedbackData();
  }

  /// Get status color based on feedback status
  Color getStatusColor(FeedbackStatus status) {
    switch (status) {
      case FeedbackStatus.pending:
        return TColors.warning;
      case FeedbackStatus.submitted:
        return TColors.success;
      case FeedbackStatus.disabled:
        return TColors.error;
    }
  }

  /// Get rating color based on average rating
  Color getRatingColor(double averageRating) {
    if (averageRating >= 4.0) return TColors.success;
    if (averageRating >= 3.0) return TColors.warning;
    return TColors.error;
  }
}
