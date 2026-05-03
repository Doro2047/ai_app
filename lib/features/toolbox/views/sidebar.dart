/// 侧边栏组件
///
/// 首页/工具库/程序分类导航按钮，支持折叠/展开。
library;

import 'package:flutter/material.dart';

import '../models/category.dart';

/// 侧边栏组件
class Sidebar extends StatelessWidget {
  /// 是否展开
  final bool isExpanded;

  /// 切换展开/折叠回调
  final VoidCallback onToggle;

  /// 分类选择回调
  final ValueChanged<String> onCategorySelected;

  /// 添加程序回调
  final VoidCallback onAddProgram;

  /// 设置回调
  final VoidCallback onSettings;

  /// 当前选中的分类 ID
  final String currentCategoryId;

  const Sidebar({
    super.key,
    required this.isExpanded,
    required this.onToggle,
    required this.onCategorySelected,
    required this.onAddProgram,
    required this.onSettings,
    this.currentCategoryId = 'home',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = DefaultCategories.defaults;

    return Container(
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          // 顶部：标题和折叠按钮
          _buildHeader(context),
          const Divider(height: 1),
          // 导航按钮
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(
                vertical: isExpanded ? 8 : 4,
              ),
              children: [
                // 首页
                _SidebarButton(
                  icon: Icons.home_outlined,
                  label: '首页',
                  isExpanded: isExpanded,
                  isSelected: currentCategoryId == 'home',
                  onTap: () => onCategorySelected('home'),
                ),
                // 工具库
                _SidebarButton(
                  icon: Icons.build_outlined,
                  label: '工具库',
                  isExpanded: isExpanded,
                  isSelected: currentCategoryId == 'tool_library',
                  onTap: () => onCategorySelected('tool_library'),
                ),
                const SizedBox(height: 8),
                if (isExpanded)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '程序分类',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                if (!isExpanded) const Divider(height: 16, indent: 12, endIndent: 12),
                // 分类列表
                ...categories
                    .where((c) => c.id != 'all')
                    .map((category) => _SidebarButton(
                          icon: _getCategoryIcon(category.icon),
                          label: category.name,
                          isExpanded: isExpanded,
                          isSelected: currentCategoryId == category.id,
                          onTap: () => onCategorySelected(category.id),
                        )),
              ],
            ),
          ),
          const Divider(height: 1),
          // 底部操作按钮
          _SidebarButton(
            icon: Icons.add_outlined,
            label: '添加程序',
            isExpanded: isExpanded,
            isSelected: false,
            onTap: onAddProgram,
          ),
          _SidebarButton(
            icon: Icons.settings_outlined,
            label: '设置',
            isExpanded: isExpanded,
            isSelected: false,
            onTap: onSettings,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 56,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            if (isExpanded)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    'FREE工具箱',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            SizedBox(
              width: 48,
              height: 48,
              child: IconButton(
                icon: Icon(
                  isExpanded ? Icons.menu_open : Icons.menu,
                  size: 20,
                ),
                tooltip: isExpanded ? '折叠侧边栏' : '展开侧边栏',
                onPressed: onToggle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String iconName) {
    switch (iconName) {
      case 'folder':
        return Icons.folder_outlined;
      case 'settings':
        return Icons.settings_outlined;
      case 'wifi':
        return Icons.wifi_outlined;
      case 'play_circle':
        return Icons.play_circle_outline;
      case 'more_horiz':
        return Icons.more_horiz;
      default:
        return Icons.apps;
    }
  }
}

/// 侧边栏按钮
class _SidebarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isExpanded;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarButton({
    required this.icon,
    required this.label,
    required this.isExpanded,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final backgroundColor = isSelected
        ? colorScheme.primaryContainer
        : Colors.transparent;
    final foregroundColor = isSelected
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurface;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isExpanded ? 8 : 4,
        vertical: 2,
      ),
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            child: isExpanded
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Icon(icon, size: 20, color: foregroundColor),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            label,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: foregroundColor,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: Icon(icon, size: 20, color: foregroundColor),
                  ),
          ),
        ),
      ),
    );
  }
}
