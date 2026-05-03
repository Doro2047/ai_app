import 'package:flutter/material.dart';

/// 共享组件导出
class SharedWidgets {
  SharedWidgets._();
}

/// 通用间距组件
class Gap extends StatelessWidget {
  final double width;
  final double height;

  const Gap({super.key, this.width = 0, this.height = 0});

  const Gap.width(double w, {Key? key}) : this(key: key, width: w, height: 0);

  const Gap.height(double h, {Key? key}) : this(key: key, width: 0, height: h);

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: width, height: height);
  }
}

/// 通用卡片组件（简化版）
/// 注意：如需更丰富的卡片功能，请使用 card.dart 中的 AppCard
class SimpleAppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const SimpleAppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: card,
      );
    }
    return card;
  }
}
