/// 进度对话框组件
///
/// 显示处理进度，支持暂停/取消操作。
/// 对应 Python CustomTkinter 的 ProgressDialog 组件。
library;

import 'package:flutter/material.dart';

/// 进度对话框操作回调
typedef ProgressDialogCallback = void Function();

/// 进度对话框状态
enum ProgressDialogState {
  /// 正在处理
  running,
  /// 已暂停
  paused,
  /// 已完成
  completed,
  /// 已取消
  cancelled,
}

/// 进度对话框控制器
class ProgressDialogController extends ChangeNotifier {
  ProgressDialogState _state = ProgressDialogState.running;
  int _current = 0;
  final int _total = 100;
  String _statusText = '正在处理...';

  ProgressDialogState get state => _state;
  int get current => _current;
  int get total => _total;
  double get progress => _total > 0 ? _current / _total : 0.0;
  String get statusText => _statusText;
  bool get isPaused => _state == ProgressDialogState.paused;
  bool get isCancelled => _state == ProgressDialogState.cancelled;
  bool get isCompleted => _state == ProgressDialogState.completed;
  bool get isRunning => _state == ProgressDialogState.running;

  void updateProgress(int current, {String? status}) {
    if (isRunning) {
      _current = current.clamp(0, _total);
      if (status != null) {
        _statusText = status;
      }
      notifyListeners();
    }
  }

  void pause() {
    if (isRunning) {
      _state = ProgressDialogState.paused;
      _statusText = '已暂停';
      notifyListeners();
    }
  }

  void resume() {
    if (isPaused) {
      _state = ProgressDialogState.running;
      _statusText = '正在处理...';
      notifyListeners();
    }
  }

  void cancel() {
    if (!isCompleted && !isCancelled) {
      _state = ProgressDialogState.cancelled;
      _statusText = '已取消';
      notifyListeners();
    }
  }

  void complete({String? message}) {
    _state = ProgressDialogState.completed;
    _current = _total;
    _statusText = message ?? '已完成';
    notifyListeners();
  }
}

/// 进度对话框组件
///
/// 模态对话框，显示处理进度，支持暂停/取消按钮。
/// 包含进度条、状态文本和预计剩余时间。
class AppProgressDialog extends StatefulWidget {
  /// 对话框标题
  final String title;

  /// 总进度数
  final int total;

  /// 是否显示暂停按钮
  final bool showPause;

  /// 控制器
  final ProgressDialogController? controller;

  const AppProgressDialog({
    super.key,
    this.title = '处理中',
    this.total = 100,
    this.showPause = true,
    this.controller,
  });

  /// 显示进度对话框
  ///
  /// 返回控制器实例，可用于更新进度。
  static ProgressDialogController show(
    BuildContext context, {
    String title = '处理中',
    int total = 100,
    bool showPause = true,
  }) {
    final controller = ProgressDialogController();
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AppProgressDialog(
        title: title,
        total: total,
        showPause: showPause,
        controller: controller,
      ),
    );
    return controller;
  }

  @override
  State<AppProgressDialog> createState() => _AppProgressDialogState();
}

class _AppProgressDialogState extends State<AppProgressDialog>
    with SingleTickerProviderStateMixin {
  late ProgressDialogController _controller;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? ProgressDialogController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: _AnimationToggle(
                    isRunning: _controller.isRunning,
                    controller: _animationController,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 进度条
            ListenableBuilder(
              listenable: _controller,
              builder: (context, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 状态文本
                    Text(
                      _controller.statusText,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    // 进度条
                    LinearProgressIndicator(
                      value: _controller.progress,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _controller.isCompleted
                            ? theme.colorScheme.tertiary
                            : theme.colorScheme.primary,
                      ),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 8),
                    // 进度详情
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_controller.current} / ${_controller.total}',
                          style: theme.textTheme.bodySmall,
                        ),
                        Text(
                          '${(_controller.progress * 100).toInt()}%',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            // 按钮区域
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // 取消按钮
                TextButton(
                  onPressed: () {
                    _controller.cancel();
                    Navigator.of(context).pop();
                  },
                  child: const Text('取消'),
                ),
                const SizedBox(width: 8),
                // 暂停/继续按钮
                if (widget.showPause)
                  ListenableBuilder(
                    listenable: _controller,
                    builder: (context, _) {
                      return TextButton.icon(
                        onPressed: _controller.isRunning
                            ? _controller.pause
                            : _controller.isPaused
                                ? _controller.resume
                                : null,
                        icon: Icon(
                          _controller.isPaused ? Icons.play_arrow : Icons.pause,
                          size: 20,
                        ),
                        label: Text(_controller.isPaused ? '继续' : '暂停'),
                      );
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 内部动画切换组件
class _AnimationToggle extends StatelessWidget {
  final bool isRunning;
  final AnimationController controller;

  const _AnimationToggle({
    required this.isRunning,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (child, animation) {
        return ScaleTransition(
          scale: animation,
          child: child,
        );
      },
      child: isRunning
          ? const SizedBox(
              key: ValueKey('spinner'),
              child: CircularProgressIndicator(strokeWidth: 2.5),
            )
          : const Icon(
              Icons.check_circle_outline,
              key: ValueKey('check'),
              color: Colors.green,
            ),
    );
  }
}
