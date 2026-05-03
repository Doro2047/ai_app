class BookmarkCategory {
  final String id;
  final String name;
  final String icon;
  final String color;

  const BookmarkCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  static const List<BookmarkCategory> defaults = [
    BookmarkCategory(
      id: 'tech',
      name: '技术',
      icon: 'code',
      color: '#3B82F6',
    ),
    BookmarkCategory(
      id: 'design',
      name: '设计',
      icon: 'palette',
      color: '#8B5CF6',
    ),
    BookmarkCategory(
      id: 'ai_tools',
      name: 'AI工具',
      icon: 'smart_toy',
      color: '#06B6D4',
    ),
    BookmarkCategory(
      id: 'search',
      name: '搜索',
      icon: 'search',
      color: '#10B981',
    ),
    BookmarkCategory(
      id: 'education',
      name: '教育',
      icon: 'school',
      color: '#F59E0B',
    ),
    BookmarkCategory(
      id: 'cloud',
      name: '云存储',
      icon: 'cloud',
      color: '#6366F1',
    ),
    BookmarkCategory(
      id: 'entertainment',
      name: '娱乐',
      icon: 'movie',
      color: '#EC4899',
    ),
    BookmarkCategory(
      id: 'shopping',
      name: '购物',
      icon: 'shopping_cart',
      color: '#F97316',
    ),
    BookmarkCategory(
      id: 'social',
      name: '社交',
      icon: 'people',
      color: '#14B8A6',
    ),
    BookmarkCategory(
      id: 'news',
      name: '新闻',
      icon: 'newspaper',
      color: '#64748B',
    ),
    BookmarkCategory(
      id: 'other',
      name: '其他',
      icon: 'folder',
      color: '#94A3B8',
    ),
  ];

  Map<String, dynamic> toDict() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
    };
  }

  factory BookmarkCategory.fromDict(Map<String, dynamic> data) {
    return BookmarkCategory(
      id: data['id'] as String,
      name: data['name'] as String,
      icon: data['icon'] as String,
      color: data['color'] as String,
    );
  }

  int get colorInt {
    try {
      final hex = color.replaceAll('#', '');
      return int.parse(hex, radix: 16);
    } catch (e) {
      return 0xFF94A3B8;
    }
  }
}

const Map<String, List<String>> categoryKeywords = {
  'tech': [
    'github', 'stackoverflow', 'csdn', 'juejin', 'zhihu',
    'segmentfault', 'v2ex', 'oschina', 'gitlab', 'npm',
  ],
  'design': [
    'design', 'behance', 'dribbble', 'pinterest', 'seeseed',
    'maliquankai', 'toprender', 'meitu', 'figma', 'canva',
  ],
  'ai_tools': [
    'ai-bot', 'ai', 'gamma', 'mindshow', 'writingo',
    'booltool', 'lalal', 'suno', 'chatgpt', 'copilot',
  ],
  'search': [
    'search', 'so', 'chongbuluo', 'saucenao', 'trace', 'bing',
  ],
  'education': [
    'excel', 'learn', 'course', 'tutorial', 'microsoft',
    'coursera', 'udemy', 'edx',
  ],
  'cloud': [
    'pan.baidu', 'weiyun', 'cloud', 'disk', 'google.drive',
    'dropbox', 'onedrive',
  ],
  'entertainment': [
    'youtube', 'netflix', 'spotify', 'music', 'bilibili',
    'twitch',
  ],
  'shopping': [
    'taobao', 'jd', 'pinduoduo', 'amazon', 'ebay', 'tmall',
  ],
  'social': [
    'twitter', 'facebook', 'instagram', 'weibo', 'douyin',
    'reddit', 'discord',
  ],
  'news': [
    'news', 'bbc', 'cnn', 'reuters', 'xinhua', 'ifeng',
  ],
};

String categorizeBookmark(String title, String url) {
  final combined = '${title.toLowerCase()} ${url.toLowerCase()}';

  for (final entry in categoryKeywords.entries) {
    for (final keyword in entry.value) {
      if (combined.contains(keyword)) {
        return entry.key;
      }
    }
  }
  return 'other';
}
