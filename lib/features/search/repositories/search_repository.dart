/// 搜索仓库
///
/// 提供工具搜索功能，基于简单的字符串匹配。
library;

import '../../../app/routes/app_router.dart';
import '../models/search_result.dart';

/// 搜索仓库
class SearchRepository {
  /// 搜索工具（模糊匹配名称和描述）
  ///
  /// 使用简单的字符串包含匹配，不依赖外部搜索引擎。
  /// 返回按相关度排序的结果列表。
  List<SearchResult> searchTools(String query) {
    if (query.trim().isEmpty) {
      return [];
    }

    final lowerQuery = query.toLowerCase().trim();
    final results = <SearchResult>[];

    for (final tool in toolPages) {
      final lowerName = tool.name.toLowerCase();
      final lowerRoute = tool.route.toLowerCase();
      final description = _getToolDescription(tool.route).toLowerCase();

      // 计算相关度
      double relevance = 0.0;

      // 名称完全匹配 - 最高相关度
      if (lowerName == lowerQuery) {
        relevance = 1.0;
      }
      // 名称包含查询词
      else if (lowerName.contains(lowerQuery)) {
        relevance = 0.8;
        // 名称以查询词开头，相关度更高
        if (lowerName.startsWith(lowerQuery)) {
          relevance = 0.9;
        }
      }
      // 描述包含查询词
      else if (description.contains(lowerQuery)) {
        relevance = 0.5;
      }
      // 路由包含查询词
      else if (lowerRoute.contains(lowerQuery)) {
        relevance = 0.3;
      }

      if (relevance > 0) {
        results.add(SearchResult(
          toolId: tool.route.substring(1),
          toolName: tool.name,
          description: _getToolDescription(tool.route),
          route: tool.route,
          relevance: relevance,
        ));
      }
    }

    // 按相关度排序
    results.sort((a, b) => b.relevance.compareTo(a.relevance));

    return results;
  }

  /// 获取工具描述
  String _getToolDescription(String route) {
    switch (route) {
      case '/toolbox':
        return 'FREE 综合工具箱';
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
      default:
        return '工具';
    }
  }

  /// 获取最近搜索词
  List<String> getRecentSearches() {
    // TODO: 从 StorageService 读取最近搜索
    return [];
  }

  /// 保存搜索词到最近搜索
  void saveRecentSearch(String query) {
    // TODO: 保存到 StorageService
  }

  /// 清除最近搜索
  void clearRecentSearches() {
    // TODO: 从 StorageService 清除
  }
}
