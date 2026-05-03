/// 工具库面板
///
/// 预注册系统工具集合。
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/program_bloc.dart';
import 'program_card.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/empty_state.dart';

/// 工具库面板
class ToolLibraryPanel extends StatelessWidget {
  const ToolLibraryPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<ProgramBloc, ProgramState>(
      builder: (context, state) {
        final toolLibraryPrograms =
            state.programs.where((p) => p.isToolLibrary).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题栏
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Icon(Icons.build_circle_outlined,
                      size: 24, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text('系统工具库', style: theme.textTheme.titleLarge),
                  const Spacer(),
                  Text(
                    '${toolLibraryPrograms.length} 个工具',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            // 工具网格
            Expanded(
              child: toolLibraryPrograms.isEmpty
                  ? const EmptyState(
                      icon: Icons.build_outlined,
                      title: '暂无系统工具',
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount =
                            (constraints.maxWidth / 180).floor().clamp(2, 6);
                        final childAspectRatio =
                            (constraints.maxWidth / crossAxisCount - 32) / 140;

                        return GridView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.sm,
                          ),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            childAspectRatio:
                                childAspectRatio.clamp(0.8, 1.5),
                            crossAxisSpacing: AppSpacing.md,
                            mainAxisSpacing: AppSpacing.md,
                          ),
                          itemCount: toolLibraryPrograms.length,
                          itemBuilder: (context, index) {
                            return ProgramCard(
                                program: toolLibraryPrograms[index]);
                          },
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
