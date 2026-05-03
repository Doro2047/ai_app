import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';

class StorageService {
  late Box _box;

  StorageService();

  static Future<StorageService> init() async {
    final service = StorageService();
    service._box = await Hive.openBox(AppConstants.hiveBoxName);
    return service;
  }

  Future<void> setString(String key, String value) async {
    await _box.put(key, value);
  }

  String? getString(String key) {
    return _box.get(key) as String?;
  }

  Future<void> setInt(String key, int value) async {
    await _box.put(key, value);
  }

  int? getInt(String key) {
    return _box.get(key) as int?;
  }

  Future<void> setBool(String key, bool value) async {
    await _box.put(key, value);
  }

  bool? getBool(String key) {
    return _box.get(key) as bool?;
  }

  Future<void> setDouble(String key, double value) async {
    await _box.put(key, value);
  }

  double? getDouble(String key) {
    return _box.get(key) as double?;
  }

  Future<void> remove(String key) async {
    await _box.delete(key);
  }

  Future<void> clear() async {
    await _box.clear();
  }

  Future<void> close() async {
    await _box.close();
  }
}
