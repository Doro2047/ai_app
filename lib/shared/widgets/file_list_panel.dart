/// 文件列表面板组件
///
/// 显示文件列表，支持批量更新和多列显示。
/// 对应 Python CustomTkinter 的 FileListPanel 组件。
library;

import 'package:flutter/material.dart';

/// 文件列表项数据
class FileListItem {
  /// 唯一标识
  final String id;

  /// 文件名
  final String fileName;

  /// 文件路径
  final String path;

  /// 状态文本
  final String status;

  /// 状态类型（用于颜色区分）
  final FileItemStatus statusType;

  /// 附加数据
  final Map<String, dynamic>? extra;

  const FileListItem({
    required this.id,
    required this.fileName,
    required this.path,
    this.status = '',
    this.statusType = FileItemStatus.normal,
    this.extra,
  });

  FileListItem copyWith({
    String? fileName,
    String? path,
    String? status,
    FileItemStatus? statusType,
    Map<String, dynamic>? extra,
  }) {
    return FileListItem(
      id: id,
      fileName: fileName ?? this.fileName,
      path: path ?? this.path,
      status: status ?? this.status,
      statusType: statusType ?? this.statusType,
      extra: extra ?? this.extra,
    );
  }
}

/// 文件项状态
enum FileItemStatus {
  /// 普通
  normal,
  /// 成功
  success,
  /// 错误
  error,
  /// 警告
  warning,
  /// 处理中
  processing,
}

/// 文件列表面板组件
///
/// 支持批量更新、多列显示和状态颜色区分。
class FileListPanel extends StatefulWidget {
  /// 面板标题
  final String? title;

  /// 列表高度
  final double? height;

  /// 最小行数
  final int minLines;

  /// 是否显示选择框
  final bool selectable;

  /// 选中项变化回调
  final ValueChanged<List<FileListItem>>? onSelectionChanged;

  /// 列定义
  final List<DataColumn> columns;

  const FileListPanel({
    super.key,
    this.title,
    this.height,
    this.minLines = 8,
    this.selectable = false,
    this.onSelectionChanged,
    this.columns = const [],
  });

  @override
  State<FileListPanel> createState() => _FileListPanelState();
}

class _FileListPanelState extends State<FileListPanel> {
  final List<FileListItem> _items = [];
  final Set<int> _selectedIndices = {};

  /// 设置列表数据
  void setItems(List<FileListItem> items) {
    if (!mounted) return;
    setState(() {
      _items.clear();
      _items.addAll(items);
      _selectedIndices.clear();
    });
  }

  /// 批量更新列表项
  void batchUpdate(List<FileListItem> items) {
    if (!mounted) return;
    setState(() {
      _items.clear();
      _items.addAll(items);
    });
  }

  /// 添加单个项
  void addItem(FileListItem item) {
    if (!mounted) return;
    setState(() {
      _items.add(item);
    });
  }

  /// 更新指定 ID 的项
  void updateItem(String id, FileListItem newItem) {
    if (!mounted) return;
    setState(() {
      final index = _items.indexWhere((item) => item.id == id);
      if (index != -1) {
        _items[index] = newItem;
      }
    });
  }

  /// 清空所有项
  void clearItems() {
    if (!mounted) return;
    setState(() {
      _items.clear();
      _selectedIndices.clear();
    });
  }

  /// 获取选中项
  List<FileListItem> get selectedItems {
    return _selectedIndices.map((index) => _items[index]).toList();
  }

  void _onSelectedRowChanged(int? index) {
    if (index == null) return;
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        _selectedIndices.add(index);
      }
    });
    widget.onSelectionChanged?.call(selectedItems);
  }

  Color _getStatusColor(FileItemStatus status) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case FileItemStatus.normal:
        return colorScheme.onSurface;
      case FileItemStatus.success:
        return colorScheme.tertiary;
      case FileItemStatus.error:
        return colorScheme.error;
      case FileItemStatus.warning:
        return const Color(0xFFF59E0B);
      case FileItemStatus.processing:
        return colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题
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
        // 列表内容
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: colorScheme.outlineVariant.withOpacity(0.5),
            ),
          ),
          constraints:
              widget.height != null ? BoxConstraints.tightFor(height: widget.height) : null,
          child: _items.isEmpty
              ? Center(
                  child: Text(
                    '暂无文件',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                )
              : Theme(
                  data: theme.copyWith(
                    dataTableTheme: DataTableThemeData(
                      headingRowColor: WidgetStateProperty.all(
                        colorScheme.surfaceContainerHighest,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      showCheckboxColumn: widget.selectable,
                      columns: [
                        if (widget.selectable)
                          const DataColumn(label: SizedBox(width: 48)),
                        if (widget.columns.isNotEmpty)
                          ...widget.columns
                        else ...[
                          const DataColumn(label: Text('文件名')),
                          const DataColumn(label: Text('路径')),
                          const DataColumn(label: Text('状态')),
                        ],
                      ],
                      rows: List<DataRow>.generate(
                        _items.length,
                        (index) {
                          final item = _items[index];
                          return DataRow(
                            selected: _selectedIndices.contains(index),
                            onSelectChanged: widget.selectable
                                ? (_) => _onSelectedRowChanged(index)
                                : null,
                            cells: [
                              if (widget.columns.isNotEmpty)
                                ...widget.columns.map(
                                  (col) => DataCell(Text(item.extra?[col.label] ?? '')),
                                )
                              else ...[
                                DataCell(Text(item.fileName)),
                                DataCell(
                                  SizedBox(
                                    width: 200,
                                    child: Text(
                                      item.path,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    item.status,
                                    style: TextStyle(
                                      color: _getStatusColor(item.statusType),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
