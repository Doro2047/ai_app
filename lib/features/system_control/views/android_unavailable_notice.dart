/// Android 平台功能降级提示组件
library;

import 'package:flutter/material.dart';

/// Android 平台不可用提示组件
///
/// 在 Android 平台上显示功能受限的说明信息。
class AndroidUnavailableNotice extends StatelessWidget {
  /// 标题文本
  final String title;

  /// 说明文本
  final String description;

  /// 图标
  final IconData icon;

  /// 是否显示为卡片
  final bool showAsCard;

  const AndroidUnavailableNotice({
    super.key,
    this.title = '平台功能限制',
    this.description = '此功能在 Android 平台上不可用，需要 root 权限或使用 Platform Channel 实现。',
    this.icon = Icons.warning_amber_rounded,
    this.showAsCard = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: colorScheme.tertiary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colorScheme.tertiary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );

    if (showAsCard) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.tertiary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: content,
      );
    }

    return content;
  }
}
