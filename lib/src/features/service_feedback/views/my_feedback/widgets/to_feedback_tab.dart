import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../controllers/my_feedback/my_feedback_controller.dart';
import '../my_feedback.dart';

class ToFeedbackTab extends StatelessWidget {
  const ToFeedbackTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MyServiceFeedbackController>();

    return RefreshIndicator(
      onRefresh: controller.refreshCurrentTab,
      color: TColors.primary,
      child: Obx(() {
        if (controller.isLoadingToFeedback.value) {
          return LoadingStateWidget(message: 'Loading feedback...');
        }

        if (controller.hasError.value) {
          return ErrorStateWidget(
            title: 'Connection Error',
            message: controller.errorMessage.value,
            onRetry: controller.retryLoading,
          );
        }

        if (controller.toFeedbackList.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.task_alt_rounded,
            title: 'All Caught Up! 🎉',
            message: 'You have no services awaiting feedback.\nCompleted services will appear here within 7 days.',
            iconColor: TColors.success,
          );
        }

        return ListView.separated(
          padding: EdgeInsets.all(16),
          itemCount: controller.toFeedbackList.length,
          separatorBuilder: (context, index) => SizedBox(height: 16),
          itemBuilder: (context, index) {
            final feedback = controller.toFeedbackList[index];
            return ToFeedbackCard(feedback: feedback);
          },
        );
      }),
    );
  }
}