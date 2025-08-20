import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';

import 'notification_controller.dart';

class ReviewScreen extends StatelessWidget {
  final ReviewController controller = Get.put(ReviewController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
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
            _buildServiceInfo(),
            SizedBox(height: 24),
            _buildRatingSection(),
            SizedBox(height: 24),
            _buildMediaUploadSection(),
            SizedBox(height: 24),
            _buildCommentSection(),
            SizedBox(height: 32),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceInfo() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
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

  Widget _buildRatingSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildRatingRow('Service', 'service', 0),
          Divider(height: 24),
          _buildRatingRow('Repair Efficiency', 'repair', 5),
          Divider(height: 24),
          _buildRatingRow('Transparency', 'transparency', 10),
          Divider(height: 24),
          _buildRatingRow('Overall Experience', 'overall', 15),
        ],
      ),
    );
  }

  Widget _buildRatingRow(String title, String category, int animationStartIndex) {
    return Container(
      height: 50, // Fixed height to prevent overflow
      child: Stack(
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: List.generate(5, (index) {
                    return GestureDetector(
                      onTap: () => controller.setRating(category, index + 1),
                      child: AnimatedBuilder(
                        animation: controller.starAnimations[animationStartIndex + index],
                        builder: (context, child) {
                          return Transform.scale(
                            scale: controller.starAnimations[animationStartIndex + index].value,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 1),
                              child: Obx(() {
                                int currentRating = _getCurrentRating(category);
                                bool isSelected = index < currentRating;
                                return Icon(
                                  isSelected ? Icons.star : Icons.star_outline,
                                  color: isSelected ? Colors.amber : Colors.grey[400],
                                  size: 24, // Reduced size to fit better
                                );
                              }),
                            ),
                          );
                        },
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
          // Fireworks animation overlay for 4-5 stars
          AnimatedBuilder(
            animation: controller.fireworksAnimation,
            builder: (context, child) {
              int currentRating = _getCurrentRating(category);
              if (currentRating >= 4 && controller.fireworksAnimation.value > 0) {
                return Positioned(
                  right: 0,
                  top: -10,
                  child: Opacity(
                    opacity: controller.fireworksAnimation.value > 0.5
                        ? 1.0 - controller.fireworksAnimation.value
                        : controller.fireworksAnimation.value * 2,
                    child: Transform.scale(
                      scale: controller.fireworksAnimation.value * 2,
                      child: Container(
                        width: 60,
                        height: 60,
                        child: CustomPaint(
                          painter: FireworksPainter(controller.fireworksAnimation.value),
                        ),
                      ),
                    ),
                  ),
                );
              }
              return SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  int _getCurrentRating(String category) {
    switch (category) {
      case 'service':
        return controller.serviceRating.value;
      case 'repair':
        return controller.repairEfficiencyRating.value;
      case 'transparency':
        return controller.transparencyRating.value;
      case 'overall':
        return controller.overallExperienceRating.value;
      default:
        return 0;
    }
  }

  Widget _buildMediaUploadSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
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
                '${controller.uploadedMedia.length}/3',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              )),
            ],
          ),
          SizedBox(height: 16),
          Obx(() {
            if (controller.uploadedMedia.isEmpty) {
              return _buildUploadPlaceholder();
            }
            return _buildMediaGrid();
          }),
        ],
      ),
    );
  }

  Widget _buildUploadPlaceholder() {
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
            Icon(
              Icons.file_upload_outlined,
              size: 32,
              color: Colors.blue[600], // Changed to blue
            ),
            SizedBox(height: 8),
            Text(
              'Click here to upload',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaGrid() {
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
          itemCount: controller.uploadedMedia.length +
              (controller.remainingMediaSlots > 0 ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < controller.uploadedMedia.length) {
              return _buildMediaItem(controller.uploadedMedia[index], index);
            } else {
              return _buildAddMediaButton();
            }
          },
        ),
      ],
    );
  }

  Widget _buildMediaItem(File file, int index) {
    String extension = file.path.split('.').last.toLowerCase();
    bool isVideo = ['mp4', 'mov'].contains(extension);

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
                  : Image.file(
                file,
                fit: BoxFit.cover,
              ),
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
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddMediaButton() {
    return GestureDetector(
      onTap: controller.pickMedia,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Icon(
          Icons.add,
          color: Colors.blue[600], // Changed to blue
          size: 32,
        ),
      ),
    );
  }

  Widget _buildCommentSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
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
              Obx(() => Text(
                '${controller.commentLength.value}/150',
                style: TextStyle(
                  fontSize: 14,
                  color: controller.commentLength.value >= 150
                      ? Colors.red
                      : Colors.grey[600],
                ),
              )),
            ],
          ),
          SizedBox(height: 12),
          TextField(
            controller: controller.commentController,
            maxLines: 5,
            maxLength: 150, // Add character limit
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
              counterText: '', // Hide default counter
            ),
            onChanged: controller.updateComment,
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Obx(() => Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: controller.canSubmit.value ? controller.submitReview : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: controller.canSubmit.value
              ? Colors.blue[600]
              : Colors.grey[400],
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: controller.canSubmit.value ? 3 : 0,
        ),
        child: Text(
          'Submit',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    ));
  }
}

// Custom painter for fireworks animation
class FireworksPainter extends CustomPainter {
  final double animationValue;

  FireworksPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.amber
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    // Draw multiple sparks radiating outward
    for (int i = 0; i < 8; i++) {
      final angle = (i * 45) * (3.14159 / 180); // Convert to radians
      final sparkRadius = maxRadius * animationValue;
      final sparkPosition = Offset(
        center.dx + sparkRadius * cos(angle),
        center.dy + sparkRadius * sin(angle),
      );

      // Draw spark as a small circle
      canvas.drawCircle(sparkPosition, 2, paint);

      // Draw trailing line
      final trailStart = Offset(
        center.dx + (sparkRadius * 0.7) * cos(angle),
        center.dy + (sparkRadius * 0.7) * sin(angle),
      );

      canvas.drawLine(trailStart, sparkPosition, paint..strokeWidth = 1);
    }
  }

  @override
  bool shouldRepaint(FireworksPainter oldDelegate) {
    return animationValue != oldDelegate.animationValue;
  }
}

// Helper function for cos (since it's not imported)
double cos(double radians) {
  // Simple approximation for cos function
  // For animation purposes, this basic implementation works
  return (1 - (radians * radians) / 2 + (radians * radians * radians * radians) / 24).clamp(-1.0, 1.0);
}