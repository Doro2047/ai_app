/// 书签数据模型
///
/// 表示一个书签节点，可以是文件夹或链接。
library;
import 'dart:convert';

class Bookmark {
  /// 唯一标识符
  final String id;

  /// 书签标题
  final String title;

  /// 书签 URL（文件夹为空字符串）
  final String url;

  /// 父文件夹 ID
  final String? parentId;

  /// 文件夹路径（如 "书签栏/技术/GitHub"）
  final String? folder;

  /// 创建时间
  final String? created;

  /// 修改时间
  final String? modified;

  /// 是否为文件夹
  final bool isFolder;

  /// 子节点列表（仅文件夹有效）
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

  /// 是否为链接（非文件夹）
  bool get isLink => !isFolder;

  /// 转换为 Map
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

  /// 从 Map 创建
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

  /// 将树形结构扁平化为列表
  List<Bookmark> toFlatList() {
    final result = <Bookmark>[this];
    if (children != null) {
      for (final child in children!) {
        result.addAll(child.toFlatList());
      }
    }
    return result;
  }

  /// 转换为 JSON 字符串
  String toJson() => jsonEncode(toDict());

  /// 从 JSON 字符串创建
  factory Bookmark.fromJson(String source) =>
      Bookmark.fromDict(jsonDecode(source) as Map<String, dynamic>);

  /// 复制并修改
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
