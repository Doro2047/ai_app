/// 应用动画系统
///
/// 定义统一的动画时长和缓动曲线，确保界面动效的一致性和流畅性。
library;

import 'package:flutter/animation.dart';

/// 动画设计令牌
///
/// 提供动画时长、延迟和缓动曲线的标准化定义。
class AppAnimation {
  AppAnimation._();

  // ============================================================
  // 动画时长
  // ============================================================

  /// instant - 0ms (无动画、即时切换)
  static const Duration instant = Duration.zero;

  /// fast - 150ms (快速反馈、hover 状态)
  static const Duration fast = Duration(milliseconds: 150);

  /// normal - 200ms (标准动画、页面过渡默认)
  static const Duration normal = Duration(milliseconds: 200);

  /// slow - 300ms (慢速动画、复杂过渡、Toast 持续时间)
  static const Duration slow = Duration(milliseconds: 300);

  /// tooltipDelay - 500ms (Tooltip 显示延迟)
  static const Duration tooltipDelay = Duration(milliseconds: 500);

  /// toastDuration - 3000ms (Toast 显示持续时间)
  static const Duration toastDuration = Duration(seconds: 3);

  /// pageTransition - 350ms (页面切换动画时长)
  static const Duration pageTransition = Duration(milliseconds: 350);

  /// 动画时长值数组（毫秒）
  static const List<int> durationsMs = [0, 150, 200, 300, 500, 3000];

  // ============================================================
  // 缓动曲线
  // ============================================================

  /// easeOut - 快速开始，缓慢结束（默认推荐）
  static const Curve easeOut = Curves.easeOut;

  /// easeInOut - 缓慢开始和结束，中间加速（页面过渡）
  static const Curve easeInOut = Curves.easeInOut;

  /// easeIn - 缓慢开始，快速结束（退出动画）
  static const Curve easeIn = Curves.easeIn;

  /// fastOutSlowIn - Material 标准曲线
  static const Curve fastOutSlowIn = Curves.fastOutSlowIn;

  /// 弹性曲线（弹出动画）
  static const Curve elasticOut = Curves.elasticOut;

  /// 弹性曲线（带回弹）
  static const Curve elasticInOut = Curves.elasticInOut;

  // ============================================================
  // 常用缓动曲线组合
  // ============================================================

  /// 默认过渡曲线
  static const Curve defaultCurve = easeOut;

  /// 页面过渡曲线
  static const Curve pageTransitionCurve = easeInOut;

  /// 弹出动画曲线
  static const Curve popAnimationCurve = elasticOut;

  // ============================================================
  // 辅助方法
  // ============================================================

  /// 创建 Tween 动画参数
  static TweenAnimationParams tweenParams({
    Duration duration = normal,
    Curve curve = defaultCurve,
  }) {
    return TweenAnimationParams(
      duration: duration,
      curve: curve,
    );
  }
}

/// Tween 动画参数封装
class TweenAnimationParams {
  final Duration duration;
  final Curve curve;

  const TweenAnimationParams({
    this.duration = AppAnimation.normal,
    this.curve = AppAnimation.defaultCurve,
  });
}
