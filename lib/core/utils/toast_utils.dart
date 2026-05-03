import 'package:flutter/material.dart';

/// Toast 提示工具类
/// 提供统一的 Toast 提示功能，支持多种提示类型
class ToastUtils {
  /// Toast 提示位置
  static ToastGravity _gravity = ToastGravity.BOTTOM;

  /// Toast 显示时长
  static Duration _duration = const Duration(seconds: 2);

  /// 设置全局 Toast 位置
  static void setGravity(ToastGravity gravity) {
    _gravity = gravity;
  }

  /// 设置全局 Toast 显示时长
  static void setDuration(Duration duration) {
    _duration = duration;
  }

  /// 显示成功提示
  /// 
  /// 绿色背景，白色文字，带成功图标
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration? duration,
    ToastGravity? gravity,
  }) {
    _showToast(
      context: context,
      message: message,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      icon: Icons.check_circle,
      duration: duration ?? _duration,
      gravity: gravity ?? _gravity,
    );
  }

  /// 显示错误提示
  /// 
  /// 红色背景，白色文字，带错误图标
  static void showError(
    BuildContext context,
    String message, {
    Duration? duration,
    ToastGravity? gravity,
  }) {
    _showToast(
      context: context,
      message: message,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      icon: Icons.error,
      duration: duration ?? _duration,
      gravity: gravity ?? _gravity,
    );
  }

  /// 显示警告提示
  /// 
  /// 橙色背景，白色文字，带警告图标
  static void showWarning(
    BuildContext context,
    String message, {
    Duration? duration,
    ToastGravity? gravity,
  }) {
    _showToast(
      context: context,
      message: message,
      backgroundColor: Colors.orange,
      textColor: Colors.white,
      icon: Icons.warning,
      duration: duration ?? _duration,
      gravity: gravity ?? _gravity,
    );
  }

  /// 显示信息提示
  /// 
  /// 蓝色背景，白色文字，带信息图标
  static void showInfo(
    BuildContext context,
    String message, {
    Duration? duration,
    ToastGravity? gravity,
  }) {
    _showToast(
      context: context,
      message: message,
      backgroundColor: Colors.blue,
      textColor: Colors.white,
      icon: Icons.info,
      duration: duration ?? _duration,
      gravity: gravity ?? _gravity,
    );
  }

  /// 显示自定义 Toast
  static void showCustom(
    BuildContext context, {
    required String message,
    Color backgroundColor = Colors.grey,
    Color textColor = Colors.white,
    IconData? icon,
    Duration? duration,
    ToastGravity? gravity,
  }) {
    _showToast(
      context: context,
      message: message,
      backgroundColor: backgroundColor,
      textColor: textColor,
      icon: icon,
      duration: duration ?? _duration,
      gravity: gravity ?? _gravity,
    );
  }

  /// 内部 Toast 实现
  static void _showToast({
    required BuildContext context,
    required String message,
    required Color backgroundColor,
    required Color textColor,
    IconData? icon,
    Duration? duration,
    ToastGravity? gravity,
  }) {
    // 移除已有的 Overlay
    _removeExistingToast();

    // 创建新的 Overlay
    final OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: _getTopPosition(context, gravity ?? _gravity),
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: backgroundColor.withOpacity(0.9),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    color: textColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // 显示 Overlay
    Overlay.of(context).insert(overlayEntry);

    // 自动移除
    Future.delayed(duration ?? _duration, () {
      overlayEntry.remove();
    });
  }

  /// 获取 Toast 距离顶部的位置
  static double _getTopPosition(BuildContext context, ToastGravity gravity) {
    final screenHeight = MediaQuery.of(context).size.height;
    switch (gravity) {
      case ToastGravity.TOP:
        return MediaQuery.of(context).padding.top + 16;
      case ToastGravity.CENTER:
        return (screenHeight / 2) - 50;
      case ToastGravity.BOTTOM:
        return screenHeight - MediaQuery.of(context).padding.bottom - 100;
      default:
        return screenHeight - MediaQuery.of(context).padding.bottom - 100;
    }
  }

  /// 移除已存在的 Toast（避免重叠）
  static void _removeExistingToast() {
    // 在实际实现中，可以通过 Overlay 管理来移除旧的 Toast
    // 这里简化处理
  }
}

/// Toast 位置枚举
enum ToastGravity {
  TOP,
  CENTER,
  BOTTOM,
}
