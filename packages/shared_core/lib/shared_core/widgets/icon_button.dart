/// 图标按钮组件
///
/// 支持图标和文本组合的按钮，提供主按钮和次要按钮样式。
/// 对应 Python CustomTkinter 的 IconButton 组件。
library;

import 'package:flutter/material.dart';

/// 图标按钮类型
enum AppIconButtonType {
  /// 主要按钮（填充样式）
  primary,
  /// 次要按钮（描边样式）
  secondary,
  /// 文本按钮
  text,
  /// 纯图标按钮
  icon,
}

/// 图标按钮组件
///
/// 支持多种按钮样式，确保最小触控目标 48x48。
class AppIconButton extends StatelessWidget {
  /// 图标
  final IconData icon;

  /// 按钮文本
  final String? label;

  /// 按钮类型
  final AppIconButtonType type;

  /// 点击回调
  final VoidCallback? onPressed;

  /// 是否禁用
  final bool disabled;

  /// 图标大小
  final double iconSize;

  /// 按钮宽度（icon 类型时使用）
  final double? buttonWidth;

  /// 按钮高度
  final double? buttonHeight;

  /// 自定义颜色
  final Color? color;

  const AppIconButton({
    super.key,
    required this.icon,
    this.label,
    this.type = AppIconButtonType.primary,
    this.onPressed,
    this.disabled = false,
    this.iconSize = 20,
    this.buttonWidth,
    this.buttonHeight,
    this.color,
  });

  /// 纯图标按钮快捷构造函数
  const AppIconButton.iconOnly({
    super.key,
    required this.icon,
    this.onPressed,
    this.disabled = false,
    this.iconSize = 24,
    this.buttonWidth = 40,
    this.buttonHeight = 40,
    this.color,
  })  : label = null,
        type = AppIconButtonType.icon;

  /// 主要按钮快捷构造函数
  const AppIconButton.primary({
    super.key,
    required this.icon,
    required this.label,
    this.onPressed,
    this.disabled = false,
    this.iconSize = 20,
    this.color,
  })  : type = AppIconButtonType.primary,
        buttonWidth = null,
        buttonHeight = null;

  /// 次要按钮快捷构造函数
  const AppIconButton.secondary({
    super.key,
    required this.icon,
    required this.label,
    this.onPressed,
    this.disabled = false,
    this.iconSize = 20,
    this.color,
  })  : type = AppIconButtonType.secondary,
        buttonWidth = null,
        buttonHeight = null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveColor = color ??
        (type == AppIconButtonType.primary
            ? colorScheme.onPrimary
            : type == AppIconButtonType.icon
                ? colorScheme.onSurfaceVariant
                : colorScheme.primary);

    final effectiveOnPressed = disabled ? null : onPressed;

    switch (type) {
      case AppIconButtonType.primary:
        return FilledButton.icon(
          onPressed: effectiveOnPressed,
          icon: Icon(icon, size: iconSize),
          label: Text(label ?? ''),
        );

      case AppIconButtonType.secondary:
        return OutlinedButton.icon(
          onPressed: effectiveOnPressed,
          icon: Icon(icon, size: iconSize),
          label: Text(label ?? ''),
        );

      case AppIconButtonType.text:
        return TextButton.icon(
          onPressed: effectiveOnPressed,
          icon: Icon(icon, size: iconSize),
          label: Text(label ?? ''),
        );

      case AppIconButtonType.icon:
        return SizedBox(
          width: buttonWidth,
          height: buttonHeight,
          child: IconButton(
            icon: Icon(icon, size: iconSize, color: effectiveColor),
            onPressed: effectiveOnPressed,
            tooltip: label,
          ),
        );
    }
  }
}
