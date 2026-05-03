library;

import 'package:path/path.dart' as p;

class RenamePreview {
  final String originalPath;
  final String newName;
  final bool hasConflict;
  final String? error;

  const RenamePreview({
    required this.originalPath,
    required this.newName,
    this.hasConflict = false,
    this.error,
  });

  String get originalName => p.basename(originalPath);

  String get newPath {
    final dir = p.dirname(originalPath);
    return p.join(dir, newName);
  }

  bool get hasChange => originalName != newName;

  RenamePreview copyWith({
    String? originalPath,
    String? newName,
    bool? hasConflict,
    String? error,
  }) {
    return RenamePreview(
      originalPath: originalPath ?? this.originalPath,
      newName: newName ?? this.newName,
      hasConflict: hasConflict ?? this.hasConflict,
      error: error ?? this.error,
    );
  }

  Map<String, dynamic> toDict() {
    return {
      'originalPath': originalPath,
      'newName': newName,
      'hasConflict': hasConflict,
      'error': error,
    };
  }

  static RenamePreview fromDict(Map<String, dynamic> data) {
    return RenamePreview(
      originalPath: data['originalPath'] as String? ?? '',
      newName: data['newName'] as String? ?? '',
      hasConflict: data['hasConflict'] as bool? ?? false,
      error: data['error'] as String?,
    );
  }
}
