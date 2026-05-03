/// 文件移动规则模型
///
/// 表示单个文件移动规则，包含匹配类型、匹配模式、目标目录等配置。
library;

/// 匹配类型
enum MatchType {
  /// 按扩展名匹配
  extension,

  /// 按文件名匹配
  name,

  /// 按包含文本匹配
  contains,

  /// 按正则表达式匹配
  regex;

  String get displayName {
    switch (this) {
      case MatchType.extension:
        return '扩展名';
      case MatchType.name:
        return '文件名';
      case MatchType.contains:
        return '包含文本';
      case MatchType.regex:
        return '正则表达式';
    }
  }
}

/// 冲突处理方式
enum ConflictAction {
  /// 跳过
  skip,

  /// 覆盖
  overwrite,

  /// 重命名
  rename;

  String get displayName {
    switch (this) {
      case ConflictAction.skip:
        return '跳过';
      case ConflictAction.overwrite:
        return '覆盖';
      case ConflictAction.rename:
        return '重命名';
    }
  }
}

/// 文件移动规则
class MoveRule {
  /// 匹配类型
  final MatchType matchType;

  /// 匹配模式
  final String matchPattern;

  /// 目标目录
  final String targetDirectory;

  /// 是否创建子目录
  final bool createSubdirs;

  /// 子目录模式（如 "{date}", "{extension}" 等）
  final String subDirPattern;

  /// 冲突处理方式
  final ConflictAction conflictAction;

  const MoveRule({
    required this.matchType,
    required this.matchPattern,
    required this.targetDirectory,
    this.createSubdirs = false,
    this.subDirPattern = '',
    this.conflictAction = ConflictAction.rename,
  });

  /// 序列化为 Map
  Map<String, dynamic> toDict() {
    return {
      'matchType': matchType.name,
      'matchPattern': matchPattern,
      'targetDirectory': targetDirectory,
      'createSubdirs': createSubdirs,
      'subDirPattern': subDirPattern,
      'conflictAction': conflictAction.name,
    };
  }

  /// 从 Map 反序列化
  static MoveRule fromDict(Map<String, dynamic> data) {
    return MoveRule(
      matchType: _parseMatchType(data['matchType'] as String? ?? 'extension'),
      matchPattern: data['matchPattern'] as String? ?? '',
      targetDirectory: data['targetDirectory'] as String? ?? '',
      createSubdirs: data['createSubdirs'] as bool? ?? false,
      subDirPattern: data['subDirPattern'] as String? ?? '',
      conflictAction: _parseConflictAction(data['conflictAction'] as String? ?? 'rename'),
    );
  }

  static MatchType _parseMatchType(String value) {
    return MatchType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MatchType.extension,
    );
  }

  static ConflictAction _parseConflictAction(String value) {
    return ConflictAction.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ConflictAction.rename,
    );
  }

  /// 复制并修改字段
  MoveRule copyWith({
    MatchType? matchType,
    String? matchPattern,
    String? targetDirectory,
    bool? createSubdirs,
    String? subDirPattern,
    ConflictAction? conflictAction,
  }) {
    return MoveRule(
      matchType: matchType ?? this.matchType,
      matchPattern: matchPattern ?? this.matchPattern,
      targetDirectory: targetDirectory ?? this.targetDirectory,
      createSubdirs: createSubdirs ?? this.createSubdirs,
      subDirPattern: subDirPattern ?? this.subDirPattern,
      conflictAction: conflictAction ?? this.conflictAction,
    );
  }

  @override
  String toString() {
    return 'MoveRule($matchType: "$matchPattern" -> $targetDirectory, conflict: $conflictAction)';
  }
}
