/// 程序卡片组件
///
/// 悬停高亮、异步图标加载、双击/长按事件、运行状态指示。
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/program_bloc.dart';
import '../bloc/process_bloc.dart';
import '../models/program.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';

/// 程序卡片
class ProgramCard extends StatefulWidget {
  /// 程序信息
  final ProgramInfo program;

  const ProgramCard({
    super.key,
    required this.program,
  });

  @override
  State<ProgramCard> createState() => _ProgramCardState();
}

class _ProgramCardState extends State<ProgramCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRunning = context.select(
      (ProcessBloc bloc) => bloc.state.isRunning(widget.program.id),
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onDoubleTap: () => _launchProgram(context),
        onLongPress: () => _showContextMenu(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: _isHovered
                ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
                : theme.cardColor,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: _isHovered
                  ? theme.colorScheme.primary.withValues(alpha: 0.5)
                  : theme.colorScheme.outlineVariant,
              width: _isHovered ? 1.5 : 0.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 图标区域
                Stack(
                  children: [
                    _buildIcon(context),
                    // 运行状态指示器
                    if (isRunning)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.colorScheme.surface,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                // 程序名称
                Text(
                  widget.program.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                // 描述
                if (widget.program.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    widget.program.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                // 使用次数
                if (widget.program.useCount > 0) ...[
                  const SizedBox(height: 2),
                  Text(
                    '已使用 ${widget.program.useCount} 次',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    final theme = Theme.of(context);
    const iconSize = 36.0;

    // 如果有图标名称，使用 Material Icon
    if (widget.program.icon.isNotEmpty) {
      final iconData = _getIconData(widget.program.icon);
      if (iconData != null) {
        return Icon(iconData, size: iconSize, color: theme.colorScheme.primary);
      }
    }

    // 默认图标
    return Icon(
      Icons.apps,
      size: iconSize,
      color: theme.colorScheme.primary,
    );
  }

  IconData? _getIconData(String iconName) {
    const iconMap = {
      'calculate': Icons.calculate,
      'edit_note': Icons.edit_note,
      'brush': Icons.brush,
      'terminal': Icons.terminal,
      'monitor_heart': Icons.monitor_heart,
      'tune': Icons.tune,
      'folder': Icons.folder,
      'settings': Icons.settings,
      'wifi': Icons.wifi,
      'play_circle': Icons.play_circle,
      'more_horiz': Icons.more_horiz,
      'apps': Icons.apps,
    };
    return iconMap[iconName];
  }

  void _launchProgram(BuildContext context) {
    context.read<ProgramBloc>().add(ProgramLaunched(widget.program.id));
    context.read<ProcessBloc>().add(ProcessLaunched(
          programId: widget.program.id,
          programName: widget.program.name,
          programPath: widget.program.path,
        ));
  }

  void _showContextMenu(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                widget.program.name,
                style: theme.textTheme.titleMedium,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.play_arrow),
              title: const Text('启动'),
              onTap: () {
                Navigator.pop(context);
                _launchProgram(this.context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('编辑'),
              onTap: () {
                Navigator.pop(context);
                // TODO: 编辑程序
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('详细信息'),
              onTap: () {
                Navigator.pop(context);
                _showDetailDialog(this.context);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: theme.colorScheme.error),
              title: Text('删除', style: TextStyle(color: theme.colorScheme.error)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(this.context);
              },
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }

  void _showDetailDialog(BuildContext context) {
    final p = widget.program;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(p.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow('路径', p.path),
              _detailRow('分类', p.category),
              _detailRow('描述', p.description),
              _detailRow('版本', p.version),
              _detailRow('使用次数', '${p.useCount}'),
              _detailRow('最后使用', p.lastUsed),
              _detailRow('创建时间', p.createdAt),
              _detailRow('启用', p.enabled ? '是' : '否'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除 "${widget.program.name}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              this.context.read<ProgramBloc>().add(
                    ProgramDeleted(widget.program.id),
                  );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}
