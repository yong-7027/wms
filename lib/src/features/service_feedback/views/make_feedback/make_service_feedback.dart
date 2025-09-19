import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import '../../controllers/service_feedback_controller.dart';
import 'widgets/comment_section.dart';
import 'widgets/media_upload_section.dart';
import 'widgets/service_info.dart';
import 'widgets/star_rating_section.dart';
import '../../models/service_feedback_model.dart'; // Import the model

class MakeServiceFeedbackScreen extends StatelessWidget {
  final ServiceFeedbackModel feedback;

  const MakeServiceFeedbackScreen({super.key, required this.feedback});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ServiceFeedbackController(feedback: feedback));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Write Reviews',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ServiceInfo(feedback: feedback),
            SizedBox(height: 24),
            StarRatingSection(),
            SizedBox(height: 24),
            MediaUploadSection(feedback: feedback),
            SizedBox(height: 24),
            CommentSection(),
            SizedBox(height: 32),
            SubmitButtonWidget(),
          ],
        ),
      ),
    );
  }
}

// Add Media Button Widget with camera and gallery options
class AddMediaButtonWidget extends StatelessWidget {
  final ServiceFeedbackModel feedback;

  const AddMediaButtonWidget({super.key, required this.feedback});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ServiceFeedbackController>();

    return GestureDetector(
      onTap: () {
        // 显示选择对话框
        _showMediaSourceDialog(context, controller);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: Colors.blue[600], size: 24),
            SizedBox(height: 4),
            Text(
              'Add',
              style: TextStyle(fontSize: 10, color: Colors.blue[600]),
            ),
          ],
        ),
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
                leading: Icon(Icons.camera_alt, color: Colors.blue),
                title: Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  controller.pickMediaFromCamera();
                },
              ),
              ListTile(
                leading: Icon(Icons.videocam, color: Colors.blue),
                title: Text('Record Video'),
                onTap: () {
                  Navigator.pop(context);
                  controller.pickMediaFromCamera();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: Colors.blue),
                title: Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  controller.pickMediaFromGallery();
                },
              ),
              ListTile(
                leading: Icon(Icons.cancel, color: Colors.grey),
                title: Text('Cancel'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Submit Button Widget
class SubmitButtonWidget extends StatelessWidget {
  const SubmitButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ServiceFeedbackController>();

    return Obx(() {
      final canSubmit = controller.canSubmit.value;

      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: canSubmit ? controller.submitReview : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: canSubmit ? Colors.blue[600] : Colors.grey[400],
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: canSubmit ? 3 : 0,
          ),
          child: const Text(
            'Submit',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      );
    });
  }
}