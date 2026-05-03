/// 重复文件组卡片组件
///
/// 显示重复文件组的详细信息和文件选择控件。
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/file_dedup_bloc.dart';
import '../models/models.dart';
import '../../file_scanner/models/file_scan_result.dart' show formatSize;

/// 重复文件组卡片
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
                '哈希: ${group.hash.substring(0, group.hash.length > 12 ? 12 : group.hash.length)}...',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${group.fileCount} 个文件',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
        subtitle: Text(
          '大小: ${formatSize(group.size)} | 可释放: ${formatSize(group.spaceSavings)}',
          style: theme.textTheme.bodySmall,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (group.selectedCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '已选 ${group.selectedCount}',
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
              tooltip: group.selectedCount > 0 ? '取消全选' : '全选',
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

/// 单个文件项组件
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
            ? colorScheme.surfaceContainerHighest.withOpacity(0.5)
            : isSelected
                ? colorScheme.errorContainer.withOpacity(0.3)
                : null,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isOriginal
              ? colorScheme.outlineVariant.withOpacity(0.3)
              : isSelected
                  ? colorScheme.error.withOpacity(0.3)
                  : Colors.transparent,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 复选框
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
          // 文件信息
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
                          color: colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '保留',
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
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
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
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                    ),
                    Text(
                      ' • ',
                      style: theme.textTheme.bodySmall,
                    ),
                    Text(
                      file.modifiedFormatted,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
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
