/// 文件移动预览模型
///
/// 表示单个文件的移动预览结果。
library;

import 'package:path/path.dart' as p;

/// 文件移动状态
enum MoveStatus {
  /// 待处理
  pending,

  /// 成功
  success,

  /// 失败
  failed;

  String get displayName {
    switch (this) {
      case MoveStatus.pending:
        return '待处理';
      case MoveStatus.success:
        return '成功';
      case MoveStatus.failed:
        return '失败';
    }
  }
}

/// 文件移动预览
class MovePreview {
  /// 原始文件路径
  final String originalPath;

  /// 原始文件名
  final String originalName;

  /// 目标文件路径
  final String targetPath;

  /// 操作状态
  final MoveStatus status;

  /// 错误信息
  final String? error;

  const MovePreview({
    required this.originalPath,
    required this.originalName,
    required this.targetPath,
    this.status = MoveStatus.pending,
    this.error,
  });

  /// 是否有变化（源和目标不同）
  bool get hasChange => originalPath != targetPath;

  /// 目标目录
  String get targetDirectory => p.dirname(targetPath);

  /// 复制并修改字段
  MovePreview copyWith({
    String? originalPath,
    String? originalName,
    String? targetPath,
    MoveStatus? status,
    String? error,
  }) {
    return MovePreview(
      originalPath: originalPath ?? this.originalPath,
      originalName: originalName ?? this.originalName,
      targetPath: targetPath ?? this.targetPath,
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }

  /// 序列化为 Map
  Map<String, dynamic> toDict() {
    return {
      'originalPath': originalPath,
      'originalName': originalName,
      'targetPath': targetPath,
      'status': status.name,
      'error': error,
    };
  }

  /// 从 Map 反序列化
  static MovePreview fromDict(Map<String, dynamic> data) {
    return MovePreview(
      originalPath: data['originalPath'] as String? ?? '',
      originalName: data['originalName'] as String? ?? '',
      targetPath: data['targetPath'] as String? ?? '',
      status: _parseStatus(data['status'] as String? ?? 'pending'),
      error: data['error'] as String?,
    );
  }

  static MoveStatus _parseStatus(String value) {
    return MoveStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MoveStatus.pending,
    );
  }

  @override
  String toString() {
    return 'MovePreview($originalName -> $targetPath, status: $status)';
  }
}
