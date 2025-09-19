import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../controllers/my_feedback/my_feedback_controller.dart';
import '../my_feedback.dart';

class MyFeedbackTab extends StatelessWidget {
  const MyFeedbackTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MyServiceFeedbackController>();

    return RefreshIndicator(
      onRefresh: controller.refreshCurrentTab,
      color: TColors.primary,
      child: Obx(() {
        if (controller.isLoadingMyFeedback.value) {
          return LoadingStateWidget(message: 'Loading your feedback...');
        }

        if (controller.myFeedbackList.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.rate_review_outlined,
            title: 'No Reviews Yet',
            message: 'Your submitted feedback will appear here.\nStart by providing feedback for your services.',
            iconColor: TColors.primary,
          );
        }

        return Column(
          children: [
            // Edit rules info
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: TColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: TColors.info.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: TColors.info.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.info_outline,
                      size: 20,
                      color: TColors.info,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'You can edit your feedback within 24 hours of submission, but only once.',
                      style: TextStyle(
                        fontSize: 14,
                        color: TColors.info,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Feedback list
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.myFeedbackList.length,
                separatorBuilder: (context, index) => SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final feedback = controller.myFeedbackList[index];
                  return MyFeedbackCard(feedback: feedback);
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}