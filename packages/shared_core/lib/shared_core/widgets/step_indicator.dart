/// 步骤指示器组件
///
/// 显示多步骤流程的当前进度。
/// 对应 Python CustomTkinter 的 StepIndicator 组件。
library;

import 'package:flutter/material.dart';

/// 步骤指示器组件
///
/// 显示步骤圆圈和连接线，已完成的步骤显示勾选标记。
class StepIndicator extends StatefulWidget {
  /// 步骤名称列表
  final List<String> steps;

  /// 当前步骤索引（从 0 开始）
  final int currentStep;

  /// 步骤变化回调
  final ValueChanged<int>? onStepChanged;

  /// 步骤圆圈大小
  final double stepSize;

  /// 连接线高度
  final double connectorHeight;

  const StepIndicator({
    super.key,
    required this.steps,
    this.currentStep = 0,
    this.onStepChanged,
    this.stepSize = 32,
    this.connectorHeight = 2,
  });

  @override
  State<StepIndicator> createState() => _StepIndicatorState();
}

class _StepIndicatorState extends State<StepIndicator> {
  late int _currentStep;

  @override
  void initState() {
    super.initState();
    _currentStep = widget.currentStep.clamp(0, widget.steps.length - 1);
  }

  @override
  void didUpdateWidget(StepIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentStep != oldWidget.currentStep) {
      _currentStep = widget.currentStep.clamp(0, widget.steps.length - 1);
    }
  }

  /// 前进到下一步
  bool nextStep() {
    if (_currentStep < widget.steps.length - 1) {
      setState(() {
        _currentStep++;
      });
      widget.onStepChanged?.call(_currentStep);
      return true;
    }
    return false;
  }

  /// 后退到上一步
  bool prevStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      widget.onStepChanged?.call(_currentStep);
      return true;
    }
    return false;
  }

  /// 重置到第一步
  void reset() {
    setState(() {
      _currentStep = 0;
    });
    widget.onStepChanged?.call(0);
  }

  /// 完成所有步骤
  void complete() {
    setState(() {
      _currentStep = widget.steps.length - 1;
    });
    widget.onStepChanged?.call(_currentStep);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final totalSteps = widget.steps.length;

    return Column(
      children: [
        // 顶部：步骤圆圈和连接线
        SizedBox(
          height: widget.stepSize,
          child: Row(
            children: List.generate(
              totalSteps * 2 - 1,
              (index) {
                if (index.isEven) {
                  // 步骤圆圈
                  final stepIndex = index ~/ 2;
                  return _StepCircle(
                    index: stepIndex,
                    currentStep: _currentStep,
                    size: widget.stepSize,
                  );
                } else {
                  // 连接线
                  final connectorIndex = index ~/ 2;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Container(
                        height: widget.connectorHeight,
                        decoration: BoxDecoration(
                          color: connectorIndex < _currentStep
                              ? colorScheme.tertiary
                              : colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        // 底部：步骤名称
        SizedBox(
          height: 40,
          child: Row(
            children: List.generate(
              totalSteps,
              (index) => Expanded(
                child: Text(
                  widget.steps[index],
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: _getStepNameColor(index, colorScheme),
                    fontWeight: index == _currentStep
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getStepNameColor(int index, ColorScheme colorScheme) {
    if (index == _currentStep) {
      return colorScheme.primary;
    } else if (index < _currentStep) {
      return colorScheme.tertiary;
    } else {
      return colorScheme.onSurfaceVariant;
    }
  }
}

/// 步骤圆圈组件
class _StepCircle extends StatelessWidget {
  final int index;
  final int currentStep;
  final double size;

  const _StepCircle({
    required this.index,
    required this.currentStep,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final isCompleted = index < currentStep;
    final isCurrent = index == currentStep;

    Color bgColor;
    Color textColor;

    if (isCompleted) {
      bgColor = colorScheme.tertiary;
      textColor = colorScheme.onTertiary;
    } else if (isCurrent) {
      bgColor = colorScheme.primary;
      textColor = colorScheme.onPrimary;
    } else {
      bgColor = colorScheme.surfaceContainerHighest;
      textColor = colorScheme.onSurfaceVariant;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: isCompleted
            ? const Icon(Icons.check, size: 16)
            : Text(
                '${index + 1}',
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: size * 0.35,
                ),
              ),
      ),
    );
  }
}
