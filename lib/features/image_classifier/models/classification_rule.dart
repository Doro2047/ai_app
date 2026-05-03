enum RuleType { extension, size, namePattern }

class ClassificationRule {
  final String name;
  final RuleType type;
  final String pattern;
  final String targetFolder;
  final bool enabled;

  const ClassificationRule({
    required this.name,
    required this.type,
    required this.pattern,
    required this.targetFolder,
    this.enabled = true,
  });

  ClassificationRule copyWith({
    String? name,
    RuleType? type,
    String? pattern,
    String? targetFolder,
    bool? enabled,
  }) {
    return ClassificationRule(
      name: name ?? this.name,
      type: type ?? this.type,
      pattern: pattern ?? this.pattern,
      targetFolder: targetFolder ?? this.targetFolder,
      enabled: enabled ?? this.enabled,
    );
  }

  static List<ClassificationRule> get defaults => [
        const ClassificationRule(
          name: 'JPEG 图片',
          type: RuleType.extension,
          pattern: '.jpg,.jpeg',
          targetFolder: 'JPEG',
        ),
        const ClassificationRule(
          name: 'PNG 图片',
          type: RuleType.extension,
          pattern: '.png',
          targetFolder: 'PNG',
        ),
        const ClassificationRule(
          name: 'GIF 图片',
          type: RuleType.extension,
          pattern: '.gif',
          targetFolder: 'GIF',
        ),
        const ClassificationRule(
          name: '大文件 (>5MB)',
          type: RuleType.size,
          pattern: '>5242880',
          targetFolder: '大文件',
        ),
        const ClassificationRule(
          name: '截图',
          type: RuleType.namePattern,
          pattern: 'screenshot|截图|screen',
          targetFolder: '截图',
        ),
      ];
}
