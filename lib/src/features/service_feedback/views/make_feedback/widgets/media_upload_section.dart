import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/service_feedback_controller.dart';
import '../../make_feedback/make_service_feedback.dart';

class MediaUploadSection extends StatelessWidget {
  const MediaUploadSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ServiceFeedbackController>();

    return Container(
      padding: EdgeInsets.all(16),
      // decoration: BoxDecoration(
      //   color: Colors.white,
      //   borderRadius: BorderRadius.circular(12),
      //   boxShadow: [
      //     BoxShadow(
      //       color: Colors.black.withOpacity(0.05),
      //       blurRadius: 10,
      //       offset: Offset(0, 2),
      //     ),
      //   ],
      // ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Add Photo or Video',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Obx(
                    () => Text(
                  '${controller.uploadedMedia.length}/3',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Obx(() {
            if (controller.uploadedMedia.isEmpty) {
              return UploadPlaceholderWidget();
            }
            return MediaGridWidget();
          }),
        ],
      ),
    );
  }
}