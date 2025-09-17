import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import '../../controllers/service_feedback_controller.dart';
import 'widgets/comment_section.dart';
import 'widgets/media_upload_section.dart';
import 'widgets/service_info.dart';
import 'widgets/star_rating_section.dart';

class MakeServiceFeedbackScreen extends StatelessWidget {
  const MakeServiceFeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ServiceFeedbackController());

    return Scaffold(
      // backgroundColor: Colors.grey[50],
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
            ServiceInfo(),
            SizedBox(height: 24),
            StarRatingSection(),
            SizedBox(height: 24),
            MediaUploadSection(),
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

// Upload Placeholder Widget
class UploadPlaceholderWidget extends StatelessWidget {
  const UploadPlaceholderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ServiceFeedbackController>();

    return GestureDetector(
      onTap: controller.pickMedia,
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
            Icon(Icons.file_upload_outlined, size: 32, color: Colors.blue[600]),
            SizedBox(height: 8),
            Text(
              'Click here to upload',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

// Media Grid Widget
class MediaGridWidget extends StatelessWidget {
  const MediaGridWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ServiceFeedbackController>();

    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount:
              controller.uploadedMedia.length +
              (controller.remainingMediaSlots > 0 ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < controller.uploadedMedia.length) {
              return MediaItemWidget(
                file: controller.uploadedMedia[index],
                index: index,
              );
            } else {
              return AddMediaButtonWidget();
            }
          },
        ),
      ],
    );
  }
}

// Media Item Widget
class MediaItemWidget extends StatelessWidget {
  final File file;
  final int index;

  const MediaItemWidget({super.key, required this.file, required this.index});

  @override
  Widget build(BuildContext context) {
    String extension = file.path.split('.').last.toLowerCase();
    bool isVideo = ['mp4', 'mov'].contains(extension);
    final controller = Get.find<ServiceFeedbackController>();

    return GestureDetector(
      onTap: () => controller.showMediaPreview(file, index),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: isVideo
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.video_library,
                            size: 40,
                            color: Colors.grey[600],
                          ),
                        ),
                        Icon(
                          Icons.play_circle_outline,
                          size: 30,
                          color: Colors.blue[600],
                        ),
                      ],
                    )
                  : Image.file(file, fit: BoxFit.cover),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => controller.removeMedia(index),
              child: Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Add Media Button Widget
class AddMediaButtonWidget extends StatelessWidget {
  const AddMediaButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ServiceFeedbackController>();

    return GestureDetector(
      onTap: controller.pickMedia,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Icon(Icons.add, color: Colors.blue[600], size: 32),
      ),
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


