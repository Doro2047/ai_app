/// 配置仓库
///
/// 使用 Hive 存储应用配置项。
library;

import 'package:hive_flutter/hive_flutter.dart';

/// Hive Box 名称
const String _configBoxName = 'toolbox_config';

/// 配置仓库
class ConfigRepository {
  late Box _box;

  /// 初始化仓库
  Future<void> init() async {
    _box = await Hive.openBox(_configBoxName);
  }

  /// 获取配置值
  T getConfig<T>(String key, T defaultValue) {
    final value = _box.get(key);
    if (value == null) return defaultValue;
    if (value is T) return value;
    return defaultValue;
  }

  /// 设置配置值
  Future<void> setConfig<T>(String key, T value) async {
    await _box.put(key, value);
  }

  /// 删除配置项
  Future<void> removeConfig(String key) async {
    await _box.delete(key);
  }

  /// 获取所有配置
  Map<String, dynamic> getAllConfig() {
    return Map<String, dynamic>.from(_box.toMap());
  }

  /// 清空所有配置
  Future<void> clearAll() async {
    await _box.clear();
  }

  /// 关闭仓库
  Future<void> close() async {
    await _box.close();
  }
}
