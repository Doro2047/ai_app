/// 工具提示组件
///
/// 延迟 500ms 显示的轻量级提示浮层。
/// 对应 Python CustomTkinter 的 Tooltip 组件。
library;

import 'dart:async';

import 'package:flutter/material.dart';

/// 应用工具提示组件
///
/// 在组件上悬停 500ms 后显示提示信息。
/// 支持自定义位置、样式和延迟时间。
class AppTooltip extends StatefulWidget {
  /// 子组件
  final Widget child;

  /// 提示文本
  final String message;

  /// 显示延迟时间
  final Duration showDelay;

  /// 提示框最大宽度
  final double maxWidth;

  /// 提示框背景色（默认使用主题色）
  final Color? backgroundColor;

  /// 提示框文本颜色
  final Color? textColor;

  /// 提示框圆角
  final double borderRadius;

  /// 提示框内边距
  final EdgeInsets padding;

  const AppTooltip({
    super.key,
    required this.child,
    required this.message,
    this.showDelay = const Duration(milliseconds: 500),
    this.maxWidth = 250,
    this.backgroundColor,
    this.textColor,
    this.borderRadius = 6,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
  });

  @override
  State<AppTooltip> createState() => _AppTooltipState();
}

class _AppTooltipState extends State<AppTooltip> {
  OverlayEntry? _overlayEntry;
  Timer? _showTimer;
  final GlobalKey _targetKey = GlobalKey();

  void _onHoverEnter() {
    _showTimer?.cancel();
    _showTimer = Timer(widget.showDelay, _showTooltip);
  }

  void _onHoverExit() {
    _showTimer?.cancel();
    _hideTooltip();
  }

  void _showTooltip() {
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => _TooltipPosition(
        targetKey: _targetKey,
        child: _TooltipBox(
          message: widget.message,
          maxWidth: widget.maxWidth,
          backgroundColor:
              widget.backgroundColor ??
              Theme.of(context).colorScheme.surfaceContainerHighest,
          textColor: widget.textColor ?? Theme.of(context).colorScheme.onSurface,
          borderRadius: widget.borderRadius,
          padding: widget.padding,
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideTooltip() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _showTimer?.cancel();
    _hideTooltip();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      key: _targetKey,
      onEnter: (_) => _onHoverEnter(),
      onExit: (_) => _onHoverExit(),
      child: widget.child,
    );
  }
}

/// 提示框定位组件
class _TooltipPosition extends StatefulWidget {
  final GlobalKey targetKey;
  final Widget child;

  const _TooltipPosition({
    required this.targetKey,
    required this.child,
  });

  @override
  State<_TooltipPosition> createState() => _TooltipPositionState();
}

class _TooltipPositionState extends State<_TooltipPosition> {
  @override
  Widget build(BuildContext context) {
    final renderBox = widget.targetKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return const SizedBox.shrink();

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    return Positioned(
      left: position.dx + size.width / 2,
      top: position.dy - 8,
      child: Transform.translate(
        offset: const Offset(-0.5, -1.0),
        child: FractionalTranslation(
          translation: const Offset(-0.5, -1.0),
          child: FadeTransition(
            opacity: const AlwaysStoppedAnimation(1.0),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// 提示框内部组件
class _TooltipBox extends StatelessWidget {
  final String message;
  final double maxWidth;
  final Color backgroundColor;
  final Color textColor;
  final double borderRadius;
  final EdgeInsets padding;

  const _TooltipBox({
    required this.message,
    required this.maxWidth,
    required this.backgroundColor,
    required this.textColor,
    required this.borderRadius,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: textColor,
                fontSize: 12,
              ),
        ),
      ),
    );
  }
}
