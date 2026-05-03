/// 空状态占位组件
///
/// 显示空数据状态，支持图标、标题、描述和操作按钮。
/// 对应 Python CustomTkinter 的 EmptyState 组件。
library;

import 'package:flutter/material.dart';

/// 空状态占位组件
///
/// 居中显示空数据提示，包含图标、标题、描述和可选操作按钮。
class EmptyState extends StatelessWidget {
  /// 图标
  final IconData? icon;

  /// 图标大小
  final double iconSize;

  /// 标题文本
  final String title;

  /// 描述文本
  final String? description;

  /// 操作按钮文本
  final String? actionText;

  /// 操作按钮回调
  final VoidCallback? onAction;

  /// 是否显示加载动画（替代静态图标）
  final bool showLoading;

  const EmptyState({
    super.key,
    this.icon,
    this.iconSize = 64,
    this.title = '暂无数据',
    this.description,
    this.actionText,
    this.onAction,
    this.showLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 图标或加载动画
            if (showLoading)
              SizedBox(
                width: iconSize,
                height: iconSize,
                child: const CircularProgressIndicator(
                  strokeWidth: 3,
                  value: 0.3,
                ),
              )
            else
              Icon(
                icon ?? Icons.inbox_outlined,
                size: iconSize,
                color: colorScheme.onSurfaceVariant,
              ),
            const SizedBox(height: 16),
            // 标题
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            // 描述
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            // 操作按钮
            if (actionText != null) ...[
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add, size: 18),
                label: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
