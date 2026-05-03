/// 全局搜索页面
///
/// 提供全应用级别的工具搜索功能。
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes/app_router.dart';
import '../models/search_result.dart';
import '../repositories/search_repository.dart';

/// 全局搜索页面
class GlobalSearchPage extends StatefulWidget {
  const GlobalSearchPage({super.key});

  @override
  State<GlobalSearchPage> createState() => _GlobalSearchPageState();
}

class _GlobalSearchPageState extends State<GlobalSearchPage> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  final _searchRepository = SearchRepository();

  List<SearchResult> _results = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // 自动聚焦搜索框
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// 执行搜索
  void _performSearch(String query) {
    setState(() {
      _isSearching = true;
    });

    // 模拟异步搜索延迟
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;

      final results = _searchRepository.searchTools(query);
      setState(() {
        _results = results;
        _isSearching = false;
      });
    });
  }

  /// 清除搜索
  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _results = [];
    });
  }

  /// 导航到工具
  void _navigateToTool(SearchResult result) {
    context.go(result.route);
  }

  /// 获取工具图标
  IconData _getToolIcon(String route) {
    final matchingTool = toolPages.firstWhere(
      (t) => t.route == route,
      orElse: () => const ToolPageInfo(
        route: '',
        name: '',
        icon: Icons.build,
      ),
    );
    return matchingTool.icon;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildSearchBar(),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // 搜索结果区域
          Expanded(
            child: _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  /// 构建搜索栏
  Widget _buildSearchBar() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
          tooltip: '返回',
        ),
        Expanded(
          child: TextField(
            controller: _searchController,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: '搜索工具名称或描述...',
              border: InputBorder.none,
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _clearSearch,
                      tooltip: '清除',
                    )
                  : null,
            ),
            onChanged: _performSearch,
          ),
        ),
      ],
    );
  }

  /// 构建搜索结果
  Widget _buildSearchResults() {
    // 搜索中
    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // 空查询状态
    if (_searchController.text.trim().isEmpty) {
      return _buildEmptyState();
    }

    // 无结果状态
    if (_results.isEmpty) {
      return _buildNoResultsState();
    }

    // 搜索结果列表
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final result = _results[index];
        return _SearchResultTile(
          result: result,
          icon: _getToolIcon(result.route),
          onTap: () => _navigateToTool(result),
        );
      },
    );
  }

  /// 构建空查询状态
  Widget _buildEmptyState() {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search,
            size: 72,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '输入关键词搜索工具',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '可搜索工具名称或描述',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建无结果状态
  Widget _buildNoResultsState() {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off,
            size: 72,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '未找到相关工具',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '尝试使用其他关键词',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

/// 搜索结果列表项
class _SearchResultTile extends StatelessWidget {
  final SearchResult result;
  final IconData icon;
  final VoidCallback onTap;

  const _SearchResultTile({
    required this.result,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: colorScheme.onPrimaryContainer,
          size: 24,
        ),
      ),
      title: Text(
        result.toolName,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        result.description,
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: FilledButton.tonal(
        onPressed: onTap,
        child: const Text('打开'),
      ),
      onTap: onTap,
    );
  }
}
