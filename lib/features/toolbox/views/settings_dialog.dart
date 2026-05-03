/// 设置对话框
///
/// 设置对话框（主题/语言/自动扫描等）。
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../repositories/config_repository.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/bloc/theme_bloc.dart';

/// 设置对话框
class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  bool _autoScan = false;
  int _maxConcurrent = 5;
  bool _showSystemTools = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final repo = context.read<ConfigRepository>();
    setState(() {
      _autoScan = repo.getConfig('auto_scan', false);
      _maxConcurrent = repo.getConfig('max_concurrent', 5);
      _showSystemTools = repo.getConfig('show_system_tools', true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('设置'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 主题设置
              Text('主题', style: theme.textTheme.titleSmall),
              const SizedBox(height: AppSpacing.sm),
              ListTile(
                leading: const Icon(Icons.dark_mode_outlined),
                title: const Text('主题模式'),
                trailing: BlocBuilder<ThemeBloc, ThemeState>(
                  builder: (context, state) {
                    return DropdownButton<String>(
                      value: state.currentMode.name,
                      underline: const SizedBox.shrink(),
                      items: const [
                        DropdownMenuItem(value: 'light', child: Text('亮色')),
                        DropdownMenuItem(value: 'dark', child: Text('暗色')),
                        DropdownMenuItem(value: 'system', child: Text('跟随系统')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          final mode = AppThemeMode.values.firstWhere(
                            (m) => m.name == value,
                          );
                          context.read<ThemeBloc>().add(ModeChanged(mode));
                        }
                      },
                    );
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.palette_outlined),
                title: const Text('主题皮肤'),
                trailing: BlocBuilder<ThemeBloc, ThemeState>(
                  builder: (context, state) {
                    return DropdownButton<String>(
                      value: state.currentSkin.name,
                      underline: const SizedBox.shrink(),
                      items: AppTheme.allSkins
                          .map((skin) => DropdownMenuItem(
                                value: skin.name,
                                child: Text(skin.displayName),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          final skinType = SkinType.values.firstWhere(
                            (t) => t.name == value,
                          );
                          context.read<ThemeBloc>().add(SkinChanged(skinType));
                        }
                      },
                    );
                  },
                ),
              ),
              const Divider(),
              // 程序设置
              Text('程序', style: theme.textTheme.titleSmall),
              const SizedBox(height: AppSpacing.sm),
              SwitchListTile(
                secondary: const Icon(Icons.sync_outlined),
                title: const Text('自动扫描'),
                subtitle: const Text('启动时自动扫描指定目录'),
                value: _autoScan,
                onChanged: (value) {
                  setState(() => _autoScan = value);
                  context.read<ConfigRepository>().setConfig('auto_scan', value);
                },
              ),
              SwitchListTile(
                secondary: const Icon(Icons.build_outlined),
                title: const Text('显示系统工具'),
                subtitle: const Text('在工具库中显示系统自带工具'),
                value: _showSystemTools,
                onChanged: (value) {
                  setState(() => _showSystemTools = value);
                  context.read<ConfigRepository>().setConfig('show_system_tools', value);
                },
              ),
              ListTile(
                leading: const Icon(Icons.sync_outlined),
                title: const Text('最大并发进程数'),
                trailing: DropdownButton<int>(
                  value: _maxConcurrent,
                  underline: const SizedBox.shrink(),
                  items: [1, 2, 3, 5, 10]
                      .map((v) => DropdownMenuItem(
                            value: v,
                            child: Text('$v'),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _maxConcurrent = value);
                      context.read<ConfigRepository>().setConfig('max_concurrent', value);
                    }
                  },
                ),
              ),
              const Divider(),
              // 数据管理
              Text('数据管理', style: theme.textTheme.titleSmall),
              const SizedBox(height: AppSpacing.sm),
              ListTile(
                leading: const Icon(Icons.cleaning_services_outlined),
                title: const Text('清理无效程序'),
                subtitle: const Text('移除路径不存在的程序'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: 触发清理
                },
              ),
              ListTile(
                leading: const Icon(Icons.restore_outlined),
                title: const Text('重置设置'),
                subtitle: const Text('恢复默认设置'),
                onTap: () {
                  _showResetConfirmDialog(context);
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('关闭'),
        ),
      ],
    );
  }

  void _showResetConfirmDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认重置'),
        content: const Text('确定要恢复默认设置吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () async {
              await context.read<ConfigRepository>().clearAll();
              if (!context.mounted) return;
              Navigator.pop(context); // 关闭确认对话框
              Navigator.pop(this.context); // 关闭设置对话框
              setState(() {
                _autoScan = false;
                _maxConcurrent = 5;
                _showSystemTools = true;
              });
            },
            child: const Text('重置'),
          ),
        ],
      ),
    );
  }
}
