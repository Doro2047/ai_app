/// Duplicate file group tile component
///
/// Displays detailed information and file selection controls for a duplicate file group.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/file_dedup_bloc.dart';
import '../models/models.dart';

/// Format file size helper
String _formatSize(int sizeBytes) {
  if (sizeBytes == 0) return '0 B';
  if (sizeBytes < 1024) return '$sizeBytes B';
  if (sizeBytes < 1024 * 1024) return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
  if (sizeBytes < 1024 * 1024 * 1024) {
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  return '${(sizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
}

/// Duplicate file group card
class DuplicateGroupTile extends StatelessWidget {
  final DuplicateGroup group;

  const DuplicateGroupTile({
    super.key,
    required this.group,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      child: ExpansionTile(
        initiallyExpanded: false,
        leading: Icon(
          Icons.copy_all,
          color: colorScheme.primary,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                'Hash: ${group.hash.substring(0, group.hash.length > 12 ? 12 : group.hash.length)}...',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${group.fileCount} files',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
        subtitle: Text(
          'Size: ${_formatSize(group.size)} | Freeable: ${_formatSize(group.spaceSavings)}',
          style: theme.textTheme.bodySmall,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (group.selectedCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Selected ${group.selectedCount}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onErrorContainer,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(
                group.selectedCount > 0 ? Icons.deselect : Icons.select_all,
                size: 20,
              ),
              tooltip: group.selectedCount > 0 ? 'Deselect All' : 'Select All',
              onPressed: () {
                if (group.selectedCount > 0) {
                  context.read<FileDedupBloc>().add(FileDedupDeselectAll(group.hash));
                } else {
                  context.read<FileDedupBloc>().add(FileDedupSelectAll(group.hash));
                }
              },
            ),
          ],
        ),
        children: [
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                for (int i = 0; i < group.files.length; i++)
                  _FileItemWidget(
                    file: group.files[i],
                    group: group,
                    isOriginal: i == 0,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Single file item component
class _FileItemWidget extends StatelessWidget {
  final FileHashResult file;
  final DuplicateGroup group;
  final bool isOriginal;

  const _FileItemWidget({
    required this.file,
    required this.group,
    required this.isOriginal,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = group.isFileSelected(file.path);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isOriginal
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
            : isSelected
                ? colorScheme.errorContainer.withValues(alpha: 0.3)
                : null,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isOriginal
              ? colorScheme.outlineVariant.withValues(alpha: 0.3)
              : isSelected
                  ? colorScheme.error.withValues(alpha: 0.3)
                  : Colors.transparent,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Checkbox
          Checkbox(
            value: isSelected,
            onChanged: isOriginal
                ? null
                : (value) {
                    context.read<FileDedupBloc>().add(
                          FileDedupFileSelected(
                            group.hash,
                            file.path,
                            value ?? false,
                          ),
                        );
                  },
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(width: 8),
          // File info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (isOriginal)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Keep',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        file.name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: isOriginal ? FontWeight.w600 : FontWeight.normal,
                          decoration: !isOriginal && isSelected
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  file.path,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      file.sizeFormatted,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                      ),
                    ),
                    Text(
                      ' \u2022 ',
                      style: theme.textTheme.bodySmall,
                    ),
                    Text(
                      file.modifiedFormatted,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
