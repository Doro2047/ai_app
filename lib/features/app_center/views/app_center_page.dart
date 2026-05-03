/// 应用中心页面
///
/// 显示所有可用工具，支持分类筛选和全局搜索导航。
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes/app_router.dart';
import '../../../core/utils/platform_utils.dart';
import '../../../app/app_di.dart';
import '../../../core/storage/storage_service.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/empty_state.dart';
import '../models/app_tool.dart';

/// AppCenter 页面
class AppCenterPage extends StatefulWidget {
  const AppCenterPage({super.key});

  @override
  State<AppCenterPage> createState() => _AppCenterPageState();
}

class _AppCenterPageState extends State<AppCenterPage> {
  String _selectedCategory = '全部';
  late List<AppTool> _tools;

  static const List<String> _categories = [
    '全部',
    '文件管理',
    '系统工具',
    '其他',
  ];

  @override
  void initState() {
    super.initState();
    _tools = _buildToolList();
  }

  /// 构建工具列表（从路由配置中提取）
  List<AppTool> _buildToolList() {
    // 使用工具名称和图标数据构建 AppTool 列表
    return toolPages.map((tool) {
      // 根据工具名称确定分类
      String category;
      if (_isFileManagement(tool.name)) {
        category = '文件管理';
      } else if (_isSystemTool(tool.name)) {
        category = '系统工具';
      } else {
        category = '其他';
      }

      // 从 StorageService 读取使用次数
      final storage = getIt<StorageService>();
      final useCount = storage.getInt('tool_use_count_${tool.route}') ?? 0;
      final lastUsed = storage.getString('tool_last_used_${tool.route}') ?? '';

      return AppTool(
        id: tool.route.substring(1), // 去掉开头的 /
        name: tool.name,
        description: _getToolDescription(tool.route),
        icon: _iconDataToString(tool.icon),
        route: tool.route,
        category: category,
        enabled: true,
        lastUsed: lastUsed,
        useCount: useCount,
      );
    }).toList()
      ..sort((a, b) => b.useCount.compareTo(a.useCount)); // 使用频率高的排前面
  }

  /// 判断是否为文件管理类工具
  bool _isFileManagement(String name) {
    return name.contains('重命名') ||
        name.contains('查重') ||
        name.contains('扩展名') ||
        name.contains('文件扫描') ||
        name.contains('文件移动') ||
        name.contains('文件管理');
  }

  /// 判断是否为系统工具类工具
  bool _isSystemTool(String name) {
    return name.contains('系统') ||
        name.contains('设备控制') ||
        name.contains('安装') ||
        name.contains('APK');
  }

  /// 获取工具描述
  String _getToolDescription(String route) {
    switch (route) {
      case '/apk-installer':
        return '批量安装 APK 应用文件';
      case '/file-dedup':
        return '扫描并删除重复文件，释放磁盘空间';
      case '/extension-changer':
        return '批量修改文件扩展名';
      case '/file-renamer':
        return '按照规则批量重命名文件';
      case '/file-scanner':
        return '扫描目录文件并统计信息';
      case '/file-mover':
        return '按照规则批量移动文件到目标目录';
      case '/system-control':
        return '同步系统时间和控制设备状态';
      case '/bookmark-manager':
        return '管理浏览器书签';
      case '/image-classifier':
        return '使用 AI 对图片进行分类整理';
      case '/toolbox':
        return 'FREE 综合工具箱';
      default:
        return '工具';
    }
  }

  /// 将 IconData 转换为字符串名称
  String _iconDataToString(IconData icon) {
    return icon.codePoint.toString();
  }

  /// 获取过滤后的工具列表
  List<AppTool> get _filteredTools {
    if (_selectedCategory == '全部') {
      return _tools;
    }
    return _tools.where((tool) => tool.category == _selectedCategory).toList();
  }

  /// 打开全局搜索
  void _openSearch() {
    context.push('/search');
  }

  /// 导航到工具页面并记录使用次数
  void _navigateToTool(AppTool tool) {
    // 记录使用次数
    final count = tool.useCount + 1;
    final storage = getIt<StorageService>();
    storage.setInt('tool_use_count_${tool.route}', count);
    storage.setString(
      'tool_last_used_${tool.route}',
      DateTime.now().toIso8601String(),
    );

    context.go(tool.route);
  }

  /// 获取列数（响应式）
  int _getColumnCount(double width) {
    if (PlatformUtils.isDesktop()) {
      return 3;
    }
    if (width >= 600) {
      return 2; // 平板
    }
    return 1; // 手机
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'AI Apps 工具集',
      showThemeToggle: true,
      showSkinPicker: true,
      headerActions: [
        IconButton(
          icon: const Icon(Icons.search),
          tooltip: '全局搜索',
          onPressed: _openSearch,
        ),
      ],
      body: Column(
        children: [
          // 分类标签
          _buildCategoryTabs(),
          // 工具网格
          Expanded(
            child: _buildToolsGrid(),
          ),
        ],
      ),
    );
  }

  /// 构建分类标签
  Widget _buildCategoryTabs() {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                });
              },
            ),
          );
        },
      ),
    );
  }

  /// 构建工具网格
  Widget _buildToolsGrid() {
    final tools = _filteredTools;

    if (tools.isEmpty) {
      return const EmptyState(
        icon: Icons.folder_open,
        title: '暂无工具',
        description: '该分类下没有可用工具',
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columnCount = _getColumnCount(constraints.maxWidth);
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columnCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: tools.length,
          itemBuilder: (context, index) {
            return _ToolCard(
              tool: tools[index],
              onTap: () => _navigateToTool(tools[index]),
            );
          },
        );
      },
    );
  }
}

/// 工具卡片组件
class _ToolCard extends StatelessWidget {
  final AppTool tool;
  final VoidCallback onTap;

  const _ToolCard({
    required this.tool,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 图标和名称
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      IconData(
                        int.tryParse(tool.icon) ?? Icons.build.codePoint,
                        fontFamily: 'MaterialIcons',
                      ),
                      color: colorScheme.onPrimaryContainer,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      tool.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // 描述
              Text(
                tool.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              // 使用次数
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '使用 ${tool.useCount} 次',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
