import 'package:flutter/material.dart';

/// Controller to handle the shine effect animation
class StarShineController {
  late AnimationController animationController;

  StarShineController({required TickerProvider vsync}) {
    animationController = AnimationController(
      vsync: vsync,
      duration: const Duration(seconds: 1),
    );
  }

  /// Play the shine animation
  void play() {
    animationController.forward(from: 0);
  }

  /// Dispose resources
  void dispose() {
    animationController.dispose();
  }
}
