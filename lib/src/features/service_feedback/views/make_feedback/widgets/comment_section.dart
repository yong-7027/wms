import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/service_feedback_controller.dart';

class CommentSection extends StatelessWidget {
  const CommentSection({super.key});

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
                'Write your Reviews',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Obx(
                    () => Text(
                  '${controller.commentLength.value}/150',
                  style: TextStyle(
                    fontSize: 14,
                    color: controller.commentLength.value >= 150
                        ? Colors.red
                        : Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          TextField(
            controller: controller.commentController,
            maxLines: 5,
            maxLength: 150,
            decoration: InputDecoration(
              hintText: 'Would you like to write anything about us?',
              hintStyle: TextStyle(color: Colors.grey[500]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.blue),
              ),
              contentPadding: EdgeInsets.all(12),
              counterText: '',
            ),
            onChanged: controller.updateComment,
          ),
        ],
      ),
    );
  }
}