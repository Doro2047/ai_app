library;

import 'package:path/path.dart' as p;

enum MoveStatus {
  pending,
  success,
  failed;

  String get displayName {
    switch (this) {
      case MoveStatus.pending:
        return 'Pending';
      case MoveStatus.success:
        return 'Success';
      case MoveStatus.failed:
        return 'Failed';
    }
  }
}

class MovePreview {
  final String originalPath;
  final String originalName;
  final String targetPath;
  final MoveStatus status;
  final String? error;

  const MovePreview({
    required this.originalPath,
    required this.originalName,
    required this.targetPath,
    this.status = MoveStatus.pending,
    this.error,
  });

  bool get hasChange => originalPath != targetPath;

  String get targetDirectory => p.dirname(targetPath);

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

  Map<String, dynamic> toDict() {
    return {
      'originalPath': originalPath,
      'originalName': originalName,
      'targetPath': targetPath,
      'status': status.name,
      'error': error,
    };
  }

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
