import 'dart:convert';
import 'dart:io';

import 'package:uuid/uuid.dart';

import '../models/bookmark.dart';
import '../models/bookmark_node.dart';

const _uuid = Uuid();

class BookmarkRepository {
  Future<List<BookmarkNode>> parseBookmarksFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw FileSystemException('书签文件不存在', filePath);
    }

    final content = await file.readAsString(encoding: utf8);

    if (content.trim().startsWith('{')) {
      return _parseBookmarksJsonToNodes(content);
    }

    return [];
  }

  List<BookmarkNode> _parseBookmarksJsonToNodes(String jsonContent) {
    final data = jsonDecode(jsonContent) as Map<String, dynamic>;
    final roots = data['roots'] as Map<String, dynamic>? ?? {};

    final result = <BookmarkNode>[];

    final rootFolders = {
      'bookmark_bar': '书签栏',
      'other': '其他书签',
      'synced': '移动设备',
    };

    for (final entry in rootFolders.entries) {
      final folderData = roots[entry.key];
      if (folderData != null) {
        final node = _parseNode(folderData as Map<String, dynamic>);
        if (node != null) {
          result.add(node);
        }
      }
    }

    return result;
  }

  BookmarkNode? _parseNode(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    final name = data['name'] as String? ?? '';
    final id = data['id'] as String? ?? _uuid.v4();

    if (type == 'url') {
      final url = data['url'] as String? ?? '';
      final dateAddedStr = data['date_added'] as String?;
      DateTime? dateAdded;
      if (dateAddedStr != null) {
        final micros = int.tryParse(dateAddedStr);
        if (micros != null) {
          dateAdded = DateTime.fromMillisecondsSinceEpoch(
            (micros ~/ 1000) - 11644473600000,
          );
        }
      }

      return BookmarkNode(
        id: id,
        name: name,
        type: BookmarkType.url,
        url: url,
        dateAdded: dateAdded,
      );
    }

    if (type == 'folder') {
      final childrenData = data['children'] as List<dynamic>? ?? [];
      final children = <BookmarkNode>[];

      for (final child in childrenData) {
        final node = _parseNode(child as Map<String, dynamic>);
        if (node != null) {
          children.add(node);
        }
      }

      final dateAddedStr = data['date_added'] as String?;
      DateTime? dateAdded;
      if (dateAddedStr != null) {
        final micros = int.tryParse(dateAddedStr);
        if (micros != null) {
          dateAdded = DateTime.fromMillisecondsSinceEpoch(
            (micros ~/ 1000) - 11644473600000,
          );
        }
      }

      return BookmarkNode(
        id: id,
        name: name,
        type: BookmarkType.folder,
        children: children,
        dateAdded: dateAdded,
      );
    }

    return null;
  }

  List<BookmarkNode> searchBookmarks(List<BookmarkNode> bookmarks, String query) {
    if (query.isEmpty) return bookmarks;

    final queryLower = query.toLowerCase();
    final result = <BookmarkNode>[];

    for (final node in bookmarks) {
      final matched = _searchNode(node, queryLower);
      if (matched != null) {
        result.add(matched);
      }
    }

    return result;
  }

  BookmarkNode? _searchNode(BookmarkNode node, String queryLower) {
    if (node.isUrl) {
      final nameMatch = node.name.toLowerCase().contains(queryLower);
      final urlMatch = node.url?.toLowerCase().contains(queryLower) ?? false;
      if (nameMatch || urlMatch) return node;
      return null;
    }

    final matchedChildren = <BookmarkNode>[];
    for (final child in node.children) {
      final matched = _searchNode(child, queryLower);
      if (matched != null) {
        matchedChildren.add(matched);
      }
    }

    final nameMatch = node.name.toLowerCase().contains(queryLower);
    if (nameMatch || matchedChildren.isNotEmpty) {
      return node.copyWith(children: matchedChildren);
    }

    return null;
  }

  List<BookmarkNode> deleteBookmark(List<BookmarkNode> bookmarks, String id) {
    return bookmarks
        .where((node) => node.id != id)
        .map((node) {
          if (node.isFolder && node.children.isNotEmpty) {
            return node.copyWith(children: deleteBookmark(node.children, id));
          }
          return node;
        })
        .toList();
  }

  List<BookmarkNode> editBookmark(
    List<BookmarkNode> bookmarks,
    String id,
    String newName,
    String? newUrl,
  ) {
    return bookmarks.map((node) {
      if (node.id == id) {
        return node.copyWith(
          name: newName,
          url: newUrl ?? node.url,
        );
      }
      if (node.isFolder && node.children.isNotEmpty) {
        return node.copyWith(
          children: editBookmark(node.children, id, newName, newUrl),
        );
      }
      return node;
    }).toList();
  }

  Future<bool> exportBookmarks(
    List<BookmarkNode> bookmarks,
    String outputPath,
  ) async {
    try {
      final file = File(outputPath);
      final parentDir = file.parent;
      if (!await parentDir.exists()) {
        await parentDir.create(recursive: true);
      }

      final jsonList = bookmarks.map((node) => _nodeToDict(node)).toList();
      final rootData = {
        'checksum': '',
        'roots': {
          'bookmark_bar': jsonList.isNotEmpty ? jsonList[0] : null,
          'other': jsonList.length > 1 ? jsonList[1] : null,
          'synced': jsonList.length > 2 ? jsonList[2] : null,
        },
        'version': 1,
      };

      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(rootData),
        encoding: utf8,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Map<String, dynamic> _nodeToDict(BookmarkNode node) {
    final data = <String, dynamic>{
      'id': node.id,
      'name': node.name,
      'type': node.isFolder ? 'folder' : 'url',
    };

    if (node.isUrl) {
      data['url'] = node.url ?? '';
    }

    if (node.dateAdded != null) {
      final chromeTimestamp =
          (node.dateAdded!.millisecondsSinceEpoch + 11644473600000) * 1000;
      data['date_added'] = chromeTimestamp.toString();
    }

    if (node.isFolder && node.children.isNotEmpty) {
      data['children'] = node.children.map((c) => _nodeToDict(c)).toList();
    }

    return data;
  }

  List<BookmarkNode> moveBookmarkNode(
    List<BookmarkNode> bookmarks,
    String bookmarkId,
    String targetFolderId,
  ) {
    BookmarkNode? nodeToMove;

    List<BookmarkNode> removeNode(List<BookmarkNode> nodes) {
      final result = <BookmarkNode>[];
      for (final node in nodes) {
        if (node.id == bookmarkId) {
          nodeToMove = node;
          continue;
        }
        if (node.isFolder && node.children.isNotEmpty) {
          result.add(node.copyWith(children: removeNode(node.children)));
        } else {
          result.add(node);
        }
      }
      return result;
    }

    List<BookmarkNode> insertIntoFolder(List<BookmarkNode> nodes) {
      return nodes.map((node) {
        if (node.id == targetFolderId && node.isFolder) {
          return node.copyWith(children: [...node.children, nodeToMove!]);
        }
        if (node.isFolder && node.children.isNotEmpty) {
          return node.copyWith(children: insertIntoFolder(node.children));
        }
        return node;
      }).toList();
    }

    final removed = removeNode(bookmarks);
    if (nodeToMove == null) return bookmarks;
    return insertIntoFolder(removed);
  }
  List<Bookmark> parseBookmarksJson(String jsonContent) {
    final data = jsonDecode(jsonContent) as Map<String, dynamic>;
    final roots = data['roots'] as Map<String, dynamic>? ?? {};

    final bookmarks = <Bookmark>[];

    final rootFolders = {
      'bookmark_bar': '书签栏',
      'other': '其他书签',
      'synced': '移动设备',
    };

    for (final entry in rootFolders.entries) {
      final folderData = roots[entry.key];
      if (folderData != null) {
        _parseFolder(
          folderData as Map<String, dynamic>,
          entry.value,
          null,
          bookmarks,
        );
      }
    }

    return bookmarks;
  }

  void _parseFolder(
    Map<String, dynamic> folderData,
    String parentPath,
    String? parentId,
    List<Bookmark> bookmarks,
  ) {
    final folderName = folderData['name'] as String? ?? '';
    final folderId = folderData['id'] as String? ?? _uuid.v4();

    final children = folderData['children'] as List<dynamic>?;
    if (children == null || children.isEmpty) return;

    final folderBookmark = Bookmark(
      id: folderId,
      title: folderName,
      isFolder: true,
      parentId: parentId,
      folder: parentPath,
    );
    bookmarks.add(folderBookmark);

    final currentPath = parentPath.isEmpty
        ? folderName
        : '$parentPath/$folderName';

    final folderChildren = <Bookmark>[];

    for (final child in children) {
      final childData = child as Map<String, dynamic>;
      final type = childData['type'] as String?;

      if (type == 'url') {
        final url = childData['url'] as String? ?? '';
        final name = childData['name'] as String? ?? '';
        final dateAdded = childData['date_added'] as String?;
        final dateModified = childData['date_modified'] as String?;

        final linkBookmark = Bookmark(
          id: childData['id'] as String? ?? _uuid.v4(),
          title: name,
          url: url,
          parentId: folderId,
          folder: currentPath,
          created: dateAdded,
          modified: dateModified,
        );
        bookmarks.add(linkBookmark);
        folderChildren.add(linkBookmark);
      } else if (type == 'folder') {
        _parseFolder(childData, currentPath, folderId, bookmarks);
      }
    }

    if (folderChildren.isNotEmpty) {
      final index = bookmarks.indexWhere((b) => b.id == folderId);
      if (index != -1) {
        bookmarks[index] = folderBookmark.copyWith(children: folderChildren);
      }
    }
  }

  Future<List<Bookmark>> loadBookmarksFromFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw FileSystemException('书签文件不存在', filePath);
    }

    final content = await file.readAsString(encoding: utf8);

    if (content.trim().startsWith('{')) {
      return parseBookmarksJson(content);
    }

    return [];
  }

  Future<bool> saveBookmarksToFile(
    List<Bookmark> bookmarks,
    String filePath,
  ) async {
    try {
      final file = File(filePath);
      final parentDir = file.parent;
      if (!await parentDir.exists()) {
        await parentDir.create(recursive: true);
      }

      final jsonList = bookmarks.map((b) => b.toDict()).toList();
      await file.writeAsString(
        jsonEncode(jsonList),
        encoding: utf8,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  List<Bookmark> getBookmarksByFolder(
    List<Bookmark> bookmarks,
    String folderId,
  ) {
    final folder = bookmarks.firstWhere(
      (b) => b.id == folderId && b.isFolder,
      orElse: () => const Bookmark(id: '', title: ''),
    );

    if (folder.id.isEmpty) return [];
    return folder.children ?? [];
  }

  List<Bookmark> searchBookmarksLegacy(
    List<Bookmark> bookmarks,
    String query, {
    String searchType = 'all',
  }) {
    if (query.isEmpty) return bookmarks;

    final queryLower = query.toLowerCase();

    return bookmarks.where((bookmark) {
      if (bookmark.isFolder) {
        if (searchType == 'url') return false;
        return bookmark.title.toLowerCase().contains(queryLower);
      }

      switch (searchType) {
        case 'title':
          return bookmark.title.toLowerCase().contains(queryLower);
        case 'url':
          return bookmark.url.toLowerCase().contains(queryLower);
        default:
          return bookmark.title.toLowerCase().contains(queryLower) ||
              bookmark.url.toLowerCase().contains(queryLower);
      }
    }).toList();
  }

  List<Bookmark> flattenBookmarks(List<Bookmark> bookmarks) {
    final flatList = <Bookmark>[];
    for (final bookmark in bookmarks) {
      flatList.add(bookmark);
      if (bookmark.children != null) {
        flatList.addAll(bookmark.children!);
      }
    }
    return flatList;
  }

  List<Bookmark> getAllLinks(List<Bookmark> bookmarks) {
    return bookmarks.where((b) => b.isLink && b.url.isNotEmpty).toList();
  }

  List<Bookmark> getAllFolders(List<Bookmark> bookmarks) {
    return bookmarks.where((b) => b.isFolder).toList();
  }

  List<Bookmark> moveBookmark(
    List<Bookmark> bookmarks,
    String bookmarkId,
    String targetFolderId,
  ) {
    Bookmark? bookmarkToMove;
    final updatedBookmarks = bookmarks.where((b) {
      if (b.id == bookmarkId) {
        bookmarkToMove = b;
        return false;
      }
      return true;
    }).toList();

    if (bookmarkToMove == null) return bookmarks;

    return updatedBookmarks.map((b) {
      if (b.id == targetFolderId) {
        final newChildren = <Bookmark>[...(b.children ?? []), bookmarkToMove!];
        return b.copyWith(children: newChildren);
      }
      return b;
    }).toList();
  }

  List<Bookmark> deleteBookmarkLegacy(
    List<Bookmark> bookmarks,
    String bookmarkId,
  ) {
    return bookmarks.where((b) => b.id != bookmarkId).map((b) {
      if (b.children != null) {
        return b.copyWith(
          children: deleteBookmarkLegacy(b.children!, bookmarkId),
        );
      }
      return b;
    }).toList();
  }
}

