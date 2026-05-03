/// 分区标题组件
///
/// 带图标和分隔线的区域标题。
/// 对应 Python CustomTkinter 的 SectionHeader 组件。
library;

import 'package:flutter/material.dart';

/// 分区标题组件
///
/// 显示带可选图标和底部分隔线的区域标题。
class SectionHeader extends StatelessWidget {
  /// 标题文本
  final String title;

  /// 图标
  final IconData? icon;

  /// 图标大小
  final double iconSize;

  /// 是否显示分隔线
  final bool showDivider;

  /// 标题样式
  final TextStyle? textStyle;

  /// 右侧附加组件
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.title,
    this.icon,
    this.iconSize = 20,
    this.showDivider = true,
    this.textStyle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: iconSize,
                color: theme.textTheme.titleMedium?.color,
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                title,
                style: textStyle ??
                    theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ],
          ],
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Divider(
              height: 1,
              thickness: 1,
              color: colorScheme.outlineVariant,
            ),
          ),
      ],
    );
  }
}
