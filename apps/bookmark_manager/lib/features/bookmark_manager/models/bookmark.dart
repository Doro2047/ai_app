library;
import 'dart:convert';

class Bookmark {
  final String id;
  final String title;
  final String url;
  final String? parentId;
  final String? folder;
  final String? created;
  final String? modified;
  final bool isFolder;
  final List<Bookmark>? children;

  const Bookmark({
    required this.id,
    required this.title,
    this.url = '',
    this.parentId,
    this.folder,
    this.created,
    this.modified,
    this.isFolder = false,
    this.children,
  });

  bool get isLink => !isFolder;

  Map<String, dynamic> toDict() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'parentId': parentId,
      'folder': folder,
      'created': created,
      'modified': modified,
      'isFolder': isFolder,
      'children': children?.map((c) => c.toDict()).toList(),
    };
  }

  factory Bookmark.fromDict(Map<String, dynamic> data) {
    final childrenData = data['children'] as List<dynamic>?;
    return Bookmark(
      id: data['id'] as String,
      title: data['title'] as String,
      url: data['url'] as String? ?? '',
      parentId: data['parentId'] as String?,
      folder: data['folder'] as String?,
      created: data['created'] as String?,
      modified: data['modified'] as String?,
      isFolder: data['isFolder'] as bool? ?? false,
      children: childrenData
          ?.map((c) => Bookmark.fromDict(c as Map<String, dynamic>))
          .toList(),
    );
  }

  List<Bookmark> toFlatList() {
    final result = <Bookmark>[this];
    if (children != null) {
      for (final child in children!) {
        result.addAll(child.toFlatList());
      }
    }
    return result;
  }

  String toJson() => jsonEncode(toDict());

  factory Bookmark.fromJson(String source) =>
      Bookmark.fromDict(jsonDecode(source) as Map<String, dynamic>);

  Bookmark copyWith({
    String? id,
    String? title,
    String? url,
    String? parentId,
    String? folder,
    String? created,
    String? modified,
    bool? isFolder,
    List<Bookmark>? children,
  }) {
    return Bookmark(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      parentId: parentId ?? this.parentId,
      folder: folder ?? this.folder,
      created: created ?? this.created,
      modified: modified ?? this.modified,
      isFolder: isFolder ?? this.isFolder,
      children: children ?? this.children,
    );
  }

  @override
  String toString() {
    return 'Bookmark(id: $id, title: $title, url: $url, isFolder: $isFolder)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Bookmark && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
