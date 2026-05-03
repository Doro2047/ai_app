/// 批量文件查重清理工具页面
///
/// 主页面，包含目录选择、扫描配置、扫描进度、统计和重复文件列表。
library;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/widgets/widgets.dart';
import '../../../app/app_di.dart';
import '../bloc/file_dedup_bloc.dart';
import '../models/models.dart';
import 'duplicate_group_tile.dart';

/// 批量文件查重清理工具页面
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
        title: '确认删除',
        message: '确定要删除选中的 ${_bloc.state.selectedFileCount} 个文件吗？\n此操作不可撤销。',
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
              title: '批量文件查重清理工具',
              showStatusBar: true,
              statusBarText: state.isScanning
                  ? '正在扫描...'
                  : state.isDeleting
                      ? '正在删除...'
                      : state.isScanComplete
                          ? '扫描完成'
                          : '就绪',
              statusBarProgress: state.isScanning ? state.scanProgress : (state.isDeleting ? 0.5 : 1.0),
              showStatusBarProgress: state.isScanning || state.isDeleting,
              statusBarExtraInfo: state.isScanComplete
                  ? '${state.statistics.duplicateGroups} 组重复文件'
                  : null,
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 目录选择区
                    _buildDirectorySection(state),
                    const SizedBox(height: 16),

                    // 扫描配置区
                    _buildConfigSection(state),
                    const SizedBox(height: 16),

                    // 操作按钮区
                    _buildActionButtons(state),
                    const SizedBox(height: 16),

                    // 扫描进度卡片
                    if (state.isScanning) _buildProgressCard(state),
                    if (state.isScanning) const SizedBox(height: 16),

                    // 统计卡片
                    if (state.isScanComplete) _buildStatisticsCard(state),
                    if (state.isScanComplete) const SizedBox(height: 16),

                    // 重复组列表
                    if (state.isScanComplete && state.duplicateGroups.isNotEmpty)
                      _buildDuplicatesList(state),

                    // 日志面板
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

  /// 目录选择区
  Widget _buildDirectorySection(FileDedupState state) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: '目录选择'),
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
                      '尚未选择任何目录',
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
                              tooltip: '移除此目录',
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
                      label: const Text('添加目录'),
                    ),
                    if (state.directories.isNotEmpty)
                      OutlinedButton.icon(
                        onPressed: _clearDirectories,
                        icon: const Icon(Icons.clear_all, size: 18),
                        label: const Text('清空'),
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

  /// 扫描配置区
  Widget _buildConfigSection(FileDedupState state) {
    final theme = Theme.of(context);
    final config = state.config;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: '扫描配置'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 哈希类型选择
                Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(
                        '哈希算法:',
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

                // 最小文件大小
                Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(
                        '最小文件大小:',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: '0 (不限制)',
                          suffixText: '字节',
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

                // 递归扫描开关
                SwitchListTile(
                  title: const Text('递归扫描子目录'),
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

  /// 操作按钮区
  Widget _buildActionButtons(FileDedupState state) {
    return Row(
      children: [
        // 开始扫描
        FilledButton.icon(
          onPressed: state.isScanning
              ? null
              : () => _bloc.add(const FileDedupScanStarted()),
          icon: const Icon(Icons.search, size: 18),
          label: const Text('开始扫描'),
        ),
        const SizedBox(width: 8),

        // 取消扫描
        if (state.isScanning)
          OutlinedButton.icon(
            onPressed: () => _bloc.add(const FileDedupScanCancelled()),
            icon: const Icon(Icons.cancel, size: 18),
            label: const Text('取消扫描'),
          ),

        const Spacer(),

        // 删除选中
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
            label: Text('删除选中 (${state.selectedFileCount})'),
          ),
      ],
    );
  }

  /// 扫描进度卡片
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
                  text: '扫描中',
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

  /// 统计卡片
  Widget _buildStatisticsCard(FileDedupState state) {
    final stats = state.statistics;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '扫描结果',
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
                  label: '扫描文件',
                  value: '${stats.scannedFiles}',
                  color: Theme.of(context).colorScheme.primary,
                ),
                _buildStatCard(
                  icon: Icons.copy,
                  label: '重复组数',
                  value: '${stats.duplicateGroups}',
                  color: Theme.of(context).colorScheme.secondary,
                ),
                _buildStatCard(
                  icon: Icons.file_copy,
                  label: '重复文件',
                  value: '${stats.duplicateFiles}',
                  color: Theme.of(context).colorScheme.error,
                ),
                _buildStatCard(
                  icon: Icons.storage,
                  label: '可释放空间',
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

  /// 重复组列表
  Widget _buildDuplicatesList(FileDedupState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: '重复文件列表'),
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

  /// 日志面板
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
              '操作日志',
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
                  ? const Center(child: Text('暂无日志'))
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
