import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/service_feedback_controller.dart';
import 'star_rating_row.dart';

/// Complete star rating section with all categories
class StarRatingSection extends StatelessWidget {
  const StarRatingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      // decoration: BoxDecoration(
      //   color: Colors.white,
      //   borderRadius: BorderRadius.circular(16),
      //   boxShadow: [
      //     BoxShadow(
      //       color: Colors.black.withOpacity(0.08),
      //       blurRadius: 12,
      //       offset: Offset(0, 4),
      //     ),
      //   ],
      // ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Text(
            'Rate Your Experience',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),

          // Rating rows
          StarRatingRow(
            title: 'Service Quality',
            category: 'service',
          ),
          StarRatingRow(
            title: 'Repair Efficiency',
            category: 'repair',
          ),
          StarRatingRow(
            title: 'Transparency',
            category: 'transparency',
          ),
          StarRatingRow(
            title: 'Overall Experience',
            category: 'overall',
          ),

          // Validation message
          _buildValidationMessage(),
        ],
      ),
    );
  }

  /// Build validation message widget
  Widget _buildValidationMessage() {
    final controller = Get.find<ServiceFeedbackController>();

    return Obx(() {
      if (controller.validationMessage.value.isNotEmpty) {
        return Container(
          margin: EdgeInsets.only(top: 16),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: controller.canSubmit.value ? Colors.green[50] : Colors.orange[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: controller.canSubmit.value ? Colors.green[200]! : Colors.orange[200]!,
            ),
          ),
          child: Row(
            children: [
              Icon(
                controller.canSubmit.value ? Icons.check_circle : Icons.info,
                color: controller.canSubmit.value ? Colors.green[600] : Colors.orange[600],
                size: 16,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  controller.validationMessage.value,
                  style: TextStyle(
                    color: controller.canSubmit.value ? Colors.green[700] : Colors.orange[700],
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        );
      }
      return SizedBox.shrink();
    });
  }
}

