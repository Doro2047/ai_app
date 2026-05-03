enum BookmarkType { folder, url }

class BookmarkNode {
  final String id;
  final String name;
  final BookmarkType type;
  final String? url;
  final List<BookmarkNode> children;
  final DateTime? dateAdded;

  const BookmarkNode({
    required this.id,
    required this.name,
    required this.type,
    this.url,
    this.children = const [],
    this.dateAdded,
  });

  bool get isFolder => type == BookmarkType.folder;
  bool get isUrl => type == BookmarkType.url;

  int get descendantCount {
    if (isUrl) return 0;
    return children.fold(0, (sum, child) => sum + 1 + child.descendantCount);
  }

  BookmarkNode copyWith({
    String? id,
    String? name,
    BookmarkType? type,
    String? url,
    List<BookmarkNode>? children,
    DateTime? dateAdded,
  }) {
    return BookmarkNode(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      url: url ?? this.url,
      children: children ?? this.children,
      dateAdded: dateAdded ?? this.dateAdded,
    );
  }
}
