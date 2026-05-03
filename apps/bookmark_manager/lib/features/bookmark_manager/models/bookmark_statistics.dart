class BookmarkStatistics {
  final int totalBookmarks;
  final int totalFolders;
  final int totalLinks;
  final int invalidLinks;
  final int validatedLinks;
  final Duration averageResponseTime;

  const BookmarkStatistics({
    this.totalBookmarks = 0,
    this.totalFolders = 0,
    this.totalLinks = 0,
    this.invalidLinks = 0,
    this.validatedLinks = 0,
    this.averageResponseTime = Duration.zero,
  });

  int get validLinks => validatedLinks - invalidLinks;

  double get validationCoverage {
    if (totalLinks == 0) return 0.0;
    return validatedLinks / totalLinks;
  }

  double get validityRate {
    if (validatedLinks == 0) return 0.0;
    return validLinks / validatedLinks;
  }

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
