import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/apk_installer/views/apk_installer_page.dart';
import '../../features/app_center/views/app_center_page.dart';
import '../../features/extension_changer/views/extension_changer_page.dart';
import '../../features/file_dedup/views/file_dedup_page.dart';
import '../../features/file_mover/views/file_mover_page.dart';
import '../../features/file_renamer/views/file_renamer_page.dart';
import '../../features/file_scanner/views/file_scanner_page.dart';
import '../../features/bookmark_manager/views/bookmark_manager_page.dart';
import '../../features/image_classifier/views/image_classifier_page.dart';
import '../../features/search/views/global_search_page.dart';
import '../../features/system_control/views/system_control_page.dart';
import '../../features/toolbox/views/toolbox_page.dart';

/// 路由路径常量
class AppRoutes {
  AppRoutes._();

  /// 首页
  static const String home = '/';

  /// FREE工具箱
  static const String toolbox = '/toolbox';

  /// APK批量安装工具
  static const String apkInstaller = '/apk-installer';

  /// 批量文件查重清理工具
  static const String fileDedup = '/file-dedup';

  /// 批量扩展名修改器
  static const String extensionChanger = '/extension-changer';

  /// 批量重命名工具
  static const String fileRenamer = '/file-renamer';

  /// 文件扫描器
  static const String fileScanner = '/file-scanner';

  /// 文件移动工具
  static const String fileMover = '/file-mover';

  /// 系统时间管理与设备控制工具
  static const String systemControl = '/system-control';

  /// Edge书签管理器
  static const String bookmarkManager = '/bookmark-manager';

  /// ImageClassifier
  static const String imageClassifier = '/image-classifier';

  /// 全局搜索
  static const String search = '/search';
}

/// 工具页面信息
class ToolPageInfo {
  final String route;
  final String name;
  final IconData icon;

  const ToolPageInfo({
    required this.route,
    required this.name,
    required this.icon,
  });
}

/// 所有工具页面列表
const List<ToolPageInfo> toolPages = [
  ToolPageInfo(
    route: AppRoutes.toolbox,
    name: 'FREE工具箱',
    icon: Icons.dashboard,
  ),
  ToolPageInfo(
    route: AppRoutes.apkInstaller,
    name: 'APK批量安装工具',
    icon: Icons.android,
  ),
  ToolPageInfo(
    route: AppRoutes.fileDedup,
    name: '批量文件查重清理工具',
    icon: Icons.cleaning_services,
  ),
  ToolPageInfo(
    route: AppRoutes.extensionChanger,
    name: '批量扩展名修改器',
    icon: Icons.edit_note,
  ),
  ToolPageInfo(
    route: AppRoutes.fileRenamer,
    name: '批量重命名工具',
    icon: Icons.drive_file_rename_outline,
  ),
  ToolPageInfo(
    route: AppRoutes.fileScanner,
    name: '文件扫描器',
    icon: Icons.scanner,
  ),
  ToolPageInfo(
    route: AppRoutes.fileMover,
    name: '文件移动工具',
    icon: Icons.drive_file_move_outline,
  ),
  ToolPageInfo(
    route: AppRoutes.systemControl,
    name: '系统时间管理与设备控制工具',
    icon: Icons.settings_system_daydream,
  ),
  ToolPageInfo(
    route: AppRoutes.bookmarkManager,
    name: 'Edge书签管理器',
    icon: Icons.bookmark_outline,
  ),
  ToolPageInfo(
    route: AppRoutes.imageClassifier,
    name: '图片分类器',
    icon: Icons.image_outlined,
  ),
];

/// 应用路由配置
class AppRouter {
  AppRouter._();

    /// 创建路由器，支持指定初始位置
  static GoRouter createRouter({String? initialLocation}) => GoRouter(
        initialLocation: initialLocation ?? AppRoutes.home,
        debugLogDiagnostics: true,
        routes: _buildRoutes(),
        errorBuilder: (context, state) => _ErrorPage(error: state.error),
      );

  /// 获取所有路由列表
  static List<RouteBase> get routes => _buildRoutes();

  static List<RouteBase> _buildRoutes() {
    return [
      // 首页 - 应用中心
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const AppCenterPage(),
      ),
      // 全局搜索
      GoRoute(
        path: AppRoutes.search,
        name: 'search',
        builder: (context, state) => const GlobalSearchPage(),
      ),
      // FREE工具箱
      GoRoute(
        path: AppRoutes.toolbox,
        name: 'toolbox',
        builder: (context, state) => const ToolboxPage(),
      ),
      // APK批量安装工具
      GoRoute(
        path: AppRoutes.apkInstaller,
        name: 'apk-installer',
        builder: (context, state) => const ApkInstallerPage(),
      ),
      // 批量文件查重清理工具
      GoRoute(
        path: AppRoutes.fileDedup,
        name: 'file-dedup',
        builder: (context, state) => const FileDedupPage(),
      ),
      // 批量扩展名修改器
      GoRoute(
        path: AppRoutes.extensionChanger,
        name: 'extension-changer',
        builder: (context, state) => const ExtensionChangerPage(),
      ),
      // 批量重命名工具
      GoRoute(
        path: AppRoutes.fileRenamer,
        name: 'file-renamer',
        builder: (context, state) => const FileRenamerPage(),
      ),
      // 文件扫描器
      GoRoute(
        path: AppRoutes.fileScanner,
        name: 'file-scanner',
        builder: (context, state) => const FileScannerPage(),
      ),
      // 文件移动工具
      GoRoute(
        path: AppRoutes.fileMover,
        name: 'file-mover',
        builder: (context, state) => const FileMoverPage(),
      ),
      // 系统时间管理与设备控制工具
      GoRoute(
        path: AppRoutes.systemControl,
        name: 'system-control',
        builder: (context, state) => const SystemControlPage(),
      ),
      // Edge书签管理器
      GoRoute(
        path: AppRoutes.bookmarkManager,
        name: 'bookmark-manager',
        builder: (context, state) => const BookmarkManagerPage(),
      ),
      GoRoute(
        path: AppRoutes.imageClassifier,
        name: 'image-classifier',
        builder: (context, state) => const ImageClassifierPage(),
      ),
    ];
  }
}

// ============================================================
// 页面组件
// ============================================================

/// 占位页面 - 用于尚未实现的工具页面
class _PlaceholderPage extends StatelessWidget {
  final String title;
  final IconData icon;

  const _PlaceholderPage({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 72, color: theme.colorScheme.primary.withValues(alpha: 0.5)),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '功能开发中...',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.tonal(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('返回首页'),
            ),
          ],
        ),
      ),
    );
  }
}

/// 404 错误页面
class _ErrorPage extends StatelessWidget {
  final GoException? error;

  const _ErrorPage({this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('页面未找到'),
            if (error != null) ...[
              const SizedBox(height: 8),
              Text(
                error!.message,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('返回首页'),
            ),
          ],
        ),
      ),
    );
  }
}
