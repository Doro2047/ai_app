library;

enum MatchType {
  extension,
  name,
  contains,
  regex;

  String get displayName {
    switch (this) {
      case MatchType.extension:
        return 'Extension';
      case MatchType.name:
        return 'Name';
      case MatchType.contains:
        return 'Contains';
      case MatchType.regex:
        return 'Regex';
    }
  }
}

enum ConflictAction {
  skip,
  overwrite,
  rename;

  String get displayName {
    switch (this) {
      case ConflictAction.skip:
        return 'Skip';
      case ConflictAction.overwrite:
        return 'Overwrite';
      case ConflictAction.rename:
        return 'Rename';
    }
  }
}

class MoveRule {
  final MatchType matchType;
  final String matchPattern;
  final String targetDirectory;
  final bool createSubdirs;
  final String subDirPattern;
  final ConflictAction conflictAction;

  const MoveRule({
    required this.matchType,
    required this.matchPattern,
    required this.targetDirectory,
    this.createSubdirs = false,
    this.subDirPattern = '',
    this.conflictAction = ConflictAction.rename,
  });

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
