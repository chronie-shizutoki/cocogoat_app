import 'package:flutter/material.dart';

class GenshinAnimations {
  // 淡入动画
  static Animation<double> fadeInAnimation(AnimationController controller) {
    return Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeIn),
    );
  }

  // 滑动动画
  static Animation<Offset> slideAnimation(AnimationController controller) {
    return Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOut),
    );
  }

  // 缩放动画
  static Animation<double> scaleAnimation(AnimationController controller) {
    return Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOut),
    );
  }

  // 组合动画（淡入+滑动）
  static Animation<Offset> fadeInSlideAnimation(AnimationController controller) {
    return Tween<Offset>(begin: const Offset(0, 20), end: Offset.zero).animate(
      CurvedAnimation(parent: controller, curve: const Interval(0.0, 0.5)),
    );
  }

  // 按钮点击动画
  static Widget buttonAnimation(Widget child, TickerProvider vsync) {
    return ScaleTransition(
      scale: Tween<double>(begin: 1.0, end: 0.95).animate(
        CurvedAnimation(
          parent: AnimationController(
            duration: const Duration(milliseconds: 200),
            vsync: vsync,
          ),
          curve: Curves.easeInOut,
        ),
      ),
      child: child,
    );
  }

  // 页面进入动画
  static Widget pageEnterAnimation(Widget child, Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }

  // 淡入上移动画
  static Widget fadeInUpTransition(Widget child, Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 20),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }
}