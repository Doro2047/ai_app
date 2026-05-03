/// 分类仓库
///
/// 使用 Hive 存储书签分类数据。
library;
import 'package:hive_flutter/hive_flutter.dart';

import '../models/bookmark_category.dart';

const _boxName = 'bookmark_categories';

class CategoryRepository {
  Future<Box<Map>> get _box async {
    return await Hive.openBox<Map>(_boxName);
  }

  /// 获取所有分类
  Future<List<BookmarkCategory>> getCategories() async {
    final box = await _box;
    final categories = <BookmarkCategory>[];

    for (final key in box.keys) {
      final data = box.get(key);
      if (data is Map) {
        categories.add(BookmarkCategory.fromDict(
          data.cast<String, dynamic>(),
        ));
      }
    }

    // 如果为空，返回默认分类
    if (categories.isEmpty) {
      return BookmarkCategory.defaults;
    }

    return categories;
  }

  /// 添加分类
  Future<void> addCategory(BookmarkCategory category) async {
    final box = await _box;
    await box.put(category.id, category.toDict());
  }

  /// 更新分类
  Future<void> updateCategory(BookmarkCategory category) async {
    final box = await _box;
    await box.put(category.id, category.toDict());
  }

  /// 删除分类
  Future<void> deleteCategory(String categoryId) async {
    final box = await _box;
    await box.delete(categoryId);
  }

  /// 获取单个分类
  Future<BookmarkCategory?> getCategory(String categoryId) async {
    final box = await _box;
    final data = box.get(categoryId);
    if (data is Map) {
      return BookmarkCategory.fromDict(data.cast<String, dynamic>());
    }
    return null;
  }

  /// 清空所有分类并重置为默认
  Future<void> resetToDefaults() async {
    final box = await _box;
    await box.clear();
    for (final category in BookmarkCategory.defaults) {
      await box.put(category.id, category.toDict());
    }
  }
}
