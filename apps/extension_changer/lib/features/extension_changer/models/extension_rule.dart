library;

class ExtensionRule {
  final String originalExtension;
  final String newExtension;
  final bool recursive;

  const ExtensionRule({
    required this.originalExtension,
    required this.newExtension,
    this.recursive = true,
  });

  Map<String, dynamic> toDict() {
    return {
      'originalExtension': originalExtension,
      'newExtension': newExtension,
      'recursive': recursive,
    };
  }

  static ExtensionRule fromDict(Map<String, dynamic> data) {
    return ExtensionRule(
      originalExtension: data['originalExtension'] as String? ?? '',
      newExtension: data['newExtension'] as String? ?? '',
      recursive: data['recursive'] as bool? ?? true,
    );
  }

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
    return 'ExtensionRule(${originalExtension.isNotEmpty ? originalExtension : "(none)"} -> $newExtension, recursive: $recursive)';
  }
}
