/// 应用 Toast 通知组件
///
/// 支持滑入滑出动画的轻量级通知提示。
/// 对应 Python CustomTkinter 的 Toast 组件。
library;

import 'package:flutter/material.dart';

/// Toast 通知类型
enum AppToastType {
  /// 信息提示
  info,
  /// 成功提示
  success,
  /// 警告提示
  warning,
  /// 错误提示
  error,
}

/// 应用 Toast 通知组件
///
/// 显示在屏幕右上角，支持滑入滑出动画。
/// 点击可手动关闭，自动关闭默认 3 秒。
class AppToast {
  AppToast._();

  /// 默认显示时长
  static const Duration defaultDuration = Duration(seconds: 3);

  /// 显示 Toast 通知
  ///
  /// [context] BuildContext 上下文
  /// [message] 提示消息
  /// [type] 通知类型
  /// [duration] 显示时长
  static void show(
    BuildContext context, {
    required String message,
    AppToastType type = AppToastType.info,
    Duration duration = defaultDuration,
  }) {
    final overlay = Overlay.of(context);
    late final OverlayEntry toastEntry;
    toastEntry = OverlayEntry(
      builder: (context) => _AppToastWidget(
        message: message,
        type: type,
        duration: duration,
        onDismiss: () => toastEntry.remove(),
      ),
    );

    overlay.insert(toastEntry);
  }
}

/// Toast 内部实现组件
class _AppToastWidget extends StatefulWidget {
  final String message;
  final AppToastType type;
  final Duration duration;
  final VoidCallback onDismiss;

  const _AppToastWidget({
    required this.message,
    required this.type,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_AppToastWidget> createState() => _AppToastWidgetState();
}

class _AppToastWidgetState extends State<_AppToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();

    // 自动关闭
    Future.delayed(widget.duration, _dismissWithAnimation);
  }

  Future<void> _dismissWithAnimation() async {
    await _animationController.reverse();
    if (mounted) {
      widget.onDismiss();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getBackgroundColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (widget.type) {
      case AppToastType.info:
        return colorScheme.primary;
      case AppToastType.success:
        return colorScheme.tertiary;
      case AppToastType.warning:
        return const Color(0xFFF59E0B);
      case AppToastType.error:
        return colorScheme.error;
    }
  }

  IconData _getIcon() {
    switch (widget.type) {
      case AppToastType.info:
        return Icons.info_outline;
      case AppToastType.success:
        return Icons.check_circle_outline;
      case AppToastType.warning:
        return Icons.warning_amber_outlined;
      case AppToastType.error:
        return Icons.error_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 20,
      right: 20,
      child: SafeArea(
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Material(
              color: Colors.transparent,
              child: GestureDetector(
                onTap: _dismissWithAnimation,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: _getBackgroundColor(context),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getIcon(),
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          widget.message,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
