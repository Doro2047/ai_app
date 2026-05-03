/// 应用工具数据模型
///
/// 用于 AppCenter 中显示的工具信息。
library;

/// 应用工具模型
class AppTool {
  /// 工具唯一 ID
  final String id;

  /// 工具名称
  final String name;

  /// 工具描述
  final String description;

  /// 工具图标 (Material Icon 字符串)
  final String icon;

  /// 工具路由路径
  final String route;

  /// 工具分类 (file_management / system_tool / other)
  final String category;

  /// 是否启用
  final bool enabled;

  /// 最后使用时间 (ISO 8601 字符串)
  final String lastUsed;

  /// 使用次数
  final int useCount;

  const AppTool({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.route,
    this.category = 'other',
    this.enabled = true,
    this.lastUsed = '',
    this.useCount = 0,
  });

  /// 从 JSON 创建
  factory AppTool.fromJson(Map<String, dynamic> json) {
    return AppTool(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      route: json['route'] as String,
      category: json['category'] as String? ?? 'other',
      enabled: json['enabled'] as bool? ?? true,
      lastUsed: json['lastUsed'] as String? ?? '',
      useCount: json['useCount'] as int? ?? 0,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'route': route,
      'category': category,
      'enabled': enabled,
      'lastUsed': lastUsed,
      'useCount': useCount,
    };
  }

  /// 复制并修改
  AppTool copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    String? route,
    String? category,
    bool? enabled,
    String? lastUsed,
    int? useCount,
  }) {
    return AppTool(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      route: route ?? this.route,
      category: category ?? this.category,
      enabled: enabled ?? this.enabled,
      lastUsed: lastUsed ?? this.lastUsed,
      useCount: useCount ?? this.useCount,
    );
  }

  @override
  String toString() {
    return 'AppTool(id: $id, name: $name, category: $category, useCount: $useCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppTool && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
