library;

import 'package:flutter/material.dart';

class AndroidUnavailableNotice extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool showAsCard;

  const AndroidUnavailableNotice({
    super.key,
    this.title = '\u5E73\u53F0\u529F\u80FD\u9650\u5236',
    this.description = '\u6B64\u529F\u80FD\u5728 Android \u5E73\u53F0\u4E0A\u4E0D\u53EF\u7528\uFF0C\u9700\u8981 root \u6743\u9650\u6216\u4F7F\u7528 Platform Channel \u5B9E\u73B0\u3002',
    this.icon = Icons.warning_amber_rounded,
    this.showAsCard = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: colorScheme.tertiary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colorScheme.tertiary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );

    if (showAsCard) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.tertiary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: content,
      );
    }

    return content;
  }
}
