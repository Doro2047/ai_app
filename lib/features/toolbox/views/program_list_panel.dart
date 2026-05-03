/// 程序列表面板
///
/// 网格布局卡片列表 + 搜索框。
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/toolbox_bloc.dart';
import '../bloc/program_bloc.dart';
import '../models/program.dart';
import 'program_card.dart';
import 'add_program_dialog.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_widget.dart';

/// 程序列表面板
class ProgramListPanel extends StatelessWidget {
  /// 当前分类 ID
  final String categoryId;

  /// 搜索查询
  final String searchQuery;

  const ProgramListPanel({
    super.key,
    required this.categoryId,
    this.searchQuery = '',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // 搜索栏
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: TextField(
            decoration: InputDecoration(
              hintText: '搜索程序...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        context
                            .read<ToolboxBloc>()
                            .add(const SearchChanged(''));
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              context.read<ToolboxBloc>().add(SearchChanged(value));
            },
          ),
        ),
        // 程序网格
        Expanded(
          child: BlocBuilder<ProgramBloc, ProgramState>(
            builder: (context, programState) {
              if (programState.isLoading) {
                return const LoadingWidget();
              }

              if (programState.error != null) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text('加载失败', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text(programState.error!,
                          style: theme.textTheme.bodySmall),
                      const SizedBox(height: 16),
                      FilledButton.tonal(
                        onPressed: () => context
                            .read<ProgramBloc>()
                            .add(const ProgramsLoaded()),
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                );
              }

              // 过滤程序
              final filtered = _filterPrograms(
                programState.programs,
                categoryId,
                searchQuery,
              );

              if (filtered.isEmpty) {
                return EmptyState(
                  icon: Icons.apps_outlined,
                  title: searchQuery.isNotEmpty
                      ? '未找到匹配的程序'
                      : '该分类下暂无程序',
                  actionText: '添加程序',
                  onAction: () => _showAddProgramDialog(context),
                );
              }

              return _ProgramGrid(programs: filtered);
            },
          ),
        ),
      ],
    );
  }

  List<ProgramInfo> _filterPrograms(
    List<ProgramInfo> programs,
    String categoryId,
    String query,
  ) {
    var result = programs;

    // 按分类筛选
    if (categoryId != 'all') {
      result = result.where((p) => p.category == categoryId).toList();
    }

    // 搜索过滤
    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      result = result.where((p) {
        return p.name.toLowerCase().contains(q) ||
            p.description.toLowerCase().contains(q) ||
            p.path.toLowerCase().contains(q);
      }).toList();
    }

    return result;
  }

  void _showAddProgramDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => const AddProgramDialog(),
    );
  }
}

/// 程序网格
class _ProgramGrid extends StatelessWidget {
  final List<ProgramInfo> programs;

  const _ProgramGrid({required this.programs});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 根据宽度计算列数
        final crossAxisCount = (constraints.maxWidth / 180).floor().clamp(2, 6);
        final childAspectRatio = (constraints.maxWidth / crossAxisCount - 32) / 140;

        return GridView.builder(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio.clamp(0.8, 1.5),
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
          ),
          itemCount: programs.length,
          itemBuilder: (context, index) {
            return ProgramCard(program: programs[index]);
          },
        );
      },
    );
  }
}
