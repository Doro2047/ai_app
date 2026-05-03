/// 自定义信息数据模型
///
/// 对应 Python CustomInfo，用户可自定义的文本信息条目。
library;

import 'package:equatable/equatable.dart';

/// 自定义信息模型
class CustomInfo extends Equatable {
  /// 唯一标识
  final String id;

  /// 标题
  final String title;

  /// 内容
  final String content;

  /// 创建时间
  final String createdAt;

  /// 更新时间
  final String updatedAt;

  const CustomInfo({
    required this.id,
    required this.title,
    required this.content,
    this.createdAt = '',
    this.updatedAt = '',
  });

  /// 从 JSON Map 创建
  factory CustomInfo.fromDict(Map<String, dynamic> data) {
    return CustomInfo(
      id: data['id'] as String? ?? '',
      title: data['title'] as String? ?? '',
      content: data['content'] as String? ?? '',
      createdAt: data['createdAt'] as String? ?? data['created_at'] as String? ?? '',
      updatedAt: data['updatedAt'] as String? ?? data['updated_at'] as String? ?? '',
    );
  }

  /// 转换为 JSON Map
  Map<String, dynamic> toDict() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// 复制并修改部分字段
  CustomInfo copyWith({
    String? id,
    String? title,
    String? content,
    String? createdAt,
    String? updatedAt,
  }) {
    return CustomInfo(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, title, content, createdAt, updatedAt];
}
