/// 扩展名修改预览模型
///
/// 表示单个文件的扩展名修改预览结果。
library;

import 'package:path/path.dart' as p;

/// 扩展名修改状态
enum ExtensionChangeStatus {
  /// 待处理
  pending,

  /// 成功
  success,

  /// 失败
  failed;

  String get displayName {
    switch (this) {
      case ExtensionChangeStatus.pending:
        return '待处理';
      case ExtensionChangeStatus.success:
        return '成功';
      case ExtensionChangeStatus.failed:
        return '失败';
    }
  }
}

/// 扩展名修改预览
class FilePreview {
  /// 原始文件路径
  final String originalPath;

  /// 原始文件名
  final String originalName;

  /// 新文件名
  final String newName;

  /// 操作状态
  final ExtensionChangeStatus status;

  /// 错误信息
  final String? error;

  const FilePreview({
    required this.originalPath,
    required this.originalName,
    required this.newName,
    this.status = ExtensionChangeStatus.pending,
    this.error,
  });

  /// 新文件完整路径
  String get newPath {
    final dir = p.dirname(originalPath);
    return p.join(dir, newName);
  }

  /// 是否有变化
  bool get hasChange => originalName != newName;

  /// 复制并修改字段
  FilePreview copyWith({
    String? originalPath,
    String? originalName,
    String? newName,
    ExtensionChangeStatus? status,
    String? error,
  }) {
    return FilePreview(
      originalPath: originalPath ?? this.originalPath,
      originalName: originalName ?? this.originalName,
      newName: newName ?? this.newName,
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }

  /// 序列化为 Map
  Map<String, dynamic> toDict() {
    return {
      'originalPath': originalPath,
      'originalName': originalName,
      'newName': newName,
      'status': status.name,
      'error': error,
    };
  }

  /// 从 Map 反序列化
  static FilePreview fromDict(Map<String, dynamic> data) {
    return FilePreview(
      originalPath: data['originalPath'] as String? ?? '',
      originalName: data['originalName'] as String? ?? '',
      newName: data['newName'] as String? ?? '',
      status: _parseStatus(data['status'] as String? ?? 'pending'),
      error: data['error'] as String?,
    );
  }

  static ExtensionChangeStatus _parseStatus(String value) {
    return ExtensionChangeStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ExtensionChangeStatus.pending,
    );
  }

  @override
  String toString() {
    return 'FilePreview($originalName -> $newName, status: $status)';
  }
}
