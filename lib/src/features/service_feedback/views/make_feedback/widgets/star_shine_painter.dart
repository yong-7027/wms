import 'dart:math' as Math;

import 'package:flutter/material.dart';

/// StarShine painter for 5-star special effect
class StarShinePainter extends CustomPainter {
  final double progress;
  final Math.Random _random = Math.Random();

  StarShinePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // 绘制放射光线
    for (int i = 0; i < 12; i++) {
      final angle = i * Math.pi / 6;
      final length = 20 + progress * 30;
      final paint = Paint()
        ..color = Colors.yellow.withOpacity(1 - progress)
        ..strokeWidth = 2;

      final p1 = center;
      final p2 = center + Offset(Math.cos(angle), Math.sin(angle)) * length;
      canvas.drawLine(p1, p2, paint);
    }

    // 绘制随机小光点
    for (int i = 0; i < 20; i++) {
      final angle = _random.nextDouble() * 2 * Math.pi;
      final radius = progress * 40;
      final offset = center +
          Offset(Math.cos(angle), Math.sin(angle)) * (radius * _random.nextDouble());

      final paint = Paint()
        ..color = Colors.white.withOpacity(1 - progress)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(offset, 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant StarShinePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}