import 'package:flutter/material.dart';

class StarAnimationController {
  late AnimationController _controller;
  late Animation<double> scaleAnimation;

  final TickerProvider vsync;
  final Duration duration;

  StarAnimationController({
    required this.vsync,
    this.duration = const Duration(milliseconds: 200),
  }) {
    _controller = AnimationController(duration: duration, vsync: vsync);

    // 优化的缩放动画：快速放大，快速缩小，无停顿
    scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.4),
        weight: 40, // 40% 时间放大
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.4, end: 1.0),
        weight: 60, // 60% 时间缩小
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut, // 更流畅的曲线
    ));
  }

  /// 触发弹跳动画，一次性完成放大缩小
  void triggerBounceAnimation() {
    _controller.reset();
    _controller.forward();
  }

  /// 重置动画状态
  void reset() {
    _controller.reset();
  }

  /// 销毁动画控制器
  void dispose() {
    _controller.dispose();
  }

  // Getters
  double get scale => scaleAnimation.value;
  Animation<double> get controller => _controller;
}