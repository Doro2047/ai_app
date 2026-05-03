/// 工具箱主页面
///
/// 侧边栏 + 主区域布局，使用 AppScaffold。
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/toolbox_bloc.dart';
import '../bloc/program_bloc.dart';
import '../bloc/hardware_bloc.dart';
import '../bloc/process_bloc.dart';
import '../repositories/program_repository.dart';
import '../repositories/hardware_repository.dart';
import 'sidebar.dart';
import 'home_page.dart';
import 'program_list_panel.dart';
import 'tool_library_panel.dart';
import 'add_program_dialog.dart';
import 'settings_dialog.dart';

/// 工具箱主页面
class ToolboxPage extends StatelessWidget {
  const ToolboxPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) {
            final bloc = ToolboxBloc();
            bloc.init();
            bloc.add(const ToolboxInitialized());
            return bloc;
          },
        ),
        BlocProvider(
          create: (_) {
            final bloc = ProgramBloc(
              repository: context.read<ProgramRepository>(),
            );
            bloc.init();
            bloc.add(const ProgramsLoaded());
            return bloc;
          },
        ),
        BlocProvider(
          create: (_) {
            final bloc = HardwareBloc(
              repository: context.read<HardwareRepository>(),
            );
            bloc.init();
            bloc.add(const HardwareInfoRequested());
            return bloc;
          },
        ),
        BlocProvider(
          create: (_) {
            final bloc = ProcessBloc();
            bloc.init();
            return bloc;
          },
        ),
      ],
      child: const _ToolboxView(),
    );
  }
}

class _ToolboxView extends StatelessWidget {
  const _ToolboxView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<ToolboxBloc, ToolboxState>(
      builder: (context, toolboxState) {
        return Scaffold(
          body: Row(
            children: [
              // 侧边栏
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                width: toolboxState.isSidebarExpanded ? 220 : 60,
                child: Sidebar(
                  isExpanded: toolboxState.isSidebarExpanded,
                  onToggle: () {
                    context.read<ToolboxBloc>().add(const SidebarToggled());
                  },
                  onCategorySelected: (categoryId) {
                    context.read<ToolboxBloc>().add(
                          CategorySelected(categoryId),
                        );
                  },
                  onAddProgram: () => _showAddProgramDialog(context),
                  onSettings: () => _showSettingsDialog(context),
                  currentCategoryId: toolboxState.currentCategoryId,
                ),
              ),
              // 分隔线
              Container(
                width: 1,
                color: theme.colorScheme.outlineVariant,
              ),
              // 主内容区域
              Expanded(
                child: _buildMainContent(context, toolboxState),
              ),
            ],
          ),
          floatingActionButton: toolboxState.currentCategoryId != 'home' &&
                  toolboxState.currentCategoryId != 'tool_library'
              ? FloatingActionButton(
                  onPressed: () => _showAddProgramDialog(context),
                  tooltip: '添加程序',
                  child: const Icon(Icons.add),
                )
              : null,
        );
      },
    );
  }

  Widget _buildMainContent(BuildContext context, ToolboxState state) {
    switch (state.currentCategoryId) {
      case 'home':
        return const HomePage();
      case 'tool_library':
        return const ToolLibraryPanel();
      default:
        return ProgramListPanel(
          categoryId: state.currentCategoryId,
          searchQuery: state.searchQuery,
        );
    }
  }

  void _showAddProgramDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => const AddProgramDialog(),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => const SettingsDialog(),
    );
  }
}
