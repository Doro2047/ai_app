/// 路径选择器组件
///
/// 提供路径输入和文件浏览功能。
/// 对应 Python CustomTkinter 的 PathSelector 组件。
library;

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

/// 路径选择器组件
///
/// 包含路径输入框和浏览按钮，支持文件/文件夹选择。
class PathSelector extends StatefulWidget {
  /// 标签文本
  final String? label;

  /// 提示文本
  final String? hintText;

  /// 初始路径值
  final String? initialValue;

  /// 是否只允许选择文件夹
  final bool selectFolder;

  /// 允许选择的文件类型（selectFolder 为 false 时有效）
  final List<String>? allowedExtensions;

  /// 路径变化回调
  final ValueChanged<String>? onChanged;

  /// 验证器
  final String? Function(String?)? validator;

  /// 是否只读
  final bool readOnly;

  /// 输入框装饰
  final InputDecoration? decoration;

  const PathSelector({
    super.key,
    this.label,
    this.hintText,
    this.initialValue,
    this.selectFolder = false,
    this.allowedExtensions,
    this.onChanged,
    this.validator,
    this.readOnly = false,
    this.decoration,
  });

  @override
  State<PathSelector> createState() => _PathSelectorState();
}

class _PathSelectorState extends State<PathSelector> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    widget.onChanged?.call(_controller.text);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _browse() async {
    String? path;

    if (widget.selectFolder) {
      path = await FilePicker.platform.getDirectoryPath();
    } else {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: widget.allowedExtensions,
        allowMultiple: false,
      );
      path = result?.files.single.path;
    }

    if (path != null && mounted) {
      _controller.text = path;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              widget.label!,
              style: theme.textTheme.labelLarge,
            ),
          ),
        ],
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _controller,
                readOnly: widget.readOnly,
                decoration: widget.decoration ??
                    InputDecoration(
                      hintText: widget.hintText ?? '请选择路径',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                validator: widget.validator,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 48,
              child: FilledButton.tonalIcon(
                onPressed: _browse,
                icon: const Icon(Icons.folder_open, size: 18),
                label: const Text('浏览'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 获取当前路径值
  String get value => _controller.text;

  /// 设置路径值
  void setValue(String value) {
    _controller.text = value;
  }
}
