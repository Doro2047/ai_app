/// 扩展名修改规则模型
///
/// 表示单个扩展名修改规则，包含原始扩展名、新扩展名和递归选项。
library;

/// 扩展名修改规则
class ExtensionRule {
  /// 原始扩展名（如 ".txt"）
  final String originalExtension;

  /// 新扩展名（如 ".md"）
  final String newExtension;

  /// 是否递归应用到子目录
  final bool recursive;

  const ExtensionRule({
    required this.originalExtension,
    required this.newExtension,
    this.recursive = true,
  });

  /// 序列化为 Map
  Map<String, dynamic> toDict() {
    return {
      'originalExtension': originalExtension,
      'newExtension': newExtension,
      'recursive': recursive,
    };
  }

  /// 从 Map 反序列化
  static ExtensionRule fromDict(Map<String, dynamic> data) {
    return ExtensionRule(
      originalExtension: data['originalExtension'] as String? ?? '',
      newExtension: data['newExtension'] as String? ?? '',
      recursive: data['recursive'] as bool? ?? true,
    );
  }

  /// 复制并修改字段
  ExtensionRule copyWith({
    String? originalExtension,
    String? newExtension,
    bool? recursive,
  }) {
    return ExtensionRule(
      originalExtension: originalExtension ?? this.originalExtension,
      newExtension: newExtension ?? this.newExtension,
      recursive: recursive ?? this.recursive,
    );
  }

  @override
  String toString() {
    return 'ExtensionRule(${originalExtension.isNotEmpty ? originalExtension : "(无扩展名)"} -> $newExtension, recursive: $recursive)';
  }
}
