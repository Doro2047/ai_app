/// 日志面板组件
///
/// 使用等宽字体显示日志消息，支持日志级别颜色区分。
/// 对应 Python CustomTkinter 的 LogPanel 组件。
library;

import 'package:flutter/material.dart';

/// 日志级别
enum LogLevel {
  /// 调试信息
  debug,
  /// 普通信息
  info,
  /// 警告
  warn,
  /// 错误
  error,
}

/// 日志条目
class LogEntry {
  /// 时间戳
  final DateTime timestamp;

  /// 日志消息
  final String message;

  /// 日志级别
  final LogLevel level;

  const LogEntry({
    required this.timestamp,
    required this.message,
    this.level = LogLevel.info,
  });

  /// 格式化时间
  String get formattedTime {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final second = timestamp.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }
}

/// 日志面板组件
///
/// 显示带时间戳和级别颜色的日志消息。
/// 使用等宽字体（monospace）以确保对齐。
class LogPanel extends StatefulWidget {
  /// 面板标题
  final String? title;

  /// 面板高度
  final double? height;

  /// 最小行数
  final int minLines;

  /// 最大行数（超过后滚动）
  final int maxLines;

  /// 是否显示时间戳
  final bool showTimestamp;

  /// 是否显示级别标签
  final bool showLevel;

  /// 最大日志条目数（超出时自动移除最旧的）
  final int? maxEntries;

  const LogPanel({
    super.key,
    this.title,
    this.height,
    this.minLines = 5,
    this.maxLines = 20,
    this.showTimestamp = true,
    this.showLevel = true,
    this.maxEntries = 1000,
  });

  @override
  State<LogPanel> createState() => _LogPanelState();
}

class _LogPanelState extends State<LogPanel> {
  final List<LogEntry> _entries = [];
  final ScrollController _scrollController = ScrollController();

  /// 添加日志条目
  void add(String message, {LogLevel level = LogLevel.info}) {
    if (!mounted) return;

    setState(() {
      _entries.add(LogEntry(
        timestamp: DateTime.now(),
        message: message,
        level: level,
      ));

      // 限制日志条目数量
      if (widget.maxEntries != null && _entries.length > widget.maxEntries!) {
        _entries.removeAt(0);
      }
    });

    // 自动滚动到底部
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  /// 清空日志
  void clear() {
    if (!mounted) return;
    setState(() {
      _entries.clear();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Color _getLevelColor(LogLevel level) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    switch (level) {
      case LogLevel.debug:
        return theme.textTheme.bodySmall?.color ?? colorScheme.outline;
      case LogLevel.info:
        return colorScheme.onSurface;
      case LogLevel.warn:
        return const Color(0xFFF59E0B);
      case LogLevel.error:
        return colorScheme.error;
    }
  }

  String _getLevelText(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 'DEBUG';
      case LogLevel.info:
        return 'INFO';
      case LogLevel.warn:
        return 'WARN';
      case LogLevel.error:
        return 'ERROR';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题（可选）
        if (widget.title != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              widget.title!,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: colorScheme.outlineVariant,
          ),
        ],
        // 日志内容
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: colorScheme.outlineVariant.withOpacity(0.5),
              ),
            ),
            constraints: widget.height != null
                ? BoxConstraints.tightFor(height: widget.height)
                : null,
            child: _entries.isEmpty
                ? Center(
                    child: Text(
                      '暂无日志',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8),
                    itemCount: _entries.length,
                    itemBuilder: (context, index) {
                      final entry = _entries[index];
                      return _LogEntryWidget(
                        entry: entry,
                        showTimestamp: widget.showTimestamp,
                        showLevel: widget.showLevel,
                        levelColor: _getLevelColor(entry.level),
                        levelText: _getLevelText(entry.level),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}

/// 日志条目显示组件
class _LogEntryWidget extends StatelessWidget {
  final LogEntry entry;
  final bool showTimestamp;
  final bool showLevel;
  final Color levelColor;
  final String levelText;

  const _LogEntryWidget({
    required this.entry,
    required this.showTimestamp,
    required this.showLevel,
    required this.levelColor,
    required this.levelText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 时间戳
          if (showTimestamp)
            Text(
              '[${entry.formattedTime}]',
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                fontSize: 12,
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
            ),
          if (showTimestamp) const SizedBox(width: 6),
          // 级别
          if (showLevel)
            Text(
              '[$levelText]',
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: levelColor,
              ),
            ),
          if (showLevel) const SizedBox(width: 6),
          // 消息
          Expanded(
            child: Text(
              entry.message,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                fontSize: 12,
                color: levelColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
