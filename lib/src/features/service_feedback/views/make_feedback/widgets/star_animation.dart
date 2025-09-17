import 'package:flutter/material.dart';
import 'package:wms/src/features/service_feedback/controllers/star_animation_controller.dart';

class StarAnimation extends StatelessWidget {
  final StarAnimationController animationController;
  final bool isSelected;
  final VoidCallback onTap;

  const StarAnimation({
    super.key,
    required this.animationController,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: animationController.controller,
        builder: (context, child) {
          return Transform.scale(
            scale: animationController.scale,
            child: Container(
              padding: EdgeInsets.all(6),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 100), // 快速的颜色过渡
                child: Icon(
                  isSelected ? Icons.star : Icons.star_border,
                  color: isSelected ? Colors.amber[600] : Colors.grey[400],
                  size: 32,
                  shadows: isSelected ? [
                    Shadow(
                      color: Colors.amber.withOpacity(0.4),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ] : null,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}