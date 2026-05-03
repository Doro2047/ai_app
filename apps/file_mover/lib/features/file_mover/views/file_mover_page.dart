library;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_core/shared_core.dart';

import '../../../injection.dart';
import '../bloc/file_mover_bloc.dart';
import '../models/move_preview.dart';
import '../models/move_rule.dart';

class FileMoverPage extends StatelessWidget {
  const FileMoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<FileMoverBloc>(),
      child: const _FileMoverPageContent(),
    );
  }
}

class _FileMoverPageContent extends StatefulWidget {
  const _FileMoverPageContent();

  @override
  State<_FileMoverPageContent> createState() => _FileMoverPageContentState();
}

class _FileMoverPageContentState extends State<_FileMoverPageContent> {
  final ScrollController _logScrollController = ScrollController();
  String _sourceDirectory = '';
  String _targetDirectory = '';

  @override
  void dispose() {
    _logScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<FileMoverBloc, FileMoverState>(
      listener: (context, state) {
        if (_sourceDirectory != state.sourceDirectory) {
          setState(() {
            _sourceDirectory = state.sourceDirectory;
          });
        }
        if (_targetDirectory != state.targetDirectory) {
          setState(() {
            _targetDirectory = state.targetDirectory;
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
          title: 'File Mover',
          statusBarText: _getStatusText(state),
          statusBarProgress: state.progress,
          showStatusBarProgress: state.isExecuting,
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildDirectorySection(theme, state, isSource: true),
                const SizedBox(height: 8),
                _buildDirectorySection(theme, state, isSource: false),
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

  String _getStatusText(FileMoverState state) {
    if (state.isScanning) return 'Scanning...';
    if (state.isExecuting) return 'Moving... ${(state.progress * 100).toStringAsFixed(0)}%';
    if (state.previews.isNotEmpty) {
      return 'Preview: ${state.pendingCount} pending, ${state.successCount} success, ${state.failedCount} failed';
    }
    if (state.files.isNotEmpty) {
      return '${state.files.length} files scanned';
    }
    return 'Ready';
  }

  Widget _buildDirectorySection(ThemeData theme, FileMoverState state, {required bool isSource}) {
    final directory = isSource ? _sourceDirectory : _targetDirectory;
    final title = isSource ? 'Source Directory' : 'Target Directory';
    final hint = isSource ? 'Select source directory' : 'Select target directory (optional)';
    final icon = isSource ? Icons.folder_open : Icons.folder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: title,
          icon: icon,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: hint,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                readOnly: true,
                controller: TextEditingController(text: directory),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 48,
              child: FilledButton.tonalIcon(
                onPressed: () async {
                  final path = await FilePicker.platform.getDirectoryPath();
                  if (path != null && mounted) {
                    final bloc = context.read<FileMoverBloc>();
                    if (isSource) {
                      bloc.add(SourceDirectorySelected(path));
                    } else {
                      bloc.add(TargetDirectorySelected(path));
                    }
                  }
                },
                icon: Icon(icon, size: 18),
                label: const Text('Browse'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRuleSection(ThemeData theme, FileMoverState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Move Rules',
          icon: Icons.drive_file_move_outline,
          trailing: IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 20),
            tooltip: 'Add Rule',
            onPressed: () async {
              final rule = await _showRuleDialog(context);
              if (rule != null && mounted) {
                context.read<FileMoverBloc>().add(RuleAdded(rule));
              }
            },
          ),
        ),
        const SizedBox(height: 8),

        if (state.rules.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'No rules yet. Click + to add move rules (or use target directory only)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          )
        else
          ...state.rules.asMap().entries.map((entry) {
            return _buildRuleItem(theme, entry.key, entry.value);
          }),
      ],
    );
  }

  Future<MoveRule?> _showRuleDialog(
    BuildContext context, {
    MoveRule? initialRule,
  }) async {
    var matchType = initialRule?.matchType ?? MatchType.extension;
    final patternController = TextEditingController(
      text: initialRule?.matchPattern ?? '',
    );
    final targetController = TextEditingController(
      text: initialRule?.targetDirectory ?? '',
    );
    var createSubdirs = initialRule?.createSubdirs ?? false;
    final subDirController = TextEditingController(
      text: initialRule?.subDirPattern ?? '',
    );
    var conflictAction = initialRule?.conflictAction ?? ConflictAction.rename;

    return showDialog<MoveRule>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(initialRule == null ? 'Add Rule' : 'Edit Rule'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<MatchType>(
                  initialValue: matchType,
                  decoration: const InputDecoration(
                    labelText: 'Match Type',
                    isDense: true,
                  ),
                  items: MatchType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.displayName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() {
                        matchType = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: patternController,
                  decoration: InputDecoration(
                    labelText: _getPatternLabel(matchType),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: targetController,
                  decoration: const InputDecoration(
                    labelText: 'Target Directory',
                    hintText: 'Select or enter target directory path',
                    isDense: true,
                  ),
                  readOnly: true,
                  onTap: () async {
                    final path = await FilePicker.platform.getDirectoryPath();
                    if (path != null) {
                      setDialogState(() {
                        targetController.text = path;
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Checkbox(
                      value: createSubdirs,
                      onChanged: (value) {
                        setDialogState(() {
                          createSubdirs = value ?? false;
                        });
                      },
                    ),
                    const Text('Create subdirectories'),
                  ],
                ),

                if (createSubdirs) ...[
                  TextField(
                    controller: subDirController,
                    decoration: const InputDecoration(
                      labelText: 'Subdirectory Pattern',
                      hintText: 'e.g. {extension}, {date}, {year}/{month}',
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Available variables: {extension}, {date}, {year}, {month}, {size}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: 12),

                DropdownButtonFormField<ConflictAction>(
                  initialValue: conflictAction,
                  decoration: const InputDecoration(
                    labelText: 'Conflict Resolution',
                    isDense: true,
                  ),
                  items: ConflictAction.values.map((action) {
                    return DropdownMenuItem(
                      value: action,
                      child: Text(action.displayName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() {
                        conflictAction = value;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final pattern = patternController.text.trim();
                final target = targetController.text.trim();
                if (pattern.isEmpty) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text('Match pattern cannot be empty')),
                  );
                  return;
                }
                if (target.isEmpty) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text('Target directory cannot be empty')),
                  );
                  return;
                }
                Navigator.of(dialogContext).pop(MoveRule(
                  matchType: matchType,
                  matchPattern: pattern,
                  targetDirectory: target,
                  createSubdirs: createSubdirs,
                  subDirPattern: subDirController.text.trim(),
                  conflictAction: conflictAction,
                ));
              },
              child: const Text('OK'),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  String _getPatternLabel(MatchType type) {
    switch (type) {
      case MatchType.extension:
        return 'Extension (e.g. txt or .txt)';
      case MatchType.name:
        return 'Filename (without extension)';
      case MatchType.contains:
        return 'Contains text';
      case MatchType.regex:
        return 'Regular expression';
    }
  }

  Widget _buildRuleItem(ThemeData theme, int index, MoveRule rule) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      StatusBadge(
                        text: rule.matchType.displayName,
                        status: AppBadgeStatus.info,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '"${rule.matchPattern}" -> ${rule.targetDirectory}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (rule.createSubdirs) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Subdir: ${rule.subDirPattern}, Conflict: ${rule.conflictAction.displayName}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
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
                  final bloc = context.read<FileMoverBloc>();
                  final newRules = List<MoveRule>.from(bloc.state.rules);
                  newRules[index] = edited;
                  bloc.add(RulesChanged(newRules));
                }
              },
            ),

            IconButton(
              icon: Icon(Icons.delete_outline, size: 18, color: theme.colorScheme.error),
              tooltip: 'Delete',
              onPressed: () {
                context.read<FileMoverBloc>().add(RuleRemoved(index));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme, FileMoverState state) {
    final isBusy = state.isScanning || state.isExecuting;

    return Row(
      children: [
        FilledButton.tonalIcon(
          onPressed: state.sourceDirectory.isEmpty || isBusy
              ? null
              : () {
                  context.read<FileMoverBloc>().add(
                    const ScanRequested(),
                  );
                },
          icon: const Icon(Icons.search, size: 18),
          label: const Text('Scan'),
        ),
        const SizedBox(width: 8),

        FilledButton.tonalIcon(
          onPressed: state.files.isEmpty || isBusy
              ? null
              : () {
                  context.read<FileMoverBloc>().add(
                    const PreviewRequested(),
                  );
                },
          icon: const Icon(Icons.preview, size: 18),
          label: const Text('Preview'),
        ),
        const SizedBox(width: 8),

        FilledButton.icon(
          onPressed: state.previews.isEmpty || isBusy
              ? null
              : () {
                  _showExecuteConfirm(context);
                },
          icon: const Icon(Icons.play_arrow, size: 18),
          label: const Text('Execute'),
        ),
        const SizedBox(width: 8),

        if (isBusy)
          OutlinedButton.icon(
            onPressed: () {
              context.read<FileMoverBloc>().add(
                const CancelRequested(),
              );
            },
            icon: const Icon(Icons.stop, size: 18),
            label: const Text('Cancel'),
          ),

        const Spacer(),

        if (state.isExecuting)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: LinearProgressIndicator(
                value: state.progress,
              ),
            ),
          ),

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

  void _showExecuteConfirm(BuildContext context) {
    final bloc = context.read<FileMoverBloc>();
    final state = bloc.state;
    final moveCount = state.previews.where((p) => p.hasChange).length;

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
          'About to move $moveCount files. This action cannot be undone. Continue?',
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
            child: const Text('Execute'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ).then((confirmed) {
      if (confirmed == true && context.mounted) {
        context.read<FileMoverBloc>().add(
          const ExecuteRequested(),
        );
      }
    });
  }

  Widget _buildPreviewSection(ThemeData theme, FileMoverState state) {
    if (state.previews.isEmpty) {
      if (state.isScanning) {
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Generating preview...'),
            ],
          ),
        );
      }
      return EmptyState(
        icon: Icons.drive_file_move_outline,
        title: 'No Preview',
        description: state.files.isEmpty
            ? 'Scan directory first, then add rules and preview'
            : 'Add rules and click preview',
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
            const SizedBox(height: 12),
            StatusBadge(
              text: '${state.pendingCount} pending',
              status: AppBadgeStatus.info,
            ),
            const SizedBox(width: 8),
            StatusBadge(
              text: '${state.successCount} success',
              status: AppBadgeStatus.success,
            ),
            const SizedBox(width: 8),
            StatusBadge(
              text: '${state.failedCount} failed',
              status: state.failedCount > 0 ? AppBadgeStatus.error : AppBadgeStatus.info,
            ),
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

  Widget _buildPreviewItem(ThemeData theme, MovePreview preview) {
    final hasChange = preview.hasChange;
    final statusColor = _getStatusColor(theme, preview.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(
              _getStatusIcon(preview.status),
              size: 18,
              color: statusColor,
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
                            preview.targetPath,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            StatusBadge(
              text: preview.status.displayName,
              status: _mapBadgeStatus(preview.status),
            ),

            if (preview.error != null) ...[
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

  Widget _buildLogPanel(ThemeData theme, FileMoverState state) {
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

  Color _getStatusColor(ThemeData theme, MoveStatus status) {
    switch (status) {
      case MoveStatus.pending:
        return theme.colorScheme.onSurfaceVariant;
      case MoveStatus.success:
        return theme.colorScheme.tertiary;
      case MoveStatus.failed:
        return theme.colorScheme.error;
    }
  }

  IconData _getStatusIcon(MoveStatus status) {
    switch (status) {
      case MoveStatus.pending:
        return Icons.schedule;
      case MoveStatus.success:
        return Icons.check_circle_outline;
      case MoveStatus.failed:
        return Icons.error_outline;
    }
  }

  AppBadgeStatus _mapBadgeStatus(MoveStatus status) {
    switch (status) {
      case MoveStatus.pending:
        return AppBadgeStatus.info;
      case MoveStatus.success:
        return AppBadgeStatus.success;
      case MoveStatus.failed:
        return AppBadgeStatus.error;
    }
  }
}
