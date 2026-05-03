/// 文件扫描器页面
///
/// 主页面，包含目录选择、扫描配置、扫描进度、结果展示和日志面板。
library;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/widgets/widgets.dart';
import '../../../app/app_di.dart';
import '../bloc/file_scanner_bloc.dart';
import '../models/file_scan_result.dart';

class FileScannerPage extends StatefulWidget {
  const FileScannerPage({super.key});

  @override
  State<FileScannerPage> createState() => _FileScannerPageState();
}

class _FileScannerPageState extends State<FileScannerPage>
    with SingleTickerProviderStateMixin {
  late final FileScannerBloc _bloc;
  late final TabController _tabController;
  final List<LogEntry> _logEntries = [];
  final ScrollController _logScrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bloc = getIt<FileScannerBloc>();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _bloc.close();
    _tabController.dispose();
    _logScrollController.dispose();
    _searchController.dispose();
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
        _logScrollController
            .jumpTo(_logScrollController.position.maxScrollExtent);
      }
    });
  }

  Future<void> _addDirectory() async {
    final path = await FilePicker.platform.getDirectoryPath();
    if (path != null && mounted) {
      final dirs = List<String>.from(_bloc.state.directories)..add(path);
      _bloc.add(DirectorySelected(dirs));
    }
  }

  void _removeDirectory(String path) {
    final dirs = _bloc.state.directories.where((d) => d != path).toList();
    _bloc.add(DirectorySelected(dirs));
  }

  void _clearDirectories() {
    _bloc.add(const DirectorySelected([]));
  }

  Future<void> _exportResults() async {
    final outputPath = await FilePicker.platform.saveFile(
      dialogTitle: '导出扫描结果',
      fileName: 'file_scan_result_${DateTime.now().millisecondsSinceEpoch}.csv',
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    if (outputPath != null && mounted) {
      _bloc.add(ExportRequested(outputPath));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocListener<FileScannerBloc, FileScannerState>(
        listenWhen: (previous, current) =>
            previous.logs.length != current.logs.length ||
            previous.error != current.error,
        listener: (context, state) {
          if (state.logs.isNotEmpty &&
              state.logs.length != _bloc.state.logs.length) {
            _addLog(state.logs.last);
          }
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        child: BlocBuilder<FileScannerBloc, FileScannerState>(
          builder: (context, state) {
            return AppScaffold(
              title: '文件扫描器',
              showStatusBar: true,
              statusBarText: state.isScanning
                  ? '正在扫描...'
                  : state.isExporting
                      ? '正在导出...'
                      : state.isScanComplete
                          ? '扫描完成'
                          : '就绪',
              statusBarProgress: state.isScanning
                  ? state.scanProgress
                  : (state.isExporting ? 0.5 : 1.0),
              showStatusBarProgress: state.isScanning || state.isExporting,
              statusBarExtraInfo: state.isScanComplete
                  ? '${state.statistics.totalFiles} 个文件, ${state.statistics.totalSizeFormatted}'
                  : null,
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDirectorySection(state),
                    const SizedBox(height: 16),
                    _buildConfigSection(state),
                    const SizedBox(height: 16),
                    _buildActionButtons(state),
                    const SizedBox(height: 16),
                    if (state.isScanning) _buildProgressCard(state),
                    if (state.isScanning) const SizedBox(height: 16),
                    if (state.isScanComplete) _buildStatisticsCard(state),
                    if (state.isScanComplete) const SizedBox(height: 16),
                    if (state.isScanComplete) _buildResultsSection(state),
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

  Widget _buildDirectorySection(FileScannerState state) {
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

  Widget _buildConfigSection(FileScannerState state) {
    final theme = Theme.of(context);

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
                Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(
                        '文件类型:',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: state.filterFileType ?? '全部',
                        isDense: true,
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                        items: allFileTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (value) {
                          _bloc.add(FilterChanged(
                            fileType: value == '全部' ? null : value,
                          ));
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(
                        '最小大小:',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: '0 (不限制)',
                          suffixText: 'KB',
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                        onChanged: (value) {
                          final size = int.tryParse(value);
                          _bloc.add(FilterChanged(minSizeKB: size));
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(
                        '最大大小:',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: '0 (不限制)',
                          suffixText: 'KB',
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                        onChanged: (value) {
                          final size = int.tryParse(value);
                          _bloc.add(FilterChanged(maxSizeKB: size));
                        },
                      ),
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

  Widget _buildActionButtons(FileScannerState state) {
    return Row(
      children: [
        FilledButton.icon(
          onPressed: state.isScanning
              ? null
              : () => _bloc.add(const ScanStarted()),
          icon: const Icon(Icons.search, size: 18),
          label: const Text('开始扫描'),
        ),
        const SizedBox(width: 8),
        if (state.isScanning)
          OutlinedButton.icon(
            onPressed: () => _bloc.add(const ScanCancelled()),
            icon: const Icon(Icons.cancel, size: 18),
            label: const Text('取消扫描'),
          ),
        const Spacer(),
        if (state.isScanComplete)
          FilledButton.tonalIcon(
            onPressed: state.isExporting ? null : _exportResults,
            icon: const Icon(Icons.file_download, size: 18),
            label: const Text('导出CSV'),
          ),
      ],
    );
  }

  Widget _buildProgressCard(FileScannerState state) {
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
                    '正在扫描目录 ${state.directories.length} 个',
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

  Widget _buildStatisticsCard(FileScannerState state) {
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
                  label: '文件总数',
                  value: '${stats.totalFiles}',
                  color: Theme.of(context).colorScheme.primary,
                ),
                _buildStatCard(
                  icon: Icons.storage,
                  label: '总大小',
                  value: stats.totalSizeFormatted,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                _buildStatCard(
                  icon: Icons.category,
                  label: '文件类型',
                  value: '${stats.fileTypeCount}',
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                _buildStatCard(
                  icon: Icons.filter_alt,
                  label: '筛选结果',
                  value: '${state.filteredResults.length}',
                  color: Theme.of(context).colorScheme.error,
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

  Widget _buildResultsSection(FileScannerState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: '扫描结果详情'),
        Card(
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: '文件列表'),
                  Tab(text: '类型统计'),
                  Tab(text: '大小分布'),
                ],
              ),
              SizedBox(
                height: 400,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildFileListTab(state),
                    _buildFileTypeTab(state),
                    _buildSizeDistributionTab(state),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFileListTab(FileScannerState state) {
    final theme = Theme.of(context);
    final results = state.filteredResults;

    if (results.isEmpty) {
      return Center(
        child: Text(
          '没有匹配的文件',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodySmall?.color,
          ),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '搜索文件名...',
              prefixIcon: const Icon(Icons.search, size: 18),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        _bloc.add(const FilenameSearched(''));
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              if (value.isEmpty) {
                _bloc.add(const FilenameSearched(''));
              }
            },
            onSubmitted: (value) {
              _bloc.add(FilenameSearched(value));
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              final result = results[index];
              return ListTile(
                dense: true,
                leading: Icon(
                  _getFileIcon(result.fileType),
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                title: Text(
                  result.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
                subtitle: Text(
                  result.path,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      result.sizeFormatted,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      result.modifiedFormatted,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFileTypeTab(FileScannerState state) {
    final theme = Theme.of(context);
    final byFileType = state.statistics.byFileType;

    if (byFileType.isEmpty) {
      return Center(
        child: Text(
          '暂无数据',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodySmall?.color,
          ),
        ),
      );
    }

    final sortedEntries = byFileType.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: sortedEntries.length,
      itemBuilder: (context, index) {
        final entry = sortedEntries[index];
        final percentage = state.statistics.totalFiles > 0
            ? (entry.value / state.statistics.totalFiles * 100)
                .toStringAsFixed(1)
            : '0.0';

        return ListTile(
          dense: true,
          leading: Icon(
            _getFileIcon(entry.key),
            size: 20,
            color: theme.colorScheme.primary,
          ),
          title: Text(entry.key),
          trailing: Text(
            '${entry.value} 个 ($percentage%)',
            style: theme.textTheme.bodySmall,
          ),
          subtitle: LinearProgressIndicator(
            value: state.statistics.totalFiles > 0
                ? entry.value / state.statistics.totalFiles
                : 0,
            minHeight: 3,
            borderRadius: BorderRadius.circular(1.5),
          ),
        );
      },
    );
  }

  Widget _buildSizeDistributionTab(FileScannerState state) {
    final theme = Theme.of(context);
    final bySize = state.statistics.bySize;

    if (bySize.isEmpty) {
      return Center(
        child: Text(
          '暂无数据',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodySmall?.color,
          ),
        ),
      );
    }

    final sortedEntries = bySize.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: sortedEntries.length,
      itemBuilder: (context, index) {
        final entry = sortedEntries[index];
        final percentage = state.statistics.totalFiles > 0
            ? (entry.value / state.statistics.totalFiles * 100)
                .toStringAsFixed(1)
            : '0.0';

        return ListTile(
          dense: true,
          leading: Icon(
            _getSizeIcon(entry.key),
            size: 20,
            color: theme.colorScheme.secondary,
          ),
          title: Text(entry.key),
          trailing: Text(
            '${entry.value} 个 ($percentage%)',
            style: theme.textTheme.bodySmall,
          ),
          subtitle: LinearProgressIndicator(
            value: state.statistics.totalFiles > 0
                ? entry.value / state.statistics.totalFiles
                : 0,
            minHeight: 3,
            borderRadius: BorderRadius.circular(1.5),
          ),
        );
      },
    );
  }

  Widget _buildLogPanel(FileScannerState state) {
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
          Divider(
              height: 1,
              thickness: 1,
              color: colorScheme.outlineVariant),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color:
                    colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
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

  IconData _getFileIcon(String fileType) {
    switch (fileType) {
      case '文本文件':
        return Icons.description;
      case '文档':
        return Icons.article;
      case 'PDF文档':
        return Icons.picture_as_pdf;
      case '电子表格':
        return Icons.table_chart;
      case '图片':
        return Icons.image;
      case '音频':
        return Icons.audiotrack;
      case '视频':
        return Icons.videocam;
      case '压缩文件':
        return Icons.folder_zip;
      case '可执行文件':
        return Icons.settings_applications;
      case '代码文件':
        return Icons.code;
      case '安装包':
        return Icons.install_mobile;
      case '镜像文件':
        return Icons.disc_full;
      case '其他文件':
        return Icons.insert_drive_file;
      case '无扩展名':
        return Icons.help_outline;
      default:
        return Icons.insert_drive_file;
    }
  }

  IconData _getSizeIcon(String sizeRange) {
    if (sizeRange.contains('极小')) return Icons.grain;
    if (sizeRange.contains('小')) return Icons.circle_outlined;
    if (sizeRange.contains('中')) return Icons.circle;
    if (sizeRange.contains('大')) return Icons.adjust;
    if (sizeRange.contains('极大')) return Icons.lens;
    if (sizeRange.contains('超大')) return Icons.radio_button_checked;
    return Icons.storage;
  }
}
