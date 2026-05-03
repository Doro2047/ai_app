import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/widgets/widgets.dart';
import '../../../app/app_di.dart';
import '../bloc/bloc.dart';
import '../models/models.dart';

class ImageClassifierPage extends StatelessWidget {
  const ImageClassifierPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ImageClassifierBloc>(),
      child: const _ImageClassifierPageContent(),
    );
  }
}

class _ImageClassifierPageContent extends StatefulWidget {
  const _ImageClassifierPageContent();

  @override
  State<_ImageClassifierPageContent> createState() =>
      _ImageClassifierPageContentState();
}

class _ImageClassifierPageContentState
    extends State<_ImageClassifierPageContent> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<ImageClassifierBloc, ImageClassifierState>(
      listener: (context, state) {
        if (state.error != null && state.error!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: theme.colorScheme.errorContainer,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        return AppScaffold(
          title: '图片分类器',
          statusBarText: _getStatusText(state),
          statusBarProgress: state.progress,
          showStatusBarProgress: state.isClassifying || state.isScanning,
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildDirectorySection(theme, state),
                const SizedBox(height: 12),
                _buildRulesSection(theme, state),
                const SizedBox(height: 12),
                _buildActionSection(theme, state),
                const SizedBox(height: 12),
                if (state.isScanning || state.isClassifying)
                  _buildProgressSection(theme, state),
                if (state.isScanning || state.isClassifying)
                  const SizedBox(height: 12),
                Expanded(
                  child: _buildClassifiedGroupsSection(theme, state),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 120,
                  child: _buildLogSection(theme, state),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getStatusText(ImageClassifierState state) {
    if (state.isScanning) return '正在扫描图片...';
    if (state.isClassifying) {
      return '分类中: ${state.progressText} (${(state.progress * 100).toStringAsFixed(0)}%)';
    }
    if (state.images.isNotEmpty) {
      return '已扫描 ${state.images.length} 张图片 | ${state.rules.length} 条规则';
    }
    return '就绪';
  }

  Widget _buildDirectorySection(ThemeData theme, ImageClassifierState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: '图片目录',
          icon: Icons.folder,
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      state.directory.isEmpty
                          ? '选择图片目录'
                          : state.directory,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: state.directory.isEmpty
                            ? theme.colorScheme.outline
                            : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: state.isScanning || state.isClassifying
                      ? null
                      : _selectDirectory,
                  icon: const Icon(Icons.folder_open, size: 18),
                  label: const Text('浏览'),
                ),
                if (state.images.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Text(
                    '${state.images.length} 张图片',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRulesSection(ThemeData theme, ImageClassifierState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: '分类规则',
          icon: Icons.rule,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 20),
                onPressed: () => _showAddRuleDialog(context),
                tooltip: '添加规则',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              IconButton(
                icon: const Icon(Icons.auto_fix_high, size: 20),
                onPressed: () => _loadDefaultRules(context),
                tooltip: '加载默认规则',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: state.rules.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.rule_folder_outlined, size: 40, color: theme.disabledColor),
                        const SizedBox(height: 8),
                        Text(
                          '请添加分类规则',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.disabledColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.rules.length,
                  itemBuilder: (context, index) {
                    final rule = state.rules[index];
                    return _buildRuleTile(theme, rule, index, state);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildRuleTile(
    ThemeData theme,
    ClassificationRule rule,
    int index,
    ImageClassifierState state,
  ) {
    final typeIcon = switch (rule.type) {
      RuleType.extension => Icons.extension,
      RuleType.size => Icons.straighten,
      RuleType.namePattern => Icons.text_fields,
    };

    final typeLabel = switch (rule.type) {
      RuleType.extension => '扩展名',
      RuleType.size => '大小',
      RuleType.namePattern => '名称模式',
    };

    return ListTile(
      dense: true,
      leading: Icon(typeIcon, size: 20, color: theme.colorScheme.primary),
      title: Text(rule.name),
      subtitle: Text('$typeLabel: ${rule.pattern} -> ${rule.targetFolder}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Switch(
            value: rule.enabled,
            onChanged: (value) {
              context.read<ImageClassifierBloc>().add(
                    RuleUpdated(index, rule.copyWith(enabled: value)),
                  );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            color: theme.colorScheme.error,
            onPressed: state.isClassifying
                ? null
                : () => context
                    .read<ImageClassifierBloc>()
                    .add(RuleRemoved(index)),
            tooltip: '删除',
          ),
        ],
      ),
    );
  }

  Widget _buildActionSection(ThemeData theme, ImageClassifierState state) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: (state.images.isEmpty || state.rules.isEmpty || state.isClassifying)
                ? null
                : () => context
                    .read<ImageClassifierBloc>()
                    .add(const PreviewRequested()),
            icon: const Icon(Icons.preview),
            label: const Text('预览分类'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.icon(
            onPressed: state.classifiedGroups.isEmpty || state.isClassifying
                ? null
                : () => context
                    .read<ImageClassifierBloc>()
                    .add(const ExecuteRequested()),
            icon: const Icon(Icons.drive_file_move),
            label: const Text('执行移动'),
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.tertiary,
            ),
          ),
        ),
        if (state.isClassifying || state.isScanning) ...[
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: () => context
                .read<ImageClassifierBloc>()
                .add(const CancelRequested()),
            icon: const Icon(Icons.stop),
            label: const Text('取消'),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
              side: BorderSide(color: theme.colorScheme.error),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProgressSection(ThemeData theme, ImageClassifierState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    state.isScanning
                        ? '正在扫描图片...'
                        : '正在移动: ${state.progressText}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                Text(
                  '${(state.progress * 100).toStringAsFixed(0)}%',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: state.progress > 0 ? state.progress : null),
          ],
        ),
      ),
    );
  }

  Widget _buildClassifiedGroupsSection(
    ThemeData theme,
    ImageClassifierState state,
  ) {
    if (state.classifiedGroups.isEmpty) {
      return const EmptyState(
        icon: Icons.analytics_outlined,
        title: '暂无分类结果',
        description: '选择图片目录并配置规则后，点击"预览分类"',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: '分类预览',
          icon: Icons.category,
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Card(
            child: ListView.builder(
              itemCount: state.classifiedGroups.length,
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemBuilder: (context, index) {
                final entry = state.classifiedGroups.entries.elementAt(index);
                return _buildGroupTile(theme, entry.key, entry.value);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGroupTile(ThemeData theme, String groupName, List<String> files) {
    return ExpansionTile(
      title: Row(
        children: [
          const Icon(Icons.folder, color: Colors.amber, size: 20),
          const SizedBox(width: 8),
          Text(groupName),
          const SizedBox(width: 8),
          Chip(
            label: Text('${files.length}'),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
      children: files.map((filePath) {
        final fileName = filePath.split(Platform.pathSeparator).last;
        return ListTile(
          dense: true,
          leading: const Icon(Icons.image, size: 18),
          title: Text(
            fileName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            filePath,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall,
          ),
        );
      }).toList(),
    );
  }

  Future<void> _selectDirectory() async {
    final path = await FilePicker.platform.getDirectoryPath();
    if (path != null && mounted) {
      context.read<ImageClassifierBloc>().add(DirectorySelected(path));
    }
  }

  void _loadDefaultRules(BuildContext context) {
    for (final rule in ClassificationRule.defaults) {
      context.read<ImageClassifierBloc>().add(RuleAdded(rule));
    }
  }

  void _showAddRuleDialog(BuildContext context) {
    final nameController = TextEditingController();
    final patternController = TextEditingController();
    final folderController = TextEditingController();
    var selectedType = RuleType.extension;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('添加分类规则'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: '规则名称',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<RuleType>(
                  initialValue: selectedType,
                  decoration: const InputDecoration(
                    labelText: '规则类型',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: RuleType.extension,
                      child: Text('按扩展名'),
                    ),
                    DropdownMenuItem(
                      value: RuleType.size,
                      child: Text('按文件大小'),
                    ),
                    DropdownMenuItem(
                      value: RuleType.namePattern,
                      child: Text('按名称模式'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedType = value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: patternController,
                  decoration: InputDecoration(
                    labelText: _getPatternLabel(selectedType),
                    hintText: _getPatternHint(selectedType),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: folderController,
                  decoration: const InputDecoration(
                    labelText: '目标文件夹',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () {
                if (nameController.text.isEmpty ||
                    patternController.text.isEmpty ||
                    folderController.text.isEmpty) {
                  return;
                }
                context.read<ImageClassifierBloc>().add(
                      RuleAdded(ClassificationRule(
                        name: nameController.text,
                        type: selectedType,
                        pattern: patternController.text,
                        targetFolder: folderController.text,
                      )),
                    );
                Navigator.pop(ctx);
              },
              child: const Text('添加'),
            ),
          ],
        ),
      ),
    );
  }

  String _getPatternLabel(RuleType type) {
    return switch (type) {
      RuleType.extension => '扩展名列表',
      RuleType.size => '大小条件',
      RuleType.namePattern => '名称正则',
    };
  }

  String _getPatternHint(RuleType type) {
    return switch (type) {
      RuleType.extension => '.jpg,.jpeg,.png',
      RuleType.size => '>5242880 或 <1048576',
      RuleType.namePattern => 'screenshot|截图|screen',
    };
  }

  Widget _buildLogSection(ThemeData theme, ImageClassifierState state) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Row(
              children: [
                const Icon(Icons.terminal, size: 16),
                const SizedBox(width: 6),
                Text(
                  '操作日志',
                  style: theme.textTheme.titleSmall,
                ),
                const Spacer(),
                if (state.ruleLogs.isNotEmpty)
                  Text(
                    '${state.ruleLogs.length}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: state.ruleLogs.isEmpty
                ? Center(
                    child: Text(
                      '暂无日志',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    itemCount: state.ruleLogs.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 1),
                        child: Text(
                          state.ruleLogs[index],
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
