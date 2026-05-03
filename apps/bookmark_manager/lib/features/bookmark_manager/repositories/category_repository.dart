library;
import 'package:hive_flutter/hive_flutter.dart';

import '../models/bookmark_category.dart';

const _boxName = 'bookmark_categories';

class CategoryRepository {
  Future<Box<Map>> get _box async {
    return await Hive.openBox<Map>(_boxName);
  }

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

    if (categories.isEmpty) {
      return BookmarkCategory.defaults;
    }

    return categories;
  }

  Future<void> addCategory(BookmarkCategory category) async {
    final box = await _box;
    await box.put(category.id, category.toDict());
  }

  Future<void> updateCategory(BookmarkCategory category) async {
    final box = await _box;
    await box.put(category.id, category.toDict());
  }

  Future<void> deleteCategory(String categoryId) async {
    final box = await _box;
    await box.delete(categoryId);
  }

  Future<BookmarkCategory?> getCategory(String categoryId) async {
    final box = await _box;
    final data = box.get(categoryId);
    if (data is Map) {
      return BookmarkCategory.fromDict(data.cast<String, dynamic>());
    }
    return null;
  }

  Future<void> resetToDefaults() async {
    final box = await _box;
    await box.clear();
    for (final category in BookmarkCategory.defaults) {
      await box.put(category.id, category.toDict());
    }
  }
}
