library;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../app/app_di.dart';
import '../bloc/file_renamer_bloc.dart';
import '../models/rename_rule.dart';
import '../models/rename_preview.dart';

class FileRenamerPage extends StatelessWidget {
  const FileRenamerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<FileRenamerBloc>(),
      child: const _FileRenamerPageContent(),
    );
  }
}

class _FileRenamerPageContent extends StatefulWidget {
  const _FileRenamerPageContent();

  @override
  State<_FileRenamerPageContent> createState() => _FileRenamerPageContentState();
}

class _FileRenamerPageContentState extends State<_FileRenamerPageContent> {
  final ScrollController _logScrollController = ScrollController();
  String _directory = '';

  @override
  void dispose() {
    _logScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<FileRenamerBloc, FileRenamerState>(
      listener: (context, state) {
        if (_directory != state.directory) {
          setState(() {
            _directory = state.directory;
          });
        }

        if (state.logs.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_logScrollController.hasClients) {
              _logScrollController.jumpTo(
                _logScrollController.position.maxScrollExtent,
              );
            }
          });
        }

        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        }
      },
      builder: (context, state) {
        return AppScaffold(
          title: '批量重命名工具',
          statusBarText: _getStatusText(state),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildDirectorySection(theme, state),
                const SizedBox(height: 16),
                _buildRuleSection(theme, state),
                const SizedBox(height: 16),
                _buildActionButtons(theme, state),
                const SizedBox(height: 16),
                Expanded(
                  child: _buildPreviewSection(theme, state),
                ),
                const SizedBox(height: 16),
                _buildLogPanel(theme, state),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getStatusText(FileRenamerState state) {
    if (state.isExecuting) return '正在执行...';
    if (state.previews.isNotEmpty) {
      return '预览: ${state.changedCount} 将重命名, ${state.conflictCount} 冲突, ${state.errorCount} 错误';
    }
    if (state.files.isNotEmpty) {
      return '已扫描 ${state.files.length} 个文件';
    }
    return '就绪';
  }

  Widget _buildDirectorySection(ThemeData theme, FileRenamerState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: '目录选择',
          icon: Icons.folder_open,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  hintText: '请选择要重命名文件的目录',
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                readOnly: true,
                controller: TextEditingController(text: _directory),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 48,
              child: FilledButton.tonalIcon(
                onPressed: () async {
                  final path = await FilePicker.platform.getDirectoryPath();
                  if (path != null && mounted) {
                    context.read<FileRenamerBloc>().add(
                      DirectorySelected(path),
                    );
                  }
                },
                icon: const Icon(Icons.folder_open, size: 18),
                label: const Text('浏览'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Switch(
              value: state.isRecursive,
              onChanged: (value) {
                context.read<FileRenamerBloc>().add(
                  RecursiveToggled(value),
                );
              },
            ),
            const Text('递归扫描子目录'),
          ],
        ),
      ],
    );
  }

  Widget _buildRuleSection(ThemeData theme, FileRenamerState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: '重命名规则',
          icon: Icons.rule,
          trailing: IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 20),
            tooltip: '添加规则',
            onPressed: () async {
              final rule = await _showRuleDialog(context);
              if (rule != null && mounted) {
                context.read<FileRenamerBloc>().add(RuleAdded(rule));
              }
            },
          ),
        ),
        const SizedBox(height: 8),
        if (state.rules.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              '暂无规则，点击 + 添加重命名规则',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          )
        else
          ...state.rules.map((rule) => _buildRuleItem(theme, rule)),
      ],
    );
  }

  Future<RenameRule?> _showRuleDialog(
    BuildContext context, {
    RenameRule? initialRule,
  }) async {
    var selectedType = initialRule?.type ?? RenameRuleType.replace;
    final patternController = TextEditingController(text: initialRule?.pattern ?? '');
    final replacementController = TextEditingController(text: initialRule?.replacement ?? '');
    var enabled = initialRule?.enabled ?? true;
    final startIndexController = TextEditingController(
      text: initialRule?.startIndex?.toString() ?? '1',
    );

    return showDialog<RenameRule>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(initialRule == null ? '添加规则' : '编辑规则'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<RenameRuleType>(
                    initialValue: selectedType,
                    decoration: const InputDecoration(
                      labelText: '规则类型',
                      isDense: true,
                    ),
                    items: RenameRuleType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Row(
                          children: [
                            Icon(type.icon, size: 18),
                            const SizedBox(width: 8),
                            Text(type.displayName),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          selectedType = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildPatternField(selectedType, patternController, replacementController),
                  if (selectedType == RenameRuleType.sequence) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: startIndexController,
                      decoration: const InputDecoration(
                        labelText: '起始序号',
                        isDense: true,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('启用此规则'),
                    value: enabled,
                    onChanged: (value) {
                      setDialogState(() {
                        enabled = value;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () {
                if (patternController.text.trim().isEmpty &&
                    selectedType != RenameRuleType.sequence) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text('请输入匹配内容')),
                  );
                  return;
                }
                final rule = RenameRule(
                  id: initialRule?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  type: selectedType,
                  pattern: patternController.text.trim(),
                  replacement: replacementController.text.trim(),
                  enabled: enabled,
                  startIndex: selectedType == RenameRuleType.sequence
                      ? int.tryParse(startIndexController.text) ?? 1
                      : null,
                );
                Navigator.of(dialogContext).pop(rule);
              },
              child: Text(initialRule == null ? '添加' : '保存'),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildPatternField(
    RenameRuleType type,
    TextEditingController patternController,
    TextEditingController replacementController,
  ) {
    switch (type) {
      case RenameRuleType.prefix:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: patternController,
              decoration: const InputDecoration(
                labelText: '前缀内容',
                hintText: '添加到文件名前',
                isDense: true,
              ),
            ),
          ],
        );
      case RenameRuleType.suffix:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: patternController,
              decoration: const InputDecoration(
                labelText: '后缀内容',
                hintText: '添加到文件名后（扩展名前）',
                isDense: true,
              ),
            ),
          ],
        );
      case RenameRuleType.replace:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: patternController,
              decoration: const InputDecoration(
                labelText: '查找文本',
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: replacementController,
              decoration: const InputDecoration(
                labelText: '替换为',
                isDense: true,
              ),
            ),
          ],
        );
      case RenameRuleType.sequence:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: replacementController,
              decoration: const InputDecoration(
                labelText: '文件名前缀（可选）',
                hintText: '如 file_',
                isDense: true,
              ),
            ),
          ],
        );
      case RenameRuleType.extension:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: replacementController,
              decoration: const InputDecoration(
                labelText: '新扩展名',
                hintText: '如 .md',
                isDense: true,
              ),
            ),
          ],
        );
      case RenameRuleType.regex:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: patternController,
              decoration: const InputDecoration(
                labelText: '正则表达式',
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: replacementController,
              decoration: const InputDecoration(
                labelText: '替换为（支持 \$1, \$2 分组）',
                isDense: true,
              ),
            ),
          ],
        );
    }
  }

  Widget _buildRuleItem(ThemeData theme, RenameRule rule) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Switch(
              value: rule.enabled,
              onChanged: (value) {
                context.read<FileRenamerBloc>().add(
                  RuleUpdated(rule.copyWith(enabled: value)),
                );
              },
            ),
            const SizedBox(width: 8),
            Icon(rule.type.icon, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rule.type.displayName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getRuleDescription(rule),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 18),
              tooltip: '编辑',
              onPressed: () async {
                final edited = await _showRuleDialog(
                  context,
                  initialRule: rule,
                );
                if (edited != null && mounted) {
                  context.read<FileRenamerBloc>().add(RuleUpdated(edited));
                }
              },
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, size: 18, color: theme.colorScheme.error),
              tooltip: '删除',
              onPressed: () {
                context.read<FileRenamerBloc>().add(RuleRemoved(rule.id));
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getRuleDescription(RenameRule rule) {
    switch (rule.type) {
      case RenameRuleType.prefix:
        return '添加前缀: "${rule.pattern}"';
      case RenameRuleType.suffix:
        return '添加后缀: "${rule.pattern}"';
      case RenameRuleType.replace:
        return '查找 "${rule.pattern}" 替换为 "${rule.replacement}"';
      case RenameRuleType.sequence:
        return '序号从 ${rule.startIndex ?? 1} 开始${rule.replacement.isNotEmpty ? ', 前缀: "${rule.replacement}"' : ''}';
      case RenameRuleType.extension:
        return '修改扩展名为 "${rule.replacement}"';
      case RenameRuleType.regex:
        return '正则: ${rule.pattern} -> ${rule.replacement}';
    }
  }

  Widget _buildActionButtons(ThemeData theme, FileRenamerState state) {
    return Row(
      children: [
        FilledButton.tonalIcon(
          onPressed: state.directory.isEmpty || state.isExecuting
              ? null
              : () {
                  context.read<FileRenamerBloc>().add(
                    const ScanRequested(),
                  );
                },
          icon: const Icon(Icons.search, size: 18),
          label: const Text('扫描'),
        ),
        const SizedBox(width: 8),
        FilledButton.tonalIcon(
          onPressed: state.files.isEmpty || state.isExecuting
              ? null
              : () {
                  context.read<FileRenamerBloc>().add(
                    const PreviewRequested(),
                  );
                },
          icon: const Icon(Icons.preview, size: 18),
          label: const Text('预览'),
        ),
        const SizedBox(width: 8),
        FilledButton.icon(
          onPressed: state.previews.isEmpty || state.isExecuting
              ? null
              : () {
                  _showExecuteConfirm(context);
                },
          icon: const Icon(Icons.play_arrow, size: 18),
          label: const Text('执行'),
        ),
        const SizedBox(width: 8),
        if (state.isUndoAvailable)
          OutlinedButton.icon(
            onPressed: state.isExecuting
                ? null
                : () {
                    context.read<FileRenamerBloc>().add(
                      const UndoRequested(),
                    );
                  },
            icon: const Icon(Icons.undo, size: 18),
            label: const Text('撤销'),
          ),
        const Spacer(),
        if (state.files.isNotEmpty && !state.isExecuting)
          Text(
            '${state.files.length} 个文件',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }

  void _showExecuteConfirm(BuildContext blocContext) {
    final bloc = blocContext.read<FileRenamerBloc>();
    final changeCount = bloc.state.previews.where((p) => p.hasChange).length;

    showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            Text('确认执行'),
          ],
        ),
        content: Text(
          '即将重命名 $changeCount 个文件。确定要继续吗？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('取消'),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('确定执行'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ).then((confirmed) {
      if (confirmed == true && mounted) {
        blocContext.read<FileRenamerBloc>().add(
          const ExecuteRequested(),
        );
      }
    });
  }

  Widget _buildPreviewSection(ThemeData theme, FileRenamerState state) {
    if (state.previews.isEmpty) {
      return EmptyState(
        icon: Icons.drive_file_rename_outline,
        title: '暂无预览',
        description: state.files.isEmpty
            ? '请先扫描目录，然后添加规则并点击预览'
            : '请添加规则并点击预览按钮',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '预览结果',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 12),
            StatusBadge(
              text: '${state.changedCount} 将重命名',
              status: AppBadgeStatus.info,
            ),
            const SizedBox(width: 8),
            if (state.conflictCount > 0)
              StatusBadge(
                text: '${state.conflictCount} 冲突',
                status: AppBadgeStatus.error,
              ),
            if (state.errorCount > 0) ...[
              const SizedBox(width: 8),
              StatusBadge(
                text: '${state.errorCount} 错误',
                status: AppBadgeStatus.error,
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: state.previews.length,
            itemBuilder: (context, index) {
              final preview = state.previews[index];
              return _buildPreviewItem(theme, preview);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewItem(ThemeData theme, RenamePreview preview) {
    final hasChange = preview.hasChange;
    final hasConflict = preview.hasConflict;
    final hasError = preview.error != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(
              hasConflict
                  ? Icons.warning_amber
                  : hasError
                      ? Icons.error_outline
                      : hasChange
                          ? Icons.drive_file_rename_outline
                          : Icons.check_circle_outline,
              size: 18,
              color: hasConflict
                  ? Colors.orange
                  : hasError
                      ? theme.colorScheme.error
                      : hasChange
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    preview.originalName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      decoration: hasChange ? TextDecoration.lineThrough : null,
                      color: hasChange
                          ? theme.colorScheme.onSurfaceVariant
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  if (hasChange) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.arrow_forward, size: 14, color: theme.colorScheme.primary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            preview.newName,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: hasConflict ? Colors.orange : theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (hasConflict)
              const StatusBadge(
                text: '冲突',
                status: AppBadgeStatus.error,
              ),
            if (hasError && !hasConflict) ...[
              const SizedBox(width: 8),
              Tooltip(
                message: preview.error!,
                child: Icon(
                  Icons.error_outline,
                  size: 16,
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLogPanel(ThemeData theme, FileRenamerState state) {
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              Text(
                '操作日志',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1, thickness: 1, color: colorScheme.outlineVariant),
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: state.logs.isEmpty
              ? Center(
                  child: Text(
                    '暂无日志',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                )
              : ListView.builder(
                  controller: _logScrollController,
                  padding: const EdgeInsets.all(8),
                  itemCount: state.logs.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 1),
                      child: Text(
                        state.logs[index],
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
