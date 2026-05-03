/// 应用状态栏组件
///
/// 显示状态文本、进度条和附加信息。
/// 对应 Python CustomTkinter 的 StatusBar 组件。
library;

import 'package:flutter/material.dart';

/// 应用状态栏组件
///
/// 包含状态文本、进度条和附加信息区域。
/// 通常放置在页面底部，高度 28 逻辑像素。
class AppStatusBar extends StatelessWidget {
  /// 状态文本
  final String statusText;

  /// 进度值 (0.0 - 1.0)
  final double progress;

  /// 是否显示进度条
  final bool showProgress;

  /// 附加信息文本
  final String? extraInfo;

  /// 状态栏高度
  final double height;

  const AppStatusBar({
    super.key,
    this.statusText = '就绪',
    this.progress = 0.0,
    this.showProgress = true,
    this.extraInfo,
    this.height = 28,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: theme.dividerTheme.color ?? colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // 状态文本
          Text(
            statusText,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 11,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          // 进度条
          if (showProgress) ...[
            const SizedBox(width: 12),
            SizedBox(
              width: 160,
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                minHeight: 4,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
          // 附加信息
          if (extraInfo != null) ...[
            const Spacer(),
            Text(
              extraInfo!,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 11,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
