import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/service_feedback_controller.dart';
import '../../../models/service_feedback_model.dart';

class MediaItem extends StatelessWidget {
  final String filePath;
  final int index;
  final ServiceFeedbackModel feedback;

  const MediaItem({super.key,
    required this.filePath,
    required this.index,
    required this.feedback,
  });

  @override
  Widget build(BuildContext context) {
    String extension = filePath.split('.').last.toLowerCase();
    bool isVideo = ['mp4', 'mov'].contains(extension);
    final controller = Get.find<ServiceFeedbackController>();

    return GestureDetector(
      onTap: () => controller.showMediaPreview(filePath, index),
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
                  : Image.file(File(filePath), fit: BoxFit.cover),
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