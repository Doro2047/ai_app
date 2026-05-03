/// 程序数据模型
///
/// 对应 Python ProgramInfo，包含程序的所有元数据信息。
library;

import 'package:equatable/equatable.dart';

/// 程序模型
class ProgramInfo extends Equatable {
  /// 唯一标识
  final String id;

  /// 程序名称
  final String name;

  /// 程序路径
  final String path;

  /// 图标路径
  final String icon;

  /// 分类 ID
  final String category;

  /// 描述
  final String description;

  /// 使用次数
  final int useCount;

  /// 最后使用时间
  final String lastUsed;

  /// 创建时间
  final String createdAt;

  /// 版本号
  final String version;

  /// 源代码目录
  final String sourceDir;

  /// 是否启用
  final bool enabled;

  /// 是否为工具库程序
  final bool isToolLibrary;

  const ProgramInfo({
    required this.id,
    required this.name,
    required this.path,
    this.icon = '',
    this.category = 'all',
    this.description = '',
    this.useCount = 0,
    this.lastUsed = '',
    this.createdAt = '',
    this.version = '',
    this.sourceDir = '',
    this.enabled = true,
    this.isToolLibrary = false,
  });

  /// 从 JSON Map 创建
  factory ProgramInfo.fromDict(Map<String, dynamic> data) {
    return ProgramInfo(
      id: data['id'] as String? ?? '',
      name: data['name'] as String? ?? '',
      path: data['path'] as String? ?? '',
      icon: data['icon'] as String? ?? '',
      category: data['category'] as String? ?? 'all',
      description: data['description'] as String? ?? '',
      useCount: data['useCount'] as int? ?? data['use_count'] as int? ?? 0,
      lastUsed: data['lastUsed'] as String? ?? data['last_used'] as String? ?? '',
      createdAt: data['createdAt'] as String? ?? data['created_at'] as String? ?? '',
      version: data['version'] as String? ?? '',
      sourceDir: data['sourceDir'] as String? ?? data['source_dir'] as String? ?? '',
      enabled: data['enabled'] as bool? ?? true,
      isToolLibrary: data['isToolLibrary'] as bool? ?? data['is_tool_library'] as bool? ?? false,
    );
  }

  /// 转换为 JSON Map
  Map<String, dynamic> toDict() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'icon': icon,
      'category': category,
      'description': description,
      'useCount': useCount,
      'lastUsed': lastUsed,
      'createdAt': createdAt,
      'version': version,
      'sourceDir': sourceDir,
      'enabled': enabled,
      'isToolLibrary': isToolLibrary,
    };
  }

  /// 复制并修改部分字段
  ProgramInfo copyWith({
    String? id,
    String? name,
    String? path,
    String? icon,
    String? category,
    String? description,
    int? useCount,
    String? lastUsed,
    String? createdAt,
    String? version,
    String? sourceDir,
    bool? enabled,
    bool? isToolLibrary,
  }) {
    return ProgramInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      icon: icon ?? this.icon,
      category: category ?? this.category,
      description: description ?? this.description,
      useCount: useCount ?? this.useCount,
      lastUsed: lastUsed ?? this.lastUsed,
      createdAt: createdAt ?? this.createdAt,
      version: version ?? this.version,
      sourceDir: sourceDir ?? this.sourceDir,
      enabled: enabled ?? this.enabled,
      isToolLibrary: isToolLibrary ?? this.isToolLibrary,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        path,
        icon,
        category,
        description,
        useCount,
        lastUsed,
        createdAt,
        version,
        sourceDir,
        enabled,
        isToolLibrary,
      ];
}
