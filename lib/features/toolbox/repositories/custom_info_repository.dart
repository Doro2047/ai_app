/// 自定义信息仓库
///
/// 使用 Hive 存储 CustomInfo 数据，提供 CRUD 操作。
library;

import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/custom_info.dart';

/// Hive Box 名称
const String _customInfoBoxName = 'toolbox_custom_info';

/// 自定义信息仓库
class CustomInfoRepository {
  late Box _box;
  final _uuid = const Uuid();

  /// 初始化仓库
  Future<void> init() async {
    _box = await Hive.openBox(_customInfoBoxName);
  }

  /// 添加自定义信息
  Future<CustomInfo> add(CustomInfo info) async {
    final newInfo = info.id.isEmpty
        ? info.copyWith(
            id: _uuid.v4(),
            createdAt: DateTime.now().toIso8601String(),
            updatedAt: DateTime.now().toIso8601String(),
          )
        : info;
    await _box.put(newInfo.id, newInfo.toDict());
    return newInfo;
  }

  /// 更新自定义信息
  Future<void> update(CustomInfo info) async {
    final updated = info.copyWith(
      updatedAt: DateTime.now().toIso8601String(),
    );
    await _box.put(updated.id, updated.toDict());
  }

  /// 删除自定义信息
  Future<void> remove(String id) async {
    await _box.delete(id);
  }

  /// 获取单条自定义信息
  CustomInfo? get(String id) {
    final data = _box.get(id);
    if (data == null) return null;
    return CustomInfo.fromDict(Map<String, dynamic>.from(data as Map));
  }

  /// 获取所有自定义信息
  List<CustomInfo> getAll() {
    return _box.values.map((data) {
      return CustomInfo.fromDict(Map<String, dynamic>.from(data as Map));
    }).toList();
  }

  /// 关闭仓库
  Future<void> close() async {
    await _box.close();
  }
}
