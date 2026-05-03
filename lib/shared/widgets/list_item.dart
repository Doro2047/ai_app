/// 列表项组件
///
/// 带悬停效果、可选中和完整状态管理的列表项。
/// 对应 Python CustomTkinter 的 ListItem 组件。
library;

import 'package:flutter/material.dart';

/// 列表项组件
///
/// 包含图标、主文本、详情文本，支持可选中和悬停效果。
class AppListItem extends StatefulWidget {
  /// 主文本
  final String text;

  /// 图标
  final IconData? icon;

  /// 右侧详情文本
  final String? detailText;

  /// 是否可选中
  final bool selectable;

  /// 初始选中状态
  final bool initiallySelected;

  /// 点击回调
  final VoidCallback? onTap;

  /// 长按回调
  final VoidCallback? onLongPress;

  /// 尾部组件
  final Widget? trailing;

  /// 是否显示分隔线
  final bool showDivider;

  const AppListItem({
    super.key,
    required this.text,
    this.icon,
    this.detailText,
    this.selectable = false,
    this.initiallySelected = false,
    this.onTap,
    this.onLongPress,
    this.trailing,
    this.showDivider = true,
  });

  @override
  State<AppListItem> createState() => _AppListItemState();
}

class _AppListItemState extends State<AppListItem> {
  late bool _isSelected;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _isSelected = widget.initiallySelected;
  }

  void _handleTap() {
    if (widget.selectable) {
      setState(() {
        _isSelected = !_isSelected;
      });
    }
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color backgroundColor;
    Color textColor;
    Color detailColor;

    if (_isSelected) {
      backgroundColor = colorScheme.primaryContainer;
      textColor = colorScheme.onPrimaryContainer;
      detailColor = colorScheme.onPrimaryContainer.withOpacity(0.7);
    } else if (_isHovered) {
      backgroundColor = colorScheme.surfaceContainerHighest.withOpacity(0.5);
      textColor = colorScheme.onSurface;
      detailColor = colorScheme.onSurfaceVariant;
    } else {
      backgroundColor = Colors.transparent;
      textColor = colorScheme.onSurface;
      detailColor = colorScheme.onSurfaceVariant;
    }

    return Column(
      children: [
        Material(
          color: backgroundColor,
          child: InkWell(
            onTap: _handleTap,
            onLongPress: widget.onLongPress,
            onHover: (hovered) {
              setState(() {
                _isHovered = hovered;
              });
            },
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 48, // 最小触控目标
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    // 左侧图标
                    if (widget.icon != null) ...[
                      Icon(
                        widget.icon,
                        size: 20,
                        color: textColor,
                      ),
                      const SizedBox(width: 12),
                    ],
                    // 主文本
                    Expanded(
                      child: Text(
                        widget.text,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: textColor,
                          fontWeight: _isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // 右侧详情文本
                    if (widget.detailText != null) ...[
                      const SizedBox(width: 12),
                      Text(
                        widget.detailText!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: detailColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    // 尾部组件
                    if (widget.trailing != null) ...[
                      const SizedBox(width: 8),
                      widget.trailing!,
                    ],
                    // 选中指示器
                    if (widget.selectable && _isSelected) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.check_circle,
                        size: 20,
                        color: colorScheme.primary,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        if (widget.showDivider)
          Divider(
            height: 1,
            thickness: 0.5,
            color: colorScheme.outlineVariant.withOpacity(0.5),
          ),
      ],
    );
  }
}
