/// 搜索结果数据模型
///
/// 用于全局搜索功能的结果展示。
library;

/// 搜索结果模型
class SearchResult {
  /// 工具 ID
  final String toolId;

  /// 工具名称
  final String toolName;

  /// 工具描述
  final String description;

  /// 工具路由路径
  final String route;

  /// 相关度 (0.0 - 1.0)
  final double relevance;

  const SearchResult({
    required this.toolId,
    required this.toolName,
    required this.description,
    required this.route,
    required this.relevance,
  });

  /// 从 JSON 创建
  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      toolId: json['toolId'] as String,
      toolName: json['toolName'] as String,
      description: json['description'] as String,
      route: json['route'] as String,
      relevance: (json['relevance'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'toolId': toolId,
      'toolName': toolName,
      'description': description,
      'route': route,
      'relevance': relevance,
    };
  }

  /// 复制并修改
  SearchResult copyWith({
    String? toolId,
    String? toolName,
    String? description,
    String? route,
    double? relevance,
  }) {
    return SearchResult(
      toolId: toolId ?? this.toolId,
      toolName: toolName ?? this.toolName,
      description: description ?? this.description,
      route: route ?? this.route,
      relevance: relevance ?? this.relevance,
    );
  }

  @override
  String toString() {
    return 'SearchResult(toolName: $toolName, relevance: $relevance)';
  }
}
