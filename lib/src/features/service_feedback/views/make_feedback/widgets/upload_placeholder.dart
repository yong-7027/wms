import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/service_feedback_controller.dart';
import '../../../models/service_feedback_model.dart';

// Upload Placeholder Widget with camera and gallery options
class UploadPlaceholder extends StatelessWidget {
  final ServiceFeedbackModel feedback;

  const UploadPlaceholder({super.key, required this.feedback});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ServiceFeedbackController>();

    return Obx(() {
      // 只有在媒体数量少于最大限制时才显示上传按钮
      if (controller.temporaryMediaPaths.length >= controller.maxMediaCount) {
        return const SizedBox.shrink();
      }

      return GestureDetector(
        onTap: () {
          // 显示选择对话框
          _showMediaSourceDialog(context, controller);
        },
        child: Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.camera_alt_outlined, size: 32, color: Colors.blue[600]),
              const SizedBox(height: 8),
              Text(
                'Tap to add photo/video',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                'Camera or Gallery',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      );
    });
  }

  void _showMediaSourceDialog(BuildContext context, ServiceFeedbackController controller) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.blue),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  controller.pickMediaFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.blue),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  controller.pickMediaFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.grey),
                title: const Text('Cancel'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }
}