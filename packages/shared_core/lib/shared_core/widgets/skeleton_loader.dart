/// 骨架屏加载组件
///
/// 闪烁动画模拟内容加载状态。
/// 对应 Python CustomTkinter 的 SkeletonLoader 组件。
library;

import 'package:flutter/material.dart';

/// 骨架屏加载组件
///
/// 显示闪烁动画的占位符，用于模拟内容加载状态。
/// 支持文本行占位和头像占位。
class SkeletonLoader extends StatefulWidget {
  /// 文本行数
  final int lines;

  /// 每行高度
  final double lineHeight;

  /// 行间距
  final double spacing;

  /// 是否显示头像圆形占位符
  final bool showAvatar;

  /// 头像大小
  final double avatarSize;

  /// 闪烁动画时长
  final Duration animationDuration;

  const SkeletonLoader({
    super.key,
    this.lines = 3,
    this.lineHeight = 16,
    this.spacing = 8,
    this.showAvatar = false,
    this.avatarSize = 40,
    this.animationDuration = const Duration(milliseconds: 1500),
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 根据主题计算骨架颜色
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final opacity = _animation.value;
        final color = Color.lerp(baseColor, Colors.white, opacity * 0.3);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 头像占位符
                if (widget.showAvatar) ...[
                  Container(
                    width: widget.avatarSize,
                    height: widget.avatarSize,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                // 文本行占位符
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(
                      widget.lines,
                      (index) {
                        final isLast = index == widget.lines - 1;
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index < widget.lines - 1
                                ? widget.spacing
                                : 0,
                          ),
                          child: Container(
                            height: widget.lineHeight,
                            width: isLast ? 120 : double.infinity,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

/// 骨架屏列表占位符
///
/// 用于替换整个列表加载状态的占位符。
class SkeletonList extends StatelessWidget {
  /// 列表项数量
  final int itemCount;

  /// 是否显示头像
  final bool showAvatar;

  const SkeletonList({
    super.key,
    this.itemCount = 5,
    this.showAvatar = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return SkeletonLoader(
          lines: 2,
          showAvatar: showAvatar,
        );
      },
    );
  }
}
