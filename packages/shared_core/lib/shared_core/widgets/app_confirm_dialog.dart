/// 确认对话框组件
///
/// 显示确认消息，支持自定义标题、消息、按钮文本和图标。
/// 对应 Python CustomTkinter 的 ConfirmDialog 组件。
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 确认对话框组件
///
/// 模态对话框，等待用户确认或取消操作。
/// 支持键盘快捷键（Enter 确认，Escape 取消）。
class AppConfirmDialog extends StatelessWidget {
  /// 对话框标题
  final String title;

  /// 确认消息
  final String message;

  /// 确认按钮文本
  final String confirmText;

  /// 取消按钮文本
  final String cancelText;

  /// 图标
  final IconData? icon;

  /// 确认按钮是否为危险操作（红色）
  final bool isDangerous;

  const AppConfirmDialog({
    super.key,
    this.title = '确认',
    required this.message,
    this.confirmText = '确定',
    this.cancelText = '取消',
    this.icon,
    this.isDangerous = false,
  });

  /// 显示确认对话框并返回结果
  ///
  /// 返回 true 表示用户点击了确认按钮，false 表示取消。
  static Future<bool> show(
    BuildContext context, {
    String title = '确认',
    required String message,
    String confirmText = '确定',
    String cancelText = '取消',
    IconData? icon,
    bool isDangerous = false,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AppConfirmDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        icon: icon,
        isDangerous: isDangerous,
      ),
    ).then((result) => result ?? false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: (event) {
        if (event.logicalKey == LogicalKeyboardKey.enter) {
          Navigator.of(context).pop(true);
        } else if (event.logicalKey == LogicalKeyboardKey.escape) {
          Navigator.of(context).pop(false);
        }
      },
      child: AlertDialog(
        title: Row(
          children: [
            Icon(
              icon ?? Icons.warning_amber_rounded,
              color: isDangerous
                  ? theme.colorScheme.error
                  : theme.colorScheme.primary,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title),
            ),
          ],
        ),
        content: Text(
          message,
          style: theme.textTheme.bodyLarge,
        ),
        actions: [
          // 取消按钮
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          const SizedBox(width: 8),
          // 确认按钮
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: isDangerous
                ? FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.error,
                    foregroundColor: theme.colorScheme.onError,
                  )
                : null,
            autofocus: true,
            child: Text(confirmText),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
