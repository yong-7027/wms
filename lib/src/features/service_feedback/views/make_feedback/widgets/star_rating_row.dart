import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wms/src/features/service_feedback/controllers/service_feedback_controller.dart';
import '../../test.dart';
import 'star_animation.dart';

/// Individual star rating row component with immediate animation feedback
class StarRatingRow extends StatelessWidget {
  final String title;
  final String category;

  const StarRatingRow({
    super.key,
    required this.title,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    // Access the ServiceFeedbackController from GetX
    final controller = Get.find<ServiceFeedbackController>();

    return Container(
      height: 70,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // --- Title section ---
              Expanded(
                flex: 2,
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),

              // --- Star rating section ---
              Expanded(
                flex: 3,
                child: Obx(() {
                  // Get the current rating for this category
                  final currentRating = _getCurrentRating(controller, category);

                  // Access the list of star animations for this category
                  final animations = controller.starAnimations[category];

                  return FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(5, (index) {
                        // If animations are not available, fall back to a basic star
                        if (animations == null || index >= animations.length) {
                          return _buildFallbackStar(
                            index,
                            currentRating,
                            controller,
                            category,
                          );
                        }

                        // Use StarAnimation when animations are available
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            StarAnimation(
                              animationController: animations[index],
                              isSelected: index < currentRating, // Highlight selected stars
                              onTap: () => controller.setRating(category, index + 1), // Update rating on tap
                            ),
                            // Add StarShine animation for the 5th star when rating is 5
                            if (index == 4 && currentRating == 5)
                              _buildStarShineEffect(controller),
                          ],
                        );
                      }),
                    ),
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 获取当前评分
  int _getCurrentRating(ServiceFeedbackController controller, String category) {
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

  /// 备用星星组件
  Widget _buildFallbackStar(
      int index,
      int currentRating,
      ServiceFeedbackController controller,
      String category,
      ) {
    final isSelected = index < currentRating;

    return GestureDetector(
      onTap: () => controller.setRating(category, index + 1),
      child: Icon(
        isSelected ? Icons.star : Icons.star_border,
        color: isSelected ? Colors.amber[600] : Colors.grey[400],
        size: 32,
      ),
    );
  }

  /// 构建星光特效
  Widget _buildStarShineEffect(ServiceFeedbackController controller) {
    final shineController = controller.shineControllers[category];
    if (shineController == null) return SizedBox.shrink();

    return AnimatedBuilder(
      animation: shineController,
      builder: (context, child) {
        return IgnorePointer(
          child: CustomPaint(
            painter: StarShinePainter(shineController.value),
            size: const Size(32, 32),
          ),
        );
      },
    );
  }
}