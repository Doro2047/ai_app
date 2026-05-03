/// 书签统计模型
class BookmarkStatistics {
  /// 书签总数
  final int totalBookmarks;

  /// 文件夹总数
  final int totalFolders;

  /// 链接总数
  final int totalLinks;

  /// 无效链接数
  final int invalidLinks;

  /// 已验证链接数
  final int validatedLinks;

  /// 平均响应时间
  final Duration averageResponseTime;

  const BookmarkStatistics({
    this.totalBookmarks = 0,
    this.totalFolders = 0,
    this.totalLinks = 0,
    this.invalidLinks = 0,
    this.validatedLinks = 0,
    this.averageResponseTime = Duration.zero,
  });

  /// 有效链接数
  int get validLinks => validatedLinks - invalidLinks;

  /// 验证覆盖率
  double get validationCoverage {
    if (totalLinks == 0) return 0.0;
    return validatedLinks / totalLinks;
  }

  /// 有效链接率
  double get validityRate {
    if (validatedLinks == 0) return 0.0;
    return validLinks / validatedLinks;
  }

  /// 复制并修改
  BookmarkStatistics copyWith({
    int? totalBookmarks,
    int? totalFolders,
    int? totalLinks,
    int? invalidLinks,
    int? validatedLinks,
    Duration? averageResponseTime,
  }) {
    return BookmarkStatistics(
      totalBookmarks: totalBookmarks ?? this.totalBookmarks,
      totalFolders: totalFolders ?? this.totalFolders,
      totalLinks: totalLinks ?? this.totalLinks,
      invalidLinks: invalidLinks ?? this.invalidLinks,
      validatedLinks: validatedLinks ?? this.validatedLinks,
      averageResponseTime:
          averageResponseTime ?? this.averageResponseTime,
    );
  }

  /// 从书签数据计算统计信息
  factory BookmarkStatistics.fromBookmarks(List<Map<String, dynamic>> bookmarks) {
    int totalBookmarks = bookmarks.length;
    int totalFolders = bookmarks.where((b) => b['isFolder'] == true).length;
    int totalLinks = bookmarks.where((b) => b['isFolder'] != true).length;
    int invalidLinks = bookmarks.where((b) => b['isFolder'] != true && b['isValid'] == false).length;
    int validatedLinks = bookmarks.where((b) => b['isFolder'] != true && b['isValid'] != null).length;

    final responseTimes = bookmarks
        .where((b) => b['responseTimeMs'] != null)
        .map((b) => b['responseTimeMs'] as int);

    Duration avgResponseTime = Duration.zero;
    if (responseTimes.isNotEmpty) {
      final totalMs = responseTimes.reduce((a, b) => a + b);
      avgResponseTime = Duration(milliseconds: totalMs ~/ responseTimes.length);
    }

    return BookmarkStatistics(
      totalBookmarks: totalBookmarks,
      totalFolders: totalFolders,
      totalLinks: totalLinks,
      invalidLinks: invalidLinks,
      validatedLinks: validatedLinks,
      averageResponseTime: avgResponseTime,
    );
  }

  @override
  String toString() {
    return 'BookmarkStatistics(bookmarks: $totalBookmarks, folders: $totalFolders, '
        'links: $totalLinks, invalid: $invalidLinks, validated: $validatedLinks)';
  }
}
