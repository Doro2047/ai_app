library;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:shared_core/shared_core.dart';

import '../../../injection.dart';
import '../bloc/extension_changer_bloc.dart';
import '../models/extension_rule.dart';
import '../models/file_preview.dart';

class ExtensionChangerPage extends StatelessWidget {
  const ExtensionChangerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ExtensionChangerBloc>(),
      child: const _ExtensionChangerPageContent(),
    );
  }
}

class _ExtensionChangerPageContent extends StatefulWidget {
  const _ExtensionChangerPageContent();

  @override
  State<_ExtensionChangerPageContent> createState() => _ExtensionChangerPageContentState();
}

class _ExtensionChangerPageContentState extends State<_ExtensionChangerPageContent> {
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

    return BlocConsumer<ExtensionChangerBloc, ExtensionChangerState>(
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
          title: 'Extension Changer',
          statusBarText: _getStatusText(state),
          statusBarProgress: state.progress,
          showStatusBarProgress: state.isExecuting,
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

  String _getStatusText(ExtensionChangerState state) {
    if (state.isScanning) return 'Scanning...';
    if (state.isExecuting) return 'Executing... ${(state.progress * 100).toStringAsFixed(0)}%';
    if (state.previews.isNotEmpty) {
      return 'Preview: ${state.pendingCount} pending, ${state.successCount} success, ${state.failedCount} failed';
    }
    if (state.files.isNotEmpty) {
      return '${state.files.length} files scanned';
    }
    return 'Ready';
  }

  Widget _buildDirectorySection(ThemeData theme, ExtensionChangerState state) {
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
                  hintText: 'Select a directory to change file extensions',
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
                    context.read<ExtensionChangerBloc>().add(
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
      ],
    );
  }

  Widget _buildRuleSection(ThemeData theme, ExtensionChangerState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Extension Rules',
          icon: Icons.edit_note,
          trailing: IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 20),
            tooltip: 'Add Rule',
            onPressed: () async {
              final rule = await _showRuleDialog(context);
              if (rule != null && mounted) {
                context.read<ExtensionChangerBloc>().add(RuleAdded(rule));
              }
            },
          ),
        ),
        const SizedBox(height: 8),

        if (state.rules.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'No rules yet. Click + to add an extension rule.',
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

  Future<ExtensionRule?> _showRuleDialog(
    BuildContext context, {
    ExtensionRule? initialRule,
  }) async {
    final originalController = TextEditingController(
      text: initialRule?.originalExtension ?? '',
    );
    final newController = TextEditingController(
      text: initialRule?.newExtension ?? '',
    );
    var recursive = initialRule?.recursive ?? true;

    return showDialog<ExtensionRule>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(initialRule == null ? 'Add Rule' : 'Edit Rule'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: originalController,
                decoration: const InputDecoration(
                  labelText: 'Original extension (e.g. .txt or empty for no extension)',
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newController,
                decoration: const InputDecoration(
                  labelText: 'New extension (e.g. .md)',
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Checkbox(
                    value: recursive,
                    onChanged: (value) {
                      setDialogState(() {
                        recursive = value ?? true;
                      });
                    },
                  ),
                  const Text('Apply recursively to subdirectories'),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final newExt = newController.text.trim();
                if (newExt.isEmpty) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text('New extension cannot be empty')),
                  );
                  return;
                }
                Navigator.of(dialogContext).pop(ExtensionRule(
                  originalExtension: originalController.text.trim(),
                  newExtension: newExt,
                  recursive: recursive,
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

  Widget _buildRuleItem(ThemeData theme, int index, ExtensionRule rule) {
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
                      Text(
                        rule.originalExtension.isEmpty ? '(No Extension)' : rule.originalExtension,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(Icons.arrow_forward, size: 16),
                      ),
                      Text(
                        rule.newExtension,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.tertiary,
                        ),
                      ),
                    ],
                  ),
                  if (rule.recursive) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Apply recursively to subdirectories',
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
                  final bloc = context.read<ExtensionChangerBloc>();
                  final newRules = List<ExtensionRule>.from(bloc.state.rules);
                  newRules[index] = edited;
                  bloc.add(RulesChanged(newRules));
                }
              },
            ),

            IconButton(
              icon: Icon(Icons.delete_outline, size: 18, color: theme.colorScheme.error),
              tooltip: 'Delete',
              onPressed: () {
                context.read<ExtensionChangerBloc>().add(RuleRemoved(index));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme, ExtensionChangerState state) {
    final isBusy = state.isScanning || state.isExecuting;

    return Row(
      children: [
        FilledButton.tonalIcon(
          onPressed: state.directory.isEmpty || isBusy
              ? null
              : () {
                  context.read<ExtensionChangerBloc>().add(
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
                  context.read<ExtensionChangerBloc>().add(
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
              context.read<ExtensionChangerBloc>().add(
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
    final bloc = context.read<ExtensionChangerBloc>();
    final state = bloc.state;
    final changeCount = state.previews.where((p) => p.hasChange).length;

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
          'About to rename $changeCount files. This action cannot be undone. Continue?',
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
        context.read<ExtensionChangerBloc>().add(
          const ExecuteRequested(),
        );
      }
    });
  }

  Widget _buildPreviewSection(ThemeData theme, ExtensionChangerState state) {
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
        icon: Icons.edit_note,
        title: 'No Preview',
        description: state.files.isEmpty
            ? 'Scan a directory first, then add rules and preview'
            : 'Add rules and click Preview',
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

  Widget _buildPreviewItem(ThemeData theme, FilePreview preview) {
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
                            preview.newName,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
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

  Widget _buildLogPanel(ThemeData theme, ExtensionChangerState state) {
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

  Color _getStatusColor(ThemeData theme, ExtensionChangeStatus status) {
    switch (status) {
      case ExtensionChangeStatus.pending:
        return theme.colorScheme.onSurfaceVariant;
      case ExtensionChangeStatus.success:
        return theme.colorScheme.tertiary;
      case ExtensionChangeStatus.failed:
        return theme.colorScheme.error;
    }
  }

  IconData _getStatusIcon(ExtensionChangeStatus status) {
    switch (status) {
      case ExtensionChangeStatus.pending:
        return Icons.schedule;
      case ExtensionChangeStatus.success:
        return Icons.check_circle_outline;
      case ExtensionChangeStatus.failed:
        return Icons.error_outline;
    }
  }

  AppBadgeStatus _mapBadgeStatus(ExtensionChangeStatus status) {
    switch (status) {
      case ExtensionChangeStatus.pending:
        return AppBadgeStatus.info;
      case ExtensionChangeStatus.success:
        return AppBadgeStatus.success;
      case ExtensionChangeStatus.failed:
        return AppBadgeStatus.error;
    }
  }
}
