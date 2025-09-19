import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/service_feedback_controller.dart';
import '../../../models/service_feedback_model.dart';
import 'add_media_button.dart';
import 'upload_placeholder.dart';

// Media Grid Widget - Updated to use temporaryMediaPaths
class MediaGrid extends StatelessWidget {
  final ServiceFeedbackModel feedback;

  const MediaGrid({super.key, required this.feedback});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ServiceFeedbackController>();

    return Obx(() {
      final mediaCount = controller.temporaryMediaPaths.length;

      // 如果没有媒体，显示完整的上传占位符
      if (mediaCount == 0) {
        return UploadPlaceholder(feedback: feedback);
      }

      // 如果有媒体，显示网格和添加按钮
      return Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: mediaCount + (mediaCount < controller.maxMediaCount ? 1 : 0),
            itemBuilder: (context, index) {
              // 如果是最后一个且未达到最大数量，显示添加按钮
              if (index == mediaCount && mediaCount < controller.maxMediaCount) {
                return AddMediaButton();
              }

              // 否则显示媒体项
              final filePath = controller.temporaryMediaPaths[index];
              return _buildMediaItem(filePath, index, controller);
            },
          ),
        ],
      );
    });
  }

  Widget _buildMediaItem(String filePath, int index, ServiceFeedbackController controller) {
    final String extension = filePath.split('.').last.toLowerCase();
    final bool isVideo = ['mp4', 'mov', 'avi', 'mkv'].contains(extension);
    final File file = File(filePath);

    return Stack(
      children: [
        GestureDetector(
          onTap: () => controller.showMediaPreview(filePath, index),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200],
            ),
            child: isVideo
                ? _buildVideoThumbnail(file)
                : _buildImageThumbnail(file),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => controller.removeMedia(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageThumbnail(File file) {
    return Image.file(
      file,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const Center(
          child: Icon(Icons.error, color: Colors.red),
        );
      },
    );
  }

  Widget _buildVideoThumbnail(File file) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.videocam, size: 24, color: Colors.blue[600]),
          const SizedBox(height: 4),
          Text(
            'Video',
            style: TextStyle(color: Colors.blue[600], fontSize: 10),
          ),
        ],
      ),
    );
  }
}