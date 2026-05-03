/// File dedup cleaner page
///
/// Main page with directory selection, scan configuration, scan progress, statistics, and duplicate file list.
library;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_core/shared_core.dart';

import 'package:file_dedup/main.dart';
import '../bloc/file_dedup_bloc.dart';
import '../models/models.dart';
import 'duplicate_group_tile.dart';

/// File dedup cleaner page
class FileDedupPage extends StatefulWidget {
  const FileDedupPage({super.key});

  @override
  State<FileDedupPage> createState() => _FileDedupPageState();
}

class _FileDedupPageState extends State<FileDedupPage> {
  late final FileDedupBloc _bloc;
  final List<LogEntry> _logEntries = [];
  final ScrollController _logScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _bloc = getIt<FileDedupBloc>();
  }

  @override
  void dispose() {
    _bloc.close();
    _logScrollController.dispose();
    super.dispose();
  }

  void _addLog(String message) {
    if (!mounted) return;
    setState(() {
      _logEntries.add(LogEntry(
        timestamp: DateTime.now(),
        message: message,
        level: LogLevel.info,
      ));
      if (_logEntries.length > 1000) {
        _logEntries.removeAt(0);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_logScrollController.hasClients) {
        _logScrollController.jumpTo(_logScrollController.position.maxScrollExtent);
      }
    });
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AppConfirmDialog(
        title: 'Confirm Deletion',
        message: 'Are you sure you want to delete ${_bloc.state.selectedFileCount} selected files?\nThis action cannot be undone.',
        isDangerous: true,
      ),
    ).then((confirmed) {
      if (confirmed == true && mounted) {
        _bloc.add(const FileDedupDeleteConfirmed());
      }
    });
  }

  Future<void> _addDirectory() async {
    final path = await FilePicker.platform.getDirectoryPath();
    if (path != null && mounted) {
      final dirs = List<String>.from(_bloc.state.directories)..add(path);
      _bloc.add(FileDedupDirectoriesSelected(dirs));
    }
  }

  void _removeDirectory(String path) {
    final dirs = _bloc.state.directories.where((d) => d != path).toList();
    _bloc.add(FileDedupDirectoriesSelected(dirs));
  }

  void _clearDirectories() {
    _bloc.add(const FileDedupDirectoriesSelected([]));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocListener<FileDedupBloc, FileDedupState>(
        listenWhen: (previous, current) => previous.logs.length != current.logs.length,
        listener: (context, state) {
          if (state.logs.isNotEmpty) {
            _addLog(state.logs.last);
          }
        },
        child: BlocBuilder<FileDedupBloc, FileDedupState>(
          builder: (context, state) {
            return AppScaffold(
              title: 'File Dedup Cleaner',
              showStatusBar: true,
              statusBarText: state.isScanning
                  ? 'Scanning...'
                  : state.isDeleting
                      ? 'Deleting...'
                      : state.isScanComplete
                          ? 'Scan Complete'
                          : 'Ready',
              statusBarProgress: state.isScanning ? state.scanProgress : (state.isDeleting ? 0.5 : 1.0),
              showStatusBarProgress: state.isScanning || state.isDeleting,
              statusBarExtraInfo: state.isScanComplete
                  ? '${state.statistics.duplicateGroups} duplicate groups'
                  : null,
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Directory selection section
                    _buildDirectorySection(state),
                    const SizedBox(height: 16),

                    // Scan configuration section
                    _buildConfigSection(state),
                    const SizedBox(height: 16),

                    // Action buttons section
                    _buildActionButtons(state),
                    const SizedBox(height: 16),

                    // Scan progress card
                    if (state.isScanning) _buildProgressCard(state),
                    if (state.isScanning) const SizedBox(height: 16),

                    // Statistics card
                    if (state.isScanComplete) _buildStatisticsCard(state),
                    if (state.isScanComplete) const SizedBox(height: 16),

                    // Duplicate group list
                    if (state.isScanComplete && state.duplicateGroups.isNotEmpty)
                      _buildDuplicatesList(state),

                    // Log panel
                    const SizedBox(height: 16),
                    _buildLogPanel(state),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Directory selection section
  Widget _buildDirectorySection(FileDedupState state) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Directory Selection'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state.directories.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'No directories selected',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                  ),
                if (state.directories.isNotEmpty) ...[
                  ...state.directories.map((dir) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            const Icon(Icons.folder, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                dir,
                                style: theme.textTheme.bodyMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              tooltip: 'Remove directory',
                              onPressed: () => _removeDirectory(dir),
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(4),
                            ),
                          ],
                        ),
                      )),
                ],
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.icon(
                      onPressed: _addDirectory,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Directory'),
                    ),
                    if (state.directories.isNotEmpty)
                      OutlinedButton.icon(
                        onPressed: _clearDirectories,
                        icon: const Icon(Icons.clear_all, size: 18),
                        label: const Text('Clear'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Scan configuration section
  Widget _buildConfigSection(FileDedupState state) {
    final theme = Theme.of(context);
    final config = state.config;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Scan Configuration'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hash type selection
                Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(
                        'Hash Algorithm:',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: config.hashType,
                        isDense: true,
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: ScanConfig.validHashTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(ScanConfig.hashTypeLabels[type] ?? type),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            _bloc.add(FileDedupConfigChanged(
                              config.copyWith(hashType: value),
                            ));
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Minimum file size
                Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(
                        'Min File Size:',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: '0 (No limit)',
                          suffixText: 'bytes',
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        controller: TextEditingController(
                          text: config.minFileSize > 0 ? config.minFileSize.toString() : '',
                        ),
                        onChanged: (value) {
                          final size = int.tryParse(value) ?? 0;
                          _bloc.add(FileDedupConfigChanged(
                            config.copyWith(minFileSize: size),
                          ));
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Recursive scan switch
                SwitchListTile(
                  title: const Text('Recursive Scan'),
                  value: config.recursive,
                  onChanged: (value) {
                    _bloc.add(FileDedupConfigChanged(
                      config.copyWith(recursive: value),
                    ));
                  },
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Action buttons section
  Widget _buildActionButtons(FileDedupState state) {
    return Row(
      children: [
        // Start scan
        FilledButton.icon(
          onPressed: state.isScanning
              ? null
              : () => _bloc.add(const FileDedupScanStarted()),
          icon: const Icon(Icons.search, size: 18),
          label: const Text('Start Scan'),
        ),
        const SizedBox(width: 8),

        // Cancel scan
        if (state.isScanning)
          OutlinedButton.icon(
            onPressed: () => _bloc.add(const FileDedupScanCancelled()),
            icon: const Icon(Icons.cancel, size: 18),
            label: const Text('Cancel Scan'),
          ),

        const Spacer(),

        // Delete selected
        if (state.isScanComplete && state.hasSelectedFiles)
          FilledButton.icon(
            onPressed: state.isDeleting
                ? null
                : () => _showDeleteConfirmation(context),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            icon: const Icon(Icons.delete, size: 18),
            label: Text('Delete Selected (${state.selectedFileCount})'),
          ),
      ],
    );
  }

  /// Scan progress card
  Widget _buildProgressCard(FileDedupState state) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const StatusBadge(
                  text: 'Scanning',
                  status: AppBadgeStatus.info,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    state.currentScanningFile,
                    style: theme.textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${(state.scanProgress * 100).toStringAsFixed(1)}%',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: state.scanProgress,
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
          ],
        ),
      ),
    );
  }

  /// Statistics card
  Widget _buildStatisticsCard(FileDedupState state) {
    final stats = state.statistics;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Scan Results',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildStatCard(
                  icon: Icons.insert_drive_file,
                  label: 'Scanned Files',
                  value: '${stats.scannedFiles}',
                  color: Theme.of(context).colorScheme.primary,
                ),
                _buildStatCard(
                  icon: Icons.copy,
                  label: 'Duplicate Groups',
                  value: '${stats.duplicateGroups}',
                  color: Theme.of(context).colorScheme.secondary,
                ),
                _buildStatCard(
                  icon: Icons.file_copy,
                  label: 'Duplicate Files',
                  value: '${stats.duplicateFiles}',
                  color: Theme.of(context).colorScheme.error,
                ),
                _buildStatCard(
                  icon: Icons.storage,
                  label: 'Freeable Space',
                  value: stats.duplicateSizeFormatted,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Container(
      constraints: const BoxConstraints(minWidth: 140),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// Duplicate group list
  Widget _buildDuplicatesList(FileDedupState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Duplicate Files'),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.duplicateGroups.length,
          itemBuilder: (context, index) {
            final group = state.duplicateGroups[index];
            return DuplicateGroupTile(group: group);
          },
        ),
      ],
    );
  }

  /// Log panel
  Widget _buildLogPanel(FileDedupState state) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      height: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              'Operation Log',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Divider(height: 1, thickness: 1, color: colorScheme.outlineVariant),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: _logEntries.isEmpty
                  ? const Center(child: Text('No logs yet'))
                  : ListView.builder(
                      controller: _logScrollController,
                      padding: const EdgeInsets.all(8),
                      itemCount: _logEntries.length,
                      itemBuilder: (context, index) {
                        final entry = _logEntries[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 1),
                          child: Text(
                            '[${entry.formattedTime}] ${entry.message}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
