library;

import 'package:path/path.dart' as p;

enum ExtensionChangeStatus {
  pending,
  success,
  failed;

  String get displayName {
    switch (this) {
      case ExtensionChangeStatus.pending:
        return 'Pending';
      case ExtensionChangeStatus.success:
        return 'Success';
      case ExtensionChangeStatus.failed:
        return 'Failed';
    }
  }
}

class FilePreview {
  final String originalPath;
  final String originalName;
  final String newName;
  final ExtensionChangeStatus status;
  final String? error;

  const FilePreview({
    required this.originalPath,
    required this.originalName,
    required this.newName,
    this.status = ExtensionChangeStatus.pending,
    this.error,
  });

  String get newPath {
    final dir = p.dirname(originalPath);
    return p.join(dir, newName);
  }

  bool get hasChange => originalName != newName;

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

  Map<String, dynamic> toDict() {
    return {
      'originalPath': originalPath,
      'originalName': originalName,
      'newName': newName,
      'status': status.name,
      'error': error,
    };
  }

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
