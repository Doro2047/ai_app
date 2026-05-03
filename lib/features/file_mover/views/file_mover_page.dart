/// 文件移动工具页面
///
/// 提供源目录选择、目标目录选择、移动规则设置、预览和批量执行功能。
library;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../app/app_di.dart';
import '../bloc/file_mover_bloc.dart';
import '../models/move_preview.dart';
import '../models/move_rule.dart';

/// 文件移动工具页面
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
        // 更新目录显示
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
          title: '文件移动工具',
          statusBarText: _getStatusText(state),
          statusBarProgress: state.progress,
          showStatusBarProgress: state.isExecuting,
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 源目录选择区
                _buildDirectorySection(theme, state, isSource: true),
                const SizedBox(height: 8),

                // 目标目录选择区
                _buildDirectorySection(theme, state, isSource: false),
                const SizedBox(height: 16),

                // 规则设置区
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
  String _getStatusText(FileMoverState state) {
    if (state.isScanning) return '正在扫描...';
    if (state.isExecuting) return '正在执行移动... ${(state.progress * 100).toStringAsFixed(0)}%';
    if (state.previews.isNotEmpty) {
      return '预览: ${state.pendingCount} 待处理, ${state.successCount} 成功, ${state.failedCount} 失败';
    }
    if (state.files.isNotEmpty) {
      return '已扫描 ${state.files.length} 个文件';
    }
    return '就绪';
  }

  /// 构建目录选择区
  Widget _buildDirectorySection(ThemeData theme, FileMoverState state, {required bool isSource}) {
    final directory = isSource ? _sourceDirectory : _targetDirectory;
    final title = isSource ? '源目录' : '目标目录';
    final hint = isSource ? '请选择要移动文件的源目录' : '请选择文件移动的目标目录（可选）';
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
                label: const Text('浏览'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建规则设置区
  Widget _buildRuleSection(ThemeData theme, FileMoverState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: '移动规则',
          icon: Icons.drive_file_move_outline,
          trailing: IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 20),
            tooltip: '添加规则',
            onPressed: () async {
              final rule = await _showRuleDialog(context);
              if (rule != null && mounted) {
                context.read<FileMoverBloc>().add(RuleAdded(rule));
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
              '暂无规则，点击 + 添加移动规则（或仅使用目标目录）',
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
          title: Text(initialRule == null ? '添加规则' : '编辑规则'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 匹配类型
                DropdownButtonFormField<MatchType>(
                  // ignore: deprecated_member_use
                  value: matchType,
                  decoration: const InputDecoration(
                    labelText: '匹配类型',
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

                // 匹配模式
                TextField(
                  controller: patternController,
                  decoration: InputDecoration(
                    labelText: _getPatternLabel(matchType),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 12),

                // 目标目录
                TextField(
                  controller: targetController,
                  decoration: const InputDecoration(
                    labelText: '目标目录',
                    hintText: '选择或输入目标目录路径',
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

                // 子目录开关
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
                    const Text('创建子目录'),
                  ],
                ),

                // 子目录模式
                if (createSubdirs) ...[
                  TextField(
                    controller: subDirController,
                    decoration: const InputDecoration(
                      labelText: '子目录模式',
                      hintText: '如 {extension}, {date}, {year}/{month}',
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '可用变量: {extension}, {date}, {year}, {month}, {size}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: 12),

                // 冲突处理
                DropdownButtonFormField<ConflictAction>(
                  // ignore: deprecated_member_use
                  value: conflictAction,
                  decoration: const InputDecoration(
                    labelText: '冲突处理',
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
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () {
                final pattern = patternController.text.trim();
                final target = targetController.text.trim();
                if (pattern.isEmpty) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text('匹配模式不能为空')),
                  );
                  return;
                }
                if (target.isEmpty) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text('目标目录不能为空')),
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

  /// 获取匹配模式的标签文本
  String _getPatternLabel(MatchType type) {
    switch (type) {
      case MatchType.extension:
        return '扩展名（如 txt 或 .txt）';
      case MatchType.name:
        return '文件名（不含扩展名）';
      case MatchType.contains:
        return '包含的文本';
      case MatchType.regex:
        return '正则表达式';
    }
  }

  /// 构建单个规则项
  Widget _buildRuleItem(ThemeData theme, int index, MoveRule rule) {
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
                      '子目录: ${rule.subDirPattern}, 冲突: ${rule.conflictAction.displayName}',
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
                  final bloc = context.read<FileMoverBloc>();
                  final newRules = List<MoveRule>.from(bloc.state.rules);
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
                context.read<FileMoverBloc>().add(RuleRemoved(index));
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 构建操作按钮区
  Widget _buildActionButtons(ThemeData theme, FileMoverState state) {
    final isBusy = state.isScanning || state.isExecuting;

    return Row(
      children: [
        // 扫描按钮
        FilledButton.tonalIcon(
          onPressed: state.sourceDirectory.isEmpty || isBusy
              ? null
              : () {
                  context.read<FileMoverBloc>().add(
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
                  context.read<FileMoverBloc>().add(
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
              context.read<FileMoverBloc>().add(
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
            Text('确认执行'),
          ],
        ),
        content: Text(
          '即将移动 $moveCount 个文件，此操作不可撤销。确定要继续吗？',
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
        context.read<FileMoverBloc>().add(
          const ExecuteRequested(),
        );
      }
    });
  }

  /// 构建预览区
  Widget _buildPreviewSection(ThemeData theme, FileMoverState state) {
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
        icon: Icons.drive_file_move_outline,
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
  Widget _buildPreviewItem(ThemeData theme, MovePreview preview) {
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

            // 路径变更
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 原始路径
                  Text(
                    preview.originalName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      decoration: hasChange ? TextDecoration.lineThrough : null,
                      color: hasChange
                          ? theme.colorScheme.onSurfaceVariant
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  // 目标路径
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
  Widget _buildLogPanel(ThemeData theme, FileMoverState state) {
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

  /// 获取状态图标
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

  /// 映射状态到徽章状态
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
