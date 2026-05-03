/// 状态徽章组件
///
/// 显示不同状态的小型标签。
/// 对应 Python CustomTkinter 的 StatusBadge 组件。
library;

import 'package:flutter/material.dart';

/// 状态类型
enum AppBadgeStatus {
  /// 成功
  success,
  /// 错误
  error,
  /// 警告
  warning,
  /// 信息
  info,
}

/// 状态徽章组件
///
/// 小型圆角标签，显示不同状态的颜色和文本。
class StatusBadge extends StatelessWidget {
  /// 显示文本
  final String text;

  /// 状态类型
  final AppBadgeStatus status;

  /// 是否使用描边样式
  final bool outlined;

  /// 内边距
  final EdgeInsets padding;

  /// 字体大小
  final double fontSize;

  const StatusBadge({
    super.key,
    required this.text,
    this.status = AppBadgeStatus.info,
    this.outlined = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    this.fontSize = 10,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final colors = _getStatusColors(status, colorScheme);

    return Container(
      padding: padding,
      decoration: outlined
          ? BoxDecoration(
              border: Border.all(color: colors.background),
              borderRadius: BorderRadius.circular(12),
            )
          : BoxDecoration(
              color: colors.background,
              borderRadius: BorderRadius.circular(12),
            ),
      child: Text(
        text,
        style: TextStyle(
          color: outlined ? colors.background : colors.foreground,
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
        ),
      ),
    );
  }

  ({Color background, Color foreground}) _getStatusColors(
    AppBadgeStatus status,
    ColorScheme colorScheme,
  ) {
    switch (status) {
      case AppBadgeStatus.success:
        return (
          background: colorScheme.tertiary,
          foreground: Colors.white,
        );
      case AppBadgeStatus.error:
        return (
          background: colorScheme.error,
          foreground: Colors.white,
        );
      case AppBadgeStatus.warning:
        return (
          background: const Color(0xFFF59E0B),
          foreground: Colors.white,
        );
      case AppBadgeStatus.info:
        return (
          background: colorScheme.primary,
          foreground: Colors.white,
        );
    }
  }
}
