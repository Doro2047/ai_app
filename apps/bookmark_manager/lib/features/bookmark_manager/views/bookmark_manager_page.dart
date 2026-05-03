import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_core/shared_core.dart';

import '../../../injection.dart';
import '../bloc/bookmark_bloc.dart';
import '../models/bookmark_node.dart';

class BookmarkManagerPage extends StatelessWidget {
  const BookmarkManagerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<BookmarkBloc>(),
      child: const _BookmarkManagerView(),
    );
  }
}

class _BookmarkManagerView extends StatefulWidget {
  const _BookmarkManagerView();

  @override
  State<_BookmarkManagerView> createState() => _BookmarkManagerViewState();
}

class _BookmarkManagerViewState extends State<_BookmarkManagerView> {
  final _searchController = TextEditingController();
  String _selectedFilePath = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<BookmarkBloc, BookmarkState>(
      listener: (context, state) {
        if (state.hasError) {
          AppToast.show(context, message: state.error!, type: AppToastType.error);
        }
      },
      builder: (context, state) {
        return AppScaffold(
          title: 'Bookmark Manager',
          statusBarText: state.isLoading
              ? 'Loading bookmarks...'
              : state.hasBookmarks
                  ? '${state.totalUrls} links, ${state.totalFolders} folders'
                  : 'Ready',
          showStatusBarProgress: state.isLoading,
          statusBarProgress: 0.0,
          body: Column(
            children: [
              _buildFileSection(context, state),
              _buildFilterSection(context, state),
              Divider(height: 1, color: theme.dividerColor),
              Expanded(
                child: state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : !state.hasBookmarks
                        ? const EmptyState(
                            icon: Icons.bookmark_border,
                            title: 'No Bookmarks',
                            description: 'Import a browser bookmark file to start managing',
                          )
                        : _buildBookmarkTree(context, state),
              ),
              if (state.hasBookmarks) _buildStatsBar(context, state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFileSection(BuildContext context, BookmarkState state) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          FilledButton.icon(
            onPressed: _selectFile,
            icon: const Icon(Icons.folder_open, size: 18),
            label: const Text('Select File'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _selectedFilePath.isEmpty
                    ? 'Select a Chrome/Edge bookmark file'
                    : _selectedFilePath,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _selectedFilePath.isEmpty
                          ? Theme.of(context).colorScheme.outline
                          : null,
                    ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          FilledButton.icon(
            onPressed: _selectedFilePath.isNotEmpty ? _loadBookmarks : null,
            icon: const Icon(Icons.download, size: 18),
            label: const Text('Load'),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.save_alt),
            onPressed: state.hasBookmarks ? _exportBookmarks : null,
            tooltip: 'Export Bookmarks',
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context, BookmarkState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search bookmarks...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          context
                              .read<BookmarkBloc>()
                              .add(const BookmarkSearchChanged(''));
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                isDense: true,
              ),
              onChanged: (value) {
                context.read<BookmarkBloc>().add(BookmarkSearchChanged(value));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarkTree(BuildContext context, BookmarkState state) {
    final bookmarks =
        state.filteredBookmarks.isNotEmpty ? state.filteredBookmarks : state.bookmarks;

    if (bookmarks.isEmpty) {
      return Center(
        child: Text(
          'No matching bookmarks found',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: bookmarks.length,
      itemBuilder: (context, index) {
        return _BookmarkNodeWidget(
          node: bookmarks[index],
          depth: 0,
          expandedFolders: state.expandedFolders,
          onToggleExpand: (id) {
            context.read<BookmarkBloc>().add(BookmarkExpanded(id));
          },
          onEdit: (id, name, url) {
            context.read<BookmarkBloc>().add(BookmarkEditRequested(id, name, url));
          },
          onDelete: (id) {
            context.read<BookmarkBloc>().add(BookmarkDeleteRequested(id));
          },
        );
      },
    );
  }

  Widget _buildStatsBar(BuildContext context, BookmarkState state) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStatChip(theme, Icons.bookmark, '${state.totalUrls}', Colors.blue),
          const SizedBox(width: 16),
          _buildStatChip(theme, Icons.folder, '${state.totalFolders}', Colors.amber),
        ],
      ),
    );
  }

  Widget _buildStatChip(ThemeData theme, IconData icon, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Future<void> _selectFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json', 'html', 'htm'],
      );
      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFilePath = result.files.single.path!;
        });
      }
    } catch (e) {
      if (!mounted) return;
      AppToast.show(context, message: 'Failed to select file: $e', type: AppToastType.error);
    }
  }

  void _loadBookmarks() {
    if (_selectedFilePath.isEmpty) {
      AppToast.show(context, message: 'Please select a bookmark file first', type: AppToastType.warning);
      return;
    }
    context.read<BookmarkBloc>().add(BookmarksFileSelected(_selectedFilePath));
  }

  Future<void> _exportBookmarks() async {
    try {
      final savePath = await FilePicker.platform.saveFile(
        dialogTitle: 'Export Bookmarks',
        fileName: 'Bookmarks.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (savePath != null) {
        context.read<BookmarkBloc>().add(BookmarkExportRequested(savePath));
        if (mounted) {
          AppToast.show(context, message: 'Bookmarks exported', type: AppToastType.success);
        }
      }
    } catch (e) {
      if (!mounted) return;
      AppToast.show(context, message: 'Export failed: $e', type: AppToastType.error);
    }
  }
}

class _BookmarkNodeWidget extends StatelessWidget {
  final BookmarkNode node;
  final int depth;
  final Set<String> expandedFolders;
  final ValueChanged<String> onToggleExpand;
  final void Function(String id, String name, String? url) onEdit;
  final ValueChanged<String> onDelete;

  const _BookmarkNodeWidget({
    required this.node,
    required this.depth,
    required this.expandedFolders,
    required this.onToggleExpand,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isExpanded = expandedFolders.contains(node.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRow(context, isExpanded),
        if (node.isFolder && isExpanded)
          ...node.children.map(
            (child) => _BookmarkNodeWidget(
              node: child,
              depth: depth + 1,
              expandedFolders: expandedFolders,
              onToggleExpand: onToggleExpand,
              onEdit: onEdit,
              onDelete: onDelete,
            ),
          ),
      ],
    );
  }

  Widget _buildRow(BuildContext context, bool isExpanded) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: node.isFolder ? () => onToggleExpand(node.id) : null,
      onSecondaryTapDown: (details) => _showContextMenu(context, details),
      onLongPress: () => _showBottomMenu(context),
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
            if (node.isFolder)
              InkWell(
                onTap: () => onToggleExpand(node.id),
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
              node.isFolder ? Icons.folder : Icons.link,
              size: 18,
              color: node.isFolder ? Colors.amber.shade700 : theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    node.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: node.isFolder ? FontWeight.w600 : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (node.isUrl && node.url != null && node.url!.isNotEmpty)
                    Text(
                      node.url!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            if (node.isFolder)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  '${node.children.length}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
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
      if (value == 'edit') {
        _showEditDialog(context);
      } else if (value == 'delete') {
        onDelete(node.id);
      }
    });
  }

  void _showBottomMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(sheetContext);
                _showEditDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(sheetContext);
                onDelete(node.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final nameController = TextEditingController(text: node.name);
    final urlController = TextEditingController(text: node.url ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Bookmark'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            if (node.isUrl)
              TextField(
                controller: urlController,
                decoration: const InputDecoration(
                  labelText: 'URL',
                  border: OutlineInputBorder(),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              onEdit(
                node.id,
                nameController.text,
                node.isUrl ? urlController.text : null,
              );
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
