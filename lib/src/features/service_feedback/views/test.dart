import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const StarShineDemo());
}

class StarShineDemo extends StatelessWidget {
  const StarShineDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: StarRatingWidget()),
      ),
    );
  }
}

class StarRatingWidget extends StatefulWidget {
  const StarRatingWidget({super.key});

  @override
  State<StarRatingWidget> createState() => _StarRatingWidgetState();
}

class _StarRatingWidgetState extends State<StarRatingWidget>
    with SingleTickerProviderStateMixin {
  int rating = 0;
  late AnimationController _shineController;

  @override
  void initState() {
    super.initState();
    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    _shineController.dispose();
    super.dispose();
  }

  void _onStarTap(int index) {
    setState(() {
      rating = index + 1;
    });

    if (rating == 5) {
      _shineController.forward(from: 0); // 播放星光动画
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () => _onStarTap(index),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.star,
                color: index < rating ? Colors.amber : Colors.grey,
                size: 50,
              ),
              // 在第五颗星上叠加星光动画
              if (index == 4)
                AnimatedBuilder(
                  animation: _shineController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: StarShinePainter(_shineController.value),
                      size: const Size(80, 80),
                    );
                  },
                ),
            ],
          ),
        );
      }),
    );
  }
}

class StarShinePainter extends CustomPainter {
  final double progress;
  final Random _random = Random();

  StarShinePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // 绘制放射光线
    for (int i = 0; i < 12; i++) {
      final angle = i * pi / 6;
      final length = 20 + progress * 30;
      final paint = Paint()
        ..color = Colors.yellow.withOpacity(1 - progress)
        ..strokeWidth = 2;

      final p1 = center;
      final p2 = center + Offset(cos(angle), sin(angle)) * length;
      canvas.drawLine(p1, p2, paint);
    }

    // 绘制随机小光点
    for (int i = 0; i < 20; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final radius = progress * 40;
      final offset = center +
          Offset(cos(angle), sin(angle)) * (radius * _random.nextDouble());

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
