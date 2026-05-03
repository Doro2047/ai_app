/// 分类数据模型
///
/// 对应 Python Category，包含程序分类信息。
library;

import 'package:equatable/equatable.dart';

/// 分类模型
class Category extends Equatable {
  /// 唯一标识
  final String id;

  /// 分类名称
  final String name;

  /// 图标名称
  final String icon;

  /// 描述
  final String description;

  const Category({
    required this.id,
    required this.name,
    this.icon = '',
    this.description = '',
  });

  /// 从 JSON Map 创建
  factory Category.fromDict(Map<String, dynamic> data) {
    return Category(
      id: data['id'] as String? ?? '',
      name: data['name'] as String? ?? '',
      icon: data['icon'] as String? ?? '',
      description: data['description'] as String? ?? '',
    );
  }

  /// 转换为 JSON Map
  Map<String, dynamic> toDict() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'description': description,
    };
  }

  @override
  List<Object?> get props => [id, name, icon, description];
}

/// 默认分类列表
class DefaultCategories {
  DefaultCategories._();

  static const List<Map<String, dynamic>> values = [
    {'id': 'all', 'name': '全部', 'icon': 'apps', 'description': '所有程序'},
    {'id': 'file', 'name': '文件管理', 'icon': 'folder', 'description': '文件相关工具'},
    {'id': 'system', 'name': '系统工具', 'icon': 'settings', 'description': '系统管理工具'},
    {'id': 'network', 'name': '网络工具', 'icon': 'wifi', 'description': '网络相关工具'},
    {'id': 'media', 'name': '多媒体', 'icon': 'play_circle', 'description': '媒体处理工具'},
    {'id': 'other', 'name': '其他', 'icon': 'more_horiz', 'description': '其他工具'},
  ];

  /// 获取默认分类列表
  static List<Category> get defaults =>
      values.map((e) => Category.fromDict(e)).toList();
}
