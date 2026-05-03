/// 卡片容器组件
///
/// 统一圆角和背景的卡片容器。
/// 对应 Python CustomTkinter 的 Card 组件。
library;

import 'package:flutter/material.dart';

/// 卡片容器组件
///
/// 提供统一圆角、边框和背景色的卡片容器。
/// 支持可选标题和点击交互。
class AppCard extends StatelessWidget {
  /// 卡片内容
  final Widget child;

  /// 卡片标题
  final String? title;

  /// 内边距
  final EdgeInsetsGeometry? padding;

  /// 点击回调
  final VoidCallback? onTap;

  /// 是否显示边框
  final bool showBorder;

  /// 卡片圆角
  final double? borderRadius;

  /// 卡片高度
  final double? height;

  const AppCard({
    super.key,
    required this.child,
    this.title,
    this.padding,
    this.onTap,
    this.showBorder = true,
    this.borderRadius,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardTheme = theme.cardTheme;

    Widget content = Padding(
      padding: padding ?? const EdgeInsets.all(16),
      child: child,
    );

    if (title != null) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title!,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(child: content),
        ],
      );
    }

    double cardRadius = borderRadius ?? 12;
    double cardBorderWidth = 0.5;
    Color cardBorderColor = theme.dividerTheme.color ?? Colors.transparent;

    final shape = cardTheme.shape;
    if (shape is RoundedRectangleBorder) {
      if (shape.borderRadius is BorderRadius) {
        final br = shape.borderRadius as BorderRadius;
        cardRadius = br.topRight.x;
      }
      if (shape.side != BorderSide.none) {
        cardBorderColor = shape.side.color;
        cardBorderWidth = shape.side.width;
      }
    }

    final card = Container(
      height: height,
      decoration: BoxDecoration(
        color: cardTheme.color,
        borderRadius: BorderRadius.circular(cardRadius),
        border: showBorder
            ? Border.all(
                color: cardBorderColor,
                width: cardBorderWidth,
              )
            : null,
        boxShadow: cardTheme.elevation != null && cardTheme.elevation! > 0
            ? [
                BoxShadow(
                  color: (cardTheme.shadowColor ?? Colors.black).withOpacity(0.1),
                  blurRadius: cardTheme.elevation!,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: content,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(cardRadius),
          child: card,
        ),
      );
    }

    return card;
  }
}
