import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/service_feedback_controller.dart';

class AddMediaButton extends StatelessWidget {
  const AddMediaButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ServiceFeedbackController>();

    return GestureDetector(
      onTap: () {
        _showMediaSourceDialog(context, controller);
      },
      child: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Icon(Icons.add, color: Colors.blue[600], size: 32),
      ),
    );
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