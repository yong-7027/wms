import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/service_feedback_controller.dart';
import '../../../models/service_feedback_model.dart';
import 'media_grid.dart';
import 'upload_placeholder.dart';

class MediaUploadSection extends StatelessWidget {
  final ServiceFeedbackModel feedback;

  const MediaUploadSection({super.key, required this.feedback});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ServiceFeedbackController>();

    return Container(
      padding: EdgeInsets.all(16),
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
              Obx(() => Text(
                '${controller.temporaryMediaPaths.length}/3',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              )),
            ],
          ),
          SizedBox(height: 16),
          Obx(() {
            if (controller.isMediaLoading.value) {
              return _buildLoadingIndicator();
            }

            return MediaGrid(feedback: feedback);
          }),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      height: 100,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 8),
            Text(
              'Loading media...',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}