/// 自定义信息编辑对话框
///
/// 用户可自定义的文本信息条目编辑。
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../models/custom_info.dart';
import '../repositories/custom_info_repository.dart';
import '../../../core/theme/app_spacing.dart';

/// 自定义信息对话框
class CustomInfoDialog extends StatefulWidget {
  /// 编辑模式下的自定义信息
  final CustomInfo? editingInfo;

  const CustomInfoDialog({super.key, this.editingInfo});

  @override
  State<CustomInfoDialog> createState() => _CustomInfoDialogState();
}

class _CustomInfoDialogState extends State<CustomInfoDialog> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  final _uuid = const Uuid();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.editingInfo?.title ?? '');
    _contentController = TextEditingController(text: widget.editingInfo?.content ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.editingInfo != null;

    return AlertDialog(
      title: Text(isEditing ? '编辑信息' : '添加信息'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '标题 *',
                  hintText: '输入信息标题',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入标题';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: '内容',
                  hintText: '输入信息内容',
                  prefixIcon: Icon(Icons.notes),
                  alignLabelWithHint: true,
                ),
                maxLines: 6,
                minLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: _saveInfo,
          child: Text(isEditing ? '保存' : '添加'),
        ),
      ],
    );
  }

  Future<void> _saveInfo() async {
    if (!_formKey.currentState!.validate()) return;

    final repo = context.read<CustomInfoRepository>();
    final info = CustomInfo(
      id: widget.editingInfo?.id ?? _uuid.v4(),
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      createdAt: widget.editingInfo?.createdAt ?? DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );

    if (widget.editingInfo != null) {
      await repo.update(info);
    } else {
      await repo.add(info);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }
}
