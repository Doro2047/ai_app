library;

import 'package:flutter/material.dart';

import '../models/bookmark.dart';
import '../models/link_validation_result.dart';

class BookmarkTreeItem extends StatelessWidget {
  final Bookmark bookmark;
  final Map<String, LinkValidationResult> validationResults;
  final bool isExpanded;
  final int depth;
  final VoidCallback? onTap;
  final VoidCallback? onToggleExpand;
  final ValueChanged<String>? onOpenUrl;
  final ValueChanged<Bookmark>? onEdit;
  final ValueChanged<String>? onDelete;
  final ValueChanged<Bookmark>? onMove;

  const BookmarkTreeItem({
    super.key,
    required this.bookmark,
    this.validationResults = const {},
    this.isExpanded = false,
    this.depth = 0,
    this.onTap,
    this.onToggleExpand,
    this.onOpenUrl,
    this.onEdit,
    this.onDelete,
    this.onMove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRow(context),
        if (bookmark.isFolder && isExpanded && bookmark.children != null)
          ...bookmark.children!.map(
            (child) => Padding(
              padding: EdgeInsets.only(left: depth < 3 ? 24 : 0),
              child: BookmarkTreeItem(
                bookmark: child,
                validationResults: validationResults,
                depth: depth + 1,
                onTap: onTap,
                onToggleExpand: onToggleExpand,
                onOpenUrl: onOpenUrl,
                onEdit: onEdit,
                onDelete: onDelete,
                onMove: onMove,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRow(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      onSecondaryTapDown: (details) => _showContextMenu(context, details),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: theme.dividerColor.withValues(alpha: 0.3),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            SizedBox(width: depth * 16),
            if (bookmark.isFolder)
              InkWell(
                onTap: onToggleExpand,
                child: Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_right,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            else
              const SizedBox(width: 20),
            Icon(
              bookmark.isFolder ? Icons.folder : Icons.link,
              size: 18,
              color: bookmark.isFolder
                  ? Colors.amber.shade700
                  : _getLinkColor(context),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bookmark.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight:
                          bookmark.isFolder ? FontWeight.w600 : null,
                      color: bookmark.isFolder
                          ? null
                          : _getLinkColor(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (!bookmark.isFolder && bookmark.url.isNotEmpty)
                    Text(
                      bookmark.url,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            if (!bookmark.isFolder && _isInvalidLink())
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _getErrorShort(),
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getLinkColor(BuildContext context) {
    final theme = Theme.of(context);
    if (_isInvalidLink()) {
      return Colors.red.shade600;
    }
    if (_isValidLink()) {
      return Colors.green.shade700;
    }
    return theme.colorScheme.primary;
  }

  bool _isInvalidLink() {
    final result = validationResults[bookmark.url];
    return result != null && !result.isValid;
  }

  bool _isValidLink() {
    final result = validationResults[bookmark.url];
    return result != null && result.isValid;
  }

  String _getErrorShort() {
    final result = validationResults[bookmark.url];
    if (result == null) return '';
    final code = result.statusCode;
    if (code != null) return '$code';
    return 'Invalid';
  }

  void _showContextMenu(BuildContext context, TapDownDetails details) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        details.globalPosition.dx,
        details.globalPosition.dy,
        details.globalPosition.dx,
        details.globalPosition.dy,
      ),
      items: [
        if (!bookmark.isFolder && bookmark.url.isNotEmpty)
          const PopupMenuItem(
            value: 'open',
            child: Row(
              children: [
                Icon(Icons.open_in_new, size: 18),
                SizedBox(width: 8),
                Text('Open'),
              ],
            ),
          ),
        if (onEdit != null)
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit, size: 18),
                SizedBox(width: 8),
                Text('Edit'),
              ],
            ),
          ),
        if (onMove != null)
          const PopupMenuItem(
            value: 'move',
            child: Row(
              children: [
                Icon(Icons.drive_file_move_outline, size: 18),
                SizedBox(width: 8),
                Text('Move to...'),
              ],
            ),
          ),
        if (onDelete != null)
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, size: 18, color: Colors.red),
                SizedBox(width: 8),
                Text('Delete', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
      ],
    ).then((value) {
      switch (value) {
        case 'open':
          if (bookmark.url.isNotEmpty) {
            onOpenUrl?.call(bookmark.url);
          }
          break;
        case 'edit':
          onEdit?.call(bookmark);
          break;
        case 'move':
          onMove?.call(bookmark);
          break;
        case 'delete':
          onDelete?.call(bookmark.id);
          break;
      }
    });
  }
}

class BookmarkTreeView extends StatefulWidget {
  final List<Bookmark> bookmarks;
  final Map<String, LinkValidationResult> validationResults;
  final ValueChanged<Bookmark>? onNodeTap;
  final ValueChanged<String>? onOpenUrl;
  final ValueChanged<Bookmark>? onEdit;
  final ValueChanged<String>? onDelete;
  final ValueChanged<Bookmark>? onMove;

  const BookmarkTreeView({
    super.key,
    required this.bookmarks,
    this.validationResults = const {},
    this.onNodeTap,
    this.onOpenUrl,
    this.onEdit,
    this.onDelete,
    this.onMove,
  });

  @override
  State<BookmarkTreeView> createState() => _BookmarkTreeViewState();
}

class _BookmarkTreeViewState extends State<BookmarkTreeView> {
  final Set<String> _expandedIds = {};

  void _toggleExpand(String id) {
    setState(() {
      if (_expandedIds.contains(id)) {
        _expandedIds.remove(id);
      } else {
        _expandedIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.bookmarks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border,
              size: 64,
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant
                  .withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No Bookmarks',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withValues(alpha: 0.7),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Import a browser bookmark file to start managing',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withValues(alpha: 0.5),
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: widget.bookmarks.length,
      itemBuilder: (context, index) {
        final bookmark = widget.bookmarks[index];
        return BookmarkTreeItem(
          bookmark: bookmark,
          validationResults: widget.validationResults,
          isExpanded: _expandedIds.contains(bookmark.id),
          onTap: () => widget.onNodeTap?.call(bookmark),
          onToggleExpand: () => _toggleExpand(bookmark.id),
          onOpenUrl: widget.onOpenUrl,
          onEdit: widget.onEdit,
          onDelete: widget.onDelete,
          onMove: widget.onMove,
        );
      },
    );
  }
}
