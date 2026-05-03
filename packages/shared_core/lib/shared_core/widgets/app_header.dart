/// 应用标题栏组件
///
/// 显示页面标题、主题切换按钮和皮肤选择器。
/// 对应 Python CustomTkinter 的 BaseApp 标题栏部分。
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../theme/app_theme.dart';
import '../bloc/theme_bloc.dart';

/// 应用标题栏组件
///
/// 包含标题、主题切换按钮（亮色/暗色）和皮肤选择器。
/// 最小触控目标 48x48 逻辑像素。
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  /// 页面标题
  final String title;

  /// 左侧 leading 组件（如返回按钮）
  final Widget? leading;

  /// 右侧附加操作按钮
  final List<Widget>? actions;

  /// 是否显示主题切换按钮
  final bool showThemeToggle;

  /// 是否显示皮肤选择按钮
  final bool showSkinPicker;

  const AppHeader({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.showThemeToggle = true,
    this.showSkinPicker = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final skinName = context.select(
      (ThemeBloc bloc) => bloc.state.currentSkin.name,
    );

    return AppBar(
      leading: leading,
      title: Text(
        title,
        style: theme.appBarTheme.titleTextStyle,
      ),
      centerTitle: true,
      actions: [
        if (showThemeToggle) ...[
          _ThemeToggleIconButton(skinName: skinName),
        ],
        if (showSkinPicker) ...[
          _SkinPickerButton(),
        ],
        if (actions != null) ...actions!,
      ],
    );
  }
}

/// 主题切换按钮（内部组件）
class _ThemeToggleIconButton extends StatelessWidget {
  final String skinName;

  const _ThemeToggleIconButton({required this.skinName});

  @override
  Widget build(BuildContext context) {
    final isDark = context.select((ThemeBloc bloc) => bloc.state.isDarkMode);
    final theme = Theme.of(context);

    return Tooltip(
      message: isDark ? '切换到亮色模式' : '切换到暗色模式',
      waitDuration: const Duration(milliseconds: 500),
      child: SizedBox(
        width: 48,
        height: 48,
        child: IconButton(
          icon: Icon(
            isDark ? Icons.dark_mode : Icons.light_mode,
            color: theme.iconTheme.color,
          ),
          onPressed: () {
            context.read<ThemeBloc>().add(const ThemeToggled());
          },
        ),
      ),
    );
  }
}

/// 皮肤选择按钮（内部组件）
class _SkinPickerButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Tooltip(
      message: '选择主题皮肤',
      waitDuration: const Duration(milliseconds: 500),
      child: SizedBox(
        width: 48,
        height: 48,
        child: IconButton(
          icon: Icon(
            Icons.palette_outlined,
            color: theme.iconTheme.color,
          ),
          onPressed: () => _showSkinPickerDialog(context),
        ),
      ),
    );
  }

  void _showSkinPickerDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => const _SkinPickerDialog(),
    );
  }
}

/// 皮肤选择对话框（内部组件）
class _SkinPickerDialog extends StatelessWidget {
  const _SkinPickerDialog();

  @override
  Widget build(BuildContext context) {
    final skins = AppTheme.allSkins;
    final currentSkin = context.select(
      (ThemeBloc bloc) => bloc.state.currentSkin.name,
    );

    return AlertDialog(
      title: const Text('选择主题皮肤'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: skins.length,
          itemBuilder: (context, index) {
            final skin = skins[index];
            final isSelected = skin.name == currentSkin;

            return RadioListTile<String>(
              title: Row(
                children: [
                  Text(skin.displayName),
                  const SizedBox(width: 8),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: skin.accent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
              value: skin.name,
              groupValue: currentSkin,
              onChanged: (value) {
                if (value != null) {
                  final skinType = SkinType.values.firstWhere(
                    (t) => t.name == value,
                    orElse: () => SkinType.defaultLight,
                  );
                  context.read<ThemeBloc>().add(SkinChanged(skinType));
                  Navigator.of(context).pop();
                }
              },
              selected: isSelected,
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
      ],
    );
  }
}

