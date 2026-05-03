library;

import 'package:flutter/material.dart';

enum RenameRuleType {
  prefix,
  suffix,
  replace,
  sequence,
  extension,
  regex;

  String get displayName {
    switch (this) {
      case RenameRuleType.prefix:
        return 'Prefix';
      case RenameRuleType.suffix:
        return 'Suffix';
      case RenameRuleType.replace:
        return 'Find & Replace';
      case RenameRuleType.sequence:
        return 'Sequence';
      case RenameRuleType.extension:
        return 'Extension';
      case RenameRuleType.regex:
        return 'Regex Replace';
    }
  }

  IconData get icon {
    switch (this) {
      case RenameRuleType.prefix:
        return Icons.arrow_right_alt;
      case RenameRuleType.suffix:
        return Icons.arrow_left;
      case RenameRuleType.replace:
        return Icons.find_replace;
      case RenameRuleType.sequence:
        return Icons.format_list_numbered;
      case RenameRuleType.extension:
        return Icons.edit_note;
      case RenameRuleType.regex:
        return Icons.code;
    }
  }
}

class RenameRule {
  final String id;
  final RenameRuleType type;
  final String pattern;
  final String replacement;
  final bool enabled;
  final int? startIndex;

  const RenameRule({
    required this.id,
    required this.type,
    required this.pattern,
    this.replacement = '',
    this.enabled = true,
    this.startIndex,
  });

  RenameRule copyWith({
    String? id,
    RenameRuleType? type,
    String? pattern,
    String? replacement,
    bool? enabled,
    int? startIndex,
  }) {
    return RenameRule(
      id: id ?? this.id,
      type: type ?? this.type,
      pattern: pattern ?? this.pattern,
      replacement: replacement ?? this.replacement,
      enabled: enabled ?? this.enabled,
      startIndex: startIndex ?? this.startIndex,
    );
  }

  String apply(String filename, int index) {
    final ext = filename.contains('.')
        ? '.${filename.split('.').last}'
        : '';
    final nameWithoutExt = ext.isNotEmpty
        ? filename.substring(0, filename.length - ext.length)
        : filename;

    switch (type) {
      case RenameRuleType.prefix:
        return '$pattern$nameWithoutExt$ext';

      case RenameRuleType.suffix:
        return '$nameWithoutExt$pattern$ext';

      case RenameRuleType.replace:
        if (pattern.isEmpty) return filename;
        return filename.replaceAll(pattern, replacement);

      case RenameRuleType.sequence:
        final start = startIndex ?? 1;
        final seq = (start + index).toString().padLeft(3, '0');
        if (replacement.isNotEmpty) {
          return '$replacement$seq$ext';
        }
        return '$nameWithoutExt$seq$ext';

      case RenameRuleType.extension:
        var newExt = replacement;
        if (newExt.isNotEmpty && !newExt.startsWith('.')) {
          newExt = '.$newExt';
        }
        return '$nameWithoutExt$newExt';

      case RenameRuleType.regex:
        if (pattern.isEmpty) return filename;
        try {
          final regex = RegExp(pattern);
          return filename.replaceAll(regex, replacement);
        } catch (_) {
          return filename;
        }
    }
  }

  Map<String, dynamic> toDict() {
    return {
      'id': id,
      'type': type.name,
      'pattern': pattern,
      'replacement': replacement,
      'enabled': enabled,
      'startIndex': startIndex,
    };
  }

  static RenameRule fromDict(Map<String, dynamic> data) {
    return RenameRule(
      id: data['id'] as String? ?? '',
      type: RenameRuleType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => RenameRuleType.replace,
      ),
      pattern: data['pattern'] as String? ?? '',
      replacement: data['replacement'] as String? ?? '',
      enabled: data['enabled'] as bool? ?? true,
      startIndex: data['startIndex'] as int?,
    );
  }
}
