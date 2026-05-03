/// 添加程序对话框
///
/// 添加程序对话框（名称/路径/图标/分类/描述）。
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';

import '../bloc/program_bloc.dart';
import '../models/program.dart';
import '../models/category.dart';
import '../../../core/theme/app_spacing.dart';

/// 添加程序对话框
class AddProgramDialog extends StatefulWidget {
  /// 编辑模式下的程序信息
  final ProgramInfo? editingProgram;

  const AddProgramDialog({super.key, this.editingProgram});

  @override
  State<AddProgramDialog> createState() => _AddProgramDialogState();
}

class _AddProgramDialogState extends State<AddProgramDialog> {
  late TextEditingController _nameController;
  late TextEditingController _pathController;
  late TextEditingController _iconController;
  late TextEditingController _descriptionController;
  late TextEditingController _versionController;
  late TextEditingController _sourceDirController;
  String _selectedCategory = 'other';
  bool _isEnabled = true;

  final _uuid = const Uuid();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final p = widget.editingProgram;
    _nameController = TextEditingController(text: p?.name ?? '');
    _pathController = TextEditingController(text: p?.path ?? '');
    _iconController = TextEditingController(text: p?.icon ?? '');
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _versionController = TextEditingController(text: p?.version ?? '');
    _sourceDirController = TextEditingController(text: p?.sourceDir ?? '');
    _selectedCategory = p?.category ?? 'other';
    _isEnabled = p?.enabled ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pathController.dispose();
    _iconController.dispose();
    _descriptionController.dispose();
    _versionController.dispose();
    _sourceDirController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.editingProgram != null;
    final categories = DefaultCategories.defaults
        .where((c) => c.id != 'all')
        .toList();

    return AlertDialog(
      title: Text(isEditing ? '编辑程序' : '添加程序'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 程序名称
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: '程序名称 *',
                    hintText: '输入程序名称',
                    prefixIcon: Icon(Icons.label_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '请输入程序名称';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                // 程序路径
                TextFormField(
                  controller: _pathController,
                  decoration: InputDecoration(
                    labelText: '程序路径 *',
                    hintText: '输入或选择程序路径',
                    prefixIcon: const Icon(Icons.folder_open),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.more_horiz),
                      tooltip: '浏览',
                      onPressed: _pickFile,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '请输入程序路径';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                // 图标名称
                TextFormField(
                  controller: _iconController,
                  decoration: const InputDecoration(
                    labelText: '图标名称',
                    hintText: 'Material Icon 名称（可选）',
                    prefixIcon: Icon(Icons.star_outline),
                    helperText: '如: calculate, edit_note, terminal',
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                // 分类
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: '分类',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: categories
                      .map((c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.name),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedCategory = value);
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                // 描述
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: '描述',
                    hintText: '输入程序描述（可选）',
                    prefixIcon: Icon(Icons.description_outlined),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: AppSpacing.md),
                // 版本号
                TextFormField(
                  controller: _versionController,
                  decoration: const InputDecoration(
                    labelText: '版本号',
                    hintText: '如: 1.0.0',
                    prefixIcon: Icon(Icons.info_outline),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                // 源代码目录
                TextFormField(
                  controller: _sourceDirController,
                  decoration: InputDecoration(
                    labelText: '源代码目录',
                    hintText: '选择源代码目录（可选）',
                    prefixIcon: const Icon(Icons.source_outlined),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.more_horiz),
                      tooltip: '浏览',
                      onPressed: _pickSourceDir,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                // 启用开关
                SwitchListTile(
                  title: const Text('启用'),
                  subtitle: Text(
                    _isEnabled ? '程序可正常使用' : '程序已禁用',
                    style: theme.textTheme.bodySmall,
                  ),
                  value: _isEnabled,
                  onChanged: (value) {
                    setState(() => _isEnabled = value);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: _saveProgram,
          child: Text(isEditing ? '保存' : '添加'),
        ),
      ],
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['exe', 'lnk', 'bat', 'cmd', 'ps1'],
      dialogTitle: '选择程序文件',
    );

    if (result != null && result.files.single.path != null) {
      final filePath = result.files.single.path!;
      _pathController.text = filePath;

      // 如果名称为空，自动填充
      if (_nameController.text.isEmpty) {
        final fileName = filePath
            .split(Platform.pathSeparator)
            .last
            .replaceAll(RegExp(r'\.(exe|lnk|bat|cmd|ps1)$', caseSensitive: false), '');
        _nameController.text = fileName;
      }
    }
  }

  Future<void> _pickSourceDir() async {
    final result = await FilePicker.platform.getDirectoryPath(
      dialogTitle: '选择源代码目录',
    );

    if (result != null) {
      _sourceDirController.text = result;
    }
  }

  void _saveProgram() {
    if (!_formKey.currentState!.validate()) return;

    final program = ProgramInfo(
      id: widget.editingProgram?.id ?? _uuid.v4(),
      name: _nameController.text.trim(),
      path: _pathController.text.trim(),
      icon: _iconController.text.trim(),
      category: _selectedCategory,
      description: _descriptionController.text.trim(),
      version: _versionController.text.trim(),
      sourceDir: _sourceDirController.text.trim(),
      enabled: _isEnabled,
      isToolLibrary: widget.editingProgram?.isToolLibrary ?? false,
      useCount: widget.editingProgram?.useCount ?? 0,
      lastUsed: widget.editingProgram?.lastUsed ?? '',
      createdAt: widget.editingProgram?.createdAt ?? DateTime.now().toIso8601String(),
    );

    if (widget.editingProgram != null) {
      context.read<ProgramBloc>().add(ProgramUpdated(program));
    } else {
      context.read<ProgramBloc>().add(ProgramAdded(program));
    }

    Navigator.pop(context);
  }
}
