import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/service_feedback_controller.dart';

class ServiceInfo extends StatelessWidget {
  const ServiceInfo({super.key});

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
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[300]!, Colors.blue[600]!],
                ),
              ),
              child: Icon(Icons.car_repair, color: Colors.white, size: 40),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => Text(
                  controller.serviceType.value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                )),
                SizedBox(height: 4),
                Obx(() => Text(
                  controller.carName.value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                )),
                SizedBox(height: 2),
                Obx(() => Text(
                  controller.serviceDetails.value,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                )),
              ],
            ),
          ),
          Obx(() => Text(
            controller.serviceDate.value,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          )),
        ],
      ),
    );
  }
}