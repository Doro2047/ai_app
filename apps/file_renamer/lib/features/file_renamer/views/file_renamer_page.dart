library;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_core/shared_core.dart';

import '../../../main.dart';
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
          title: 'Batch Rename Tool',
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
    if (state.isExecuting) return 'Executing...';
    if (state.previews.isNotEmpty) {
      return 'Preview: ${state.changedCount} to rename, ${state.conflictCount} conflicts, ${state.errorCount} errors';
    }
    if (state.files.isNotEmpty) {
      return 'Scanned ${state.files.length} files';
    }
    return 'Ready';
  }

  Widget _buildDirectorySection(ThemeData theme, FileRenamerState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Directory',
          icon: Icons.folder_open,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Select a directory to rename files',
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
                label: const Text('Browse'),
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
            const Text('Recursive scan'),
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
          title: 'Rename Rules',
          icon: Icons.rule,
          trailing: IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 20),
            tooltip: 'Add Rule',
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
              'No rules yet, click + to add a rename rule',
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
          title: Text(initialRule == null ? 'Add Rule' : 'Edit Rule'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<RenameRuleType>(
                    initialValue: selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Rule Type',
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
                        labelText: 'Start Index',
                        isDense: true,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Enable this rule'),
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
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (patternController.text.trim().isEmpty &&
                    selectedType != RenameRuleType.sequence) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text('Please enter pattern content')),
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
              child: Text(initialRule == null ? 'Add' : 'Save'),
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
                labelText: 'Prefix Content',
                hintText: 'Add before filename',
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
                labelText: 'Suffix Content',
                hintText: 'Add after filename (before extension)',
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
                labelText: 'Find Text',
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: replacementController,
              decoration: const InputDecoration(
                labelText: 'Replace With',
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
                labelText: 'Filename Prefix (optional)',
                hintText: 'e.g. file_',
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
                labelText: 'New Extension',
                hintText: 'e.g. .md',
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
                labelText: 'Regular Expression',
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: replacementController,
              decoration: const InputDecoration(
                labelText: 'Replace With (supports \$1, \$2 groups)',
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
              tooltip: 'Edit',
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
              tooltip: 'Delete',
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
        return 'Add prefix: "${rule.pattern}"';
      case RenameRuleType.suffix:
        return 'Add suffix: "${rule.pattern}"';
      case RenameRuleType.replace:
        return 'Find "${rule.pattern}" replace with "${rule.replacement}"';
      case RenameRuleType.sequence:
        return 'Sequence from ${rule.startIndex ?? 1}${rule.replacement.isNotEmpty ? ', prefix: "${rule.replacement}"' : ''}';
      case RenameRuleType.extension:
        return 'Change extension to "${rule.replacement}"';
      case RenameRuleType.regex:
        return 'Regex: ${rule.pattern} -> ${rule.replacement}';
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
          label: const Text('Scan'),
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
          label: const Text('Preview'),
        ),
        const SizedBox(width: 8),
        FilledButton.icon(
          onPressed: state.previews.isEmpty || state.isExecuting
              ? null
              : () {
                  _showExecuteConfirm(context);
                },
          icon: const Icon(Icons.play_arrow, size: 18),
          label: const Text('Execute'),
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
            label: const Text('Undo'),
          ),
        const Spacer(),
        if (state.files.isNotEmpty && !state.isExecuting)
          Text(
            '${state.files.length} files',
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
            Text('Confirm Execute'),
          ],
        ),
        content: Text(
          'About to rename $changeCount files. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Confirm'),
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
        title: 'No Preview',
        description: state.files.isEmpty
            ? 'Scan a directory first, then add rules and preview'
            : 'Add rules and click preview button',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Preview Results',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 12),
            StatusBadge(
              text: '${state.changedCount} to rename',
              status: AppBadgeStatus.info,
            ),
            const SizedBox(width: 8),
            if (state.conflictCount > 0)
              StatusBadge(
                text: '${state.conflictCount} conflicts',
                status: AppBadgeStatus.error,
              ),
            if (state.errorCount > 0) ...[
              const SizedBox(width: 8),
              StatusBadge(
                text: '${state.errorCount} errors',
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
                text: 'Conflict',
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
                'Operation Log',
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
                    'No logs',
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
