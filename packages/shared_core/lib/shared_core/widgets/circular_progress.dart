/// 圆形进度条组件
///
/// 使用弧形进度条显示百分比，支持平滑过渡动画。
/// 对应 Python CustomTkinter 的 CircularProgress 组件。
library;

import 'package:flutter/material.dart';

/// 圆形进度条组件
///
/// 支持平滑动画过渡的圆形进度指示器。
/// 可选择是否显示中心百分比标签。
class CircularProgress extends StatefulWidget {
  /// 圆形直径大小
  final double size;

  /// 进度条宽度
  final double strokeWidth;

  /// 当前进度 (0.0-1.0)
  final double progress;

  /// 是否显示中心标签
  final bool showLabel;

  /// 标签格式化字符串（支持 {value} 占位符）
  final String? labelFormat;

  /// 起始角度（默认从顶部开始 -90 度）
  final double startAngle;

  /// 动画时长
  final Duration animationDuration;

  const CircularProgress({
    super.key,
    this.size = 80,
    this.strokeWidth = 6,
    this.progress = 0.0,
    this.showLabel = true,
    this.labelFormat,
    this.startAngle = -90,
    this.animationDuration = const Duration(milliseconds: 400),
  });

  @override
  State<CircularProgress> createState() => _CircularProgressState();
}

class _CircularProgressState extends State<CircularProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  double _lastProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _lastProgress = widget.progress;
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _animation = Tween<double>(
      begin: _lastProgress,
      end: _lastProgress,
    ).animate(_animationController);
  }

  @override
  void didUpdateWidget(CircularProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.progress != oldWidget.progress) {
      _lastProgress = _animation.value;
      _animation = Tween<double>(
        begin: _lastProgress,
        end: widget.progress,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeOutCubic,
        ),
      );
      _animationController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final currentProgress = _animation.value.clamp(0.0, 1.0);

        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _ArcProgressPainter(
                  progress: currentProgress,
                  strokeWidth: widget.strokeWidth,
                  startAngle: widget.startAngle,
                  trackColor: colorScheme.surfaceContainerHighest,
                  progressColor: colorScheme.primary,
                ),
              ),
              if (widget.showLabel)
                Text(
                  widget.labelFormat?.replaceAll(
                        '{value}',
                        '${(currentProgress * 100).toInt()}%',
                      ) ??
                      '${(currentProgress * 100).toInt()}%',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: widget.size * 0.22,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// 弧形进度绘制器
class _ArcProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final double startAngle;
  final Color trackColor;
  final Color progressColor;

  _ArcProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.startAngle,
    required this.trackColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // 绘制背景轨道
    paint.color = trackColor;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      _degreesToRadians(startAngle),
      2 * 3.1415926535897932,
      false,
      paint,
    );

    // 绘制进度弧线
    if (progress > 0) {
      paint.color = progressColor;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        _degreesToRadians(startAngle),
        _degreesToRadians(progress * 360),
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ArcProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.startAngle != startAngle ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor;
  }

  double _degreesToRadians(double degrees) {
    return degrees * 3.1415926535897932 / 180;
  }
}
