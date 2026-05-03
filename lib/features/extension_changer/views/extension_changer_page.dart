/// 批量扩展名修改器页面
///
/// 提供目录选择、扩展名规则设置、预览和批量执行功能。
library;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../app/app_di.dart';
import '../bloc/extension_changer_bloc.dart';
import '../models/extension_rule.dart';
import '../models/file_preview.dart';

/// 批量扩展名修改器页面
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
        // 更新目录显示
        if (_directory != state.directory) {
          setState(() {
            _directory = state.directory;
          });
        }

        // 自动滚动日志到底部
        if (state.logs.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_logScrollController.hasClients) {
              _logScrollController.jumpTo(
                _logScrollController.position.maxScrollExtent,
              );
            }
          });
        }

        // 显示错误
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
          title: '批量扩展名修改器',
          statusBarText: _getStatusText(state),
          statusBarProgress: state.progress,
          showStatusBarProgress: state.isExecuting,
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 目录选择区
                _buildDirectorySection(theme, state),
                const SizedBox(height: 16),

                // 规则列表区
                _buildRuleSection(theme, state),
                const SizedBox(height: 16),

                // 操作按钮区
                _buildActionButtons(theme, state),
                const SizedBox(height: 16),

                // 预览区
                Expanded(
                  child: _buildPreviewSection(theme, state),
                ),
                const SizedBox(height: 16),

                // 日志面板
                _buildLogPanel(theme, state),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 获取状态栏文本
  String _getStatusText(ExtensionChangerState state) {
    if (state.isScanning) return '正在扫描...';
    if (state.isExecuting) return '正在执行修改... ${(state.progress * 100).toStringAsFixed(0)}%';
    if (state.previews.isNotEmpty) {
      return '预览: ${state.pendingCount} 待处理, ${state.successCount} 成功, ${state.failedCount} 失败';
    }
    if (state.files.isNotEmpty) {
      return '已扫描 ${state.files.length} 个文件';
    }
    return '就绪';
  }

  /// 构建目录选择区
  Widget _buildDirectorySection(ThemeData theme, ExtensionChangerState state) {
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
                  hintText: '请选择要修改扩展名的文件目录',
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
                label: const Text('浏览'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建规则设置区
  Widget _buildRuleSection(ThemeData theme, ExtensionChangerState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: '扩展名规则',
          icon: Icons.edit_note,
          trailing: IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 20),
            tooltip: '添加规则',
            onPressed: () async {
              final rule = await _showRuleDialog(context);
              if (rule != null && mounted) {
                context.read<ExtensionChangerBloc>().add(RuleAdded(rule));
              }
            },
          ),
        ),
        const SizedBox(height: 8),

        // 规则列表
        if (state.rules.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              '暂无规则，点击 + 添加扩展名修改规则',
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

  /// 显示规则编辑对话框
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
          title: Text(initialRule == null ? '添加规则' : '编辑规则'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: originalController,
                decoration: const InputDecoration(
                  labelText: '原扩展名（如 .txt 或留空表示无扩展名）',
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newController,
                decoration: const InputDecoration(
                  labelText: '新扩展名（如 .md）',
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
                  const Text('递归应用到子目录'),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () {
                final newExt = newController.text.trim();
                if (newExt.isEmpty) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text('新扩展名不能为空')),
                  );
                  return;
                }
                Navigator.of(dialogContext).pop(ExtensionRule(
                  originalExtension: originalController.text.trim(),
                  newExtension: newExt,
                  recursive: recursive,
                ));
              },
              child: const Text('确定'),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  /// 构建单个规则项
  Widget _buildRuleItem(ThemeData theme, int index, ExtensionRule rule) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            // 规则信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        rule.originalExtension.isEmpty ? '(无扩展名)' : rule.originalExtension,
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
                      '递归应用到子目录',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // 编辑按钮
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 18),
              tooltip: '编辑',
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

            // 删除按钮
            IconButton(
              icon: Icon(Icons.delete_outline, size: 18, color: theme.colorScheme.error),
              tooltip: '删除',
              onPressed: () {
                context.read<ExtensionChangerBloc>().add(RuleRemoved(index));
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 构建操作按钮区
  Widget _buildActionButtons(ThemeData theme, ExtensionChangerState state) {
    final isBusy = state.isScanning || state.isExecuting;

    return Row(
      children: [
        // 扫描按钮
        FilledButton.tonalIcon(
          onPressed: state.directory.isEmpty || isBusy
              ? null
              : () {
                  context.read<ExtensionChangerBloc>().add(
                    const ScanRequested(),
                  );
                },
          icon: const Icon(Icons.search, size: 18),
          label: const Text('扫描'),
        ),
        const SizedBox(width: 8),

        // 预览按钮
        FilledButton.tonalIcon(
          onPressed: state.files.isEmpty || isBusy
              ? null
              : () {
                  context.read<ExtensionChangerBloc>().add(
                    const PreviewRequested(),
                  );
                },
          icon: const Icon(Icons.preview, size: 18),
          label: const Text('预览'),
        ),
        const SizedBox(width: 8),

        // 执行按钮
        FilledButton.icon(
          onPressed: state.previews.isEmpty || isBusy
              ? null
              : () {
                  _showExecuteConfirm(context);
                },
          icon: const Icon(Icons.play_arrow, size: 18),
          label: const Text('执行'),
        ),
        const SizedBox(width: 8),

        // 取消按钮
        if (isBusy)
          OutlinedButton.icon(
            onPressed: () {
              context.read<ExtensionChangerBloc>().add(
                const CancelRequested(),
              );
            },
            icon: const Icon(Icons.stop, size: 18),
            label: const Text('取消'),
          ),

        const Spacer(),

        // 进度指示
        if (state.isExecuting)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: LinearProgressIndicator(
                value: state.progress,
              ),
            ),
          ),

        // 文件计数
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

  /// 显示执行确认对话框
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
            Text('确认执行'),
          ],
        ),
        content: Text(
          '即将修改 $changeCount 个文件的扩展名，此操作不可撤销。确定要继续吗？',
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
      if (confirmed == true && context.mounted) {
        context.read<ExtensionChangerBloc>().add(
          const ExecuteRequested(),
        );
      }
    });
  }

  /// 构建预览区
  Widget _buildPreviewSection(ThemeData theme, ExtensionChangerState state) {
    if (state.previews.isEmpty) {
      if (state.isScanning) {
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('正在生成预览...'),
            ],
          ),
        );
      }
      return EmptyState(
        icon: Icons.edit_note,
        title: '暂无预览',
        description: state.files.isEmpty
            ? '请先扫描目录，然后添加规则并点击预览'
            : '请添加规则并点击预览按钮',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 预览统计
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
              text: '${state.pendingCount} 待处理',
              status: AppBadgeStatus.info,
            ),
            const SizedBox(width: 8),
            StatusBadge(
              text: '${state.successCount} 成功',
              status: AppBadgeStatus.success,
            ),
            const SizedBox(width: 8),
            StatusBadge(
              text: '${state.failedCount} 失败',
              status: state.failedCount > 0 ? AppBadgeStatus.error : AppBadgeStatus.info,
            ),
          ],
        ),
        const SizedBox(height: 8),

        // 预览列表
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

  /// 构建预览项
  Widget _buildPreviewItem(ThemeData theme, FilePreview preview) {
    final hasChange = preview.hasChange;
    final statusColor = _getStatusColor(theme, preview.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            // 状态图标
            Icon(
              _getStatusIcon(preview.status),
              size: 18,
              color: statusColor,
            ),
            const SizedBox(width: 8),

            // 文件名变更
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 原始文件名
                  Text(
                    preview.originalName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      decoration: hasChange ? TextDecoration.lineThrough : null,
                      color: hasChange
                          ? theme.colorScheme.onSurfaceVariant
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  // 新文件名
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

            // 状态标签
            StatusBadge(
              text: preview.status.displayName,
              status: _mapBadgeStatus(preview.status),
            ),

            // 错误信息
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

  /// 构建日志面板
  Widget _buildLogPanel(ThemeData theme, ExtensionChangerState state) {
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题
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
        // 日志内容
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

  /// 获取状态颜色
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

  /// 获取状态图标
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

  /// 映射状态到徽章状态
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
