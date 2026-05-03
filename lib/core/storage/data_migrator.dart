/// 数据迁移工具
///
/// 从旧版 Python/Tkinter 应用的 JSON 数据迁移到 Flutter 版本的 Hive 存储。
/// 支持：
/// - 检测旧版 JSON 数据目录
/// - 迁移 config.json、programs.json、categories.json、theme_config.json
/// - 迁移前自动备份原始 JSON 文件
/// - 迁移后校验数据条目数量一致
/// - 标记迁移完成，避免重复迁移
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

/// 迁移结果
class MigrationResult {
  /// 是否成功
  final bool success;

  /// 迁移的消息
  final String message;

  /// 迁移的条目数量
  final int migratedCount;

  /// 源数据条目数量
  final int sourceCount;

  const MigrationResult({
    required this.success,
    required this.message,
    this.migratedCount = 0,
    this.sourceCount = 0,
  });

  @override
  String toString() =>
      'MigrationResult(success: $success, message: $message, '
      'migrated: $migratedCount, source: $sourceCount)';
}

/// 旧版数据检测结果
class LegacyDataInfo {
  /// 旧版数据目录路径
  final String? directoryPath;

  /// 是否存在 config.json
  final bool hasConfig;

  /// 是否存在 programs.json
  final bool hasPrograms;

  /// 是否存在 categories.json
  final bool hasCategories;

  /// 是否存在 theme_config.json
  final bool hasThemeConfig;

  /// 是否存在 custom_themes.json
  final bool hasCustomThemes;

  const LegacyDataInfo({
    this.directoryPath,
    this.hasConfig = false,
    this.hasPrograms = false,
    this.hasCategories = false,
    this.hasThemeConfig = false,
    this.hasCustomThemes = false,
  });

  /// 是否有任何旧版数据
  bool get hasAnyData =>
      hasConfig || hasPrograms || hasCategories || hasThemeConfig || hasCustomThemes;

  @override
  String toString() => 'LegacyDataInfo(dir: $directoryPath, '
      'config: $hasConfig, programs: $hasPrograms, '
      'categories: $hasCategories, theme: $hasThemeConfig, '
      'customThemes: $hasCustomThemes)';
}

/// Hive 存储键名
class _MigrationStorageKeys {
  static const String migrationComplete = 'migration_complete';
  static const String migrationVersion = 'migration_version';
  static const String migrationDate = 'migration_date';
}

/// Hive Box 名称
const String _migrationBoxName = 'migration_box';
const String _appDataBoxName = 'app_data';

/// 旧版数据文件名
const String _configFileName = 'config.json';
const String _programsFileName = 'programs.json';
const String _categoriesFileName = 'categories.json';
const String _themeConfigFileName = 'theme_config.json';
const String _customThemesFileName = 'custom_themes.json';

/// 当前迁移版本
const String _currentMigrationVersion = '1.0.0';

/// 数据迁移器
///
/// 负责从旧版 Python 应用的 JSON 数据迁移到 Flutter 版本的 Hive 存储。
/// 迁移是可选的，不影响首次安装的用户。
class DataMigrator {
  /// Hive Box 实例（迁移数据）
  late Box _migrationBox;

  /// Hive Box 实例（应用数据）
  late Box _appDataBox;

  /// 是否已初始化
  bool _isInitialized = false;

  // ============================================================
  // 初始化
  // ============================================================

  /// 初始化迁移器
  Future<void> init() async {
    try {
      if (!Hive.isAdapterRegistered(0)) {
        await Hive.initFlutter();
      }
      _migrationBox = await Hive.openBox(_migrationBoxName);
      _appDataBox = await Hive.openBox(_appDataBoxName);
      _isInitialized = true;
      debugPrint('DataMigrator initialized');
    } catch (e) {
      debugPrint('DataMigrator init failed: $e');
      _isInitialized = true;
    }
  }

  // ============================================================
  // 检测旧版数据
  // ============================================================

  /// 检测旧版 JSON 数据目录
  ///
  /// 检查以下位置：
  /// 1. %APPDATA%/ai_app/ (Windows 上的旧版数据目录)
  /// 2. 项目 config/ 目录
  ///
  /// 仅在 Windows 平台上检查 %APPDATA% 目录
  Future<LegacyDataInfo> detectLegacyData() async {
    // 如果不是 Windows 平台，只检查项目目录
    if (!Platform.isWindows) {
      return _detectProjectConfigDir();
    }

    // 检查 %APPDATA%/ai_app/
    final appDataInfo = await _detectAppDataDir();
    if (appDataInfo.hasAnyData) {
      return appDataInfo;
    }

    // 检查项目 config/ 目录
    return _detectProjectConfigDir();
  }

  /// 检查是否需要迁移
  ///
  /// 当满足以下条件时需要迁移：
  /// 1. 尚未标记迁移完成
  /// 2. 存在旧版数据
  Future<bool> isMigrationNeeded() async {
    if (!_isInitialized) {
      await init();
    }

    // 已标记迁移完成，不需要再迁移
    if (_isMigrationComplete()) {
      return false;
    }

    // 检测是否有旧版数据
    final legacyInfo = await detectLegacyData();
    return legacyInfo.hasAnyData;
  }

  // ============================================================
  // 迁移操作
  // ============================================================

  /// 迁移配置 config.json -> Hive
  Future<MigrationResult> migrateConfig() async {
    try {
      final legacyInfo = await detectLegacyData();
      if (!legacyInfo.hasConfig || legacyInfo.directoryPath == null) {
        return const MigrationResult(
          success: true,
          message: '无需迁移配置数据',
        );
      }

      final configPath = '${legacyInfo.directoryPath}/$_configFileName';
      final configFile = File(configPath);

      if (!await configFile.exists()) {
        return const MigrationResult(
          success: true,
          message: '配置文件不存在，跳过迁移',
        );
      }

      final content = await configFile.readAsString(encoding: utf8);
      final jsonData = json.decode(content) as Map<String, dynamic>;

      // 将配置数据写入 Hive
      int migratedCount = 0;
      for (final entry in jsonData.entries) {
        await _appDataBox.put('config_${entry.key}', entry.value);
        migratedCount++;
      }

      debugPrint('Config migrated: $migratedCount entries');
      return MigrationResult(
        success: true,
        message: '配置迁移完成',
        migratedCount: migratedCount,
        sourceCount: jsonData.length,
      );
    } catch (e) {
      debugPrint('Config migration failed: $e');
      return MigrationResult(
        success: false,
        message: '配置迁移失败: $e',
      );
    }
  }

  /// 迁移程序列表 programs.json -> Hive
  Future<MigrationResult> migratePrograms() async {
    try {
      final legacyInfo = await detectLegacyData();
      if (!legacyInfo.hasPrograms || legacyInfo.directoryPath == null) {
        return const MigrationResult(
          success: true,
          message: '无需迁移程序列表数据',
        );
      }

      final programsPath = '${legacyInfo.directoryPath}/$_programsFileName';
      final programsFile = File(programsPath);

      if (!await programsFile.exists()) {
        return const MigrationResult(
          success: true,
          message: '程序列表文件不存在，跳过迁移',
        );
      }

      final content = await programsFile.readAsString(encoding: utf8);
      final jsonData = json.decode(content) as List<dynamic>;

      // 将程序列表写入 Hive
      await _appDataBox.put('programs', jsonData);
      final migratedCount = jsonData.length;

      debugPrint('Programs migrated: $migratedCount entries');
      return MigrationResult(
        success: true,
        message: '程序列表迁移完成',
        migratedCount: migratedCount,
        sourceCount: jsonData.length,
      );
    } catch (e) {
      debugPrint('Programs migration failed: $e');
      return MigrationResult(
        success: false,
        message: '程序列表迁移失败: $e',
      );
    }
  }

  /// 迁移分类 categories.json -> Hive
  Future<MigrationResult> migrateCategories() async {
    try {
      final legacyInfo = await detectLegacyData();
      if (!legacyInfo.hasCategories || legacyInfo.directoryPath == null) {
        return const MigrationResult(
          success: true,
          message: '无需迁移分类数据',
        );
      }

      final categoriesPath = '${legacyInfo.directoryPath}/$_categoriesFileName';
      final categoriesFile = File(categoriesPath);

      if (!await categoriesFile.exists()) {
        return const MigrationResult(
          success: true,
          message: '分类文件不存在，跳过迁移',
        );
      }

      final content = await categoriesFile.readAsString(encoding: utf8);
      final jsonData = json.decode(content) as List<dynamic>;

      // 将分类数据写入 Hive
      await _appDataBox.put('categories', jsonData);
      final migratedCount = jsonData.length;

      debugPrint('Categories migrated: $migratedCount entries');
      return MigrationResult(
        success: true,
        message: '分类迁移完成',
        migratedCount: migratedCount,
        sourceCount: jsonData.length,
      );
    } catch (e) {
      debugPrint('Categories migration failed: $e');
      return MigrationResult(
        success: false,
        message: '分类迁移失败: $e',
      );
    }
  }

  /// 迁移主题 theme_config.json + custom_themes.json -> Hive
  Future<MigrationResult> migrateThemes() async {
    try {
      final legacyInfo = await detectLegacyData();
      if (legacyInfo.directoryPath == null) {
        return const MigrationResult(
          success: true,
          message: '无需迁移主题数据',
        );
      }

      int migratedCount = 0;
      int sourceCount = 0;

      // 迁移 theme_config.json
      if (legacyInfo.hasThemeConfig) {
        final themeConfigPath =
            '${legacyInfo.directoryPath}/$_themeConfigFileName';
        final themeConfigFile = File(themeConfigPath);

        if (await themeConfigFile.exists()) {
          final content = await themeConfigFile.readAsString(encoding: utf8);
          final jsonData = json.decode(content) as Map<String, dynamic>;

          await _appDataBox.put('theme_config', jsonData);
          migratedCount += jsonData.length;
          sourceCount += jsonData.length;
        }
      }

      // 迁移 custom_themes.json（如果存在）
      if (legacyInfo.hasCustomThemes) {
        final customThemesPath =
            '${legacyInfo.directoryPath}/$_customThemesFileName';
        final customThemesFile = File(customThemesPath);

        if (await customThemesFile.exists()) {
          final content = await customThemesFile.readAsString(encoding: utf8);
          final jsonData = json.decode(content) as List<dynamic>;

          await _appDataBox.put('custom_themes', jsonData);
          migratedCount += jsonData.length;
          sourceCount += jsonData.length;
        }
      }

      if (migratedCount == 0) {
        return const MigrationResult(
          success: true,
          message: '无需迁移主题数据',
        );
      }

      debugPrint('Themes migrated: $migratedCount entries');
      return MigrationResult(
        success: true,
        message: '主题迁移完成',
        migratedCount: migratedCount,
        sourceCount: sourceCount,
      );
    } catch (e) {
      debugPrint('Themes migration failed: $e');
      return MigrationResult(
        success: false,
        message: '主题迁移失败: $e',
      );
    }
  }

  // ============================================================
  // 备份与校验
  // ============================================================

  /// 迁移前自动备份原始 JSON 文件
  ///
  /// 将旧版数据文件复制到备份目录，备份目录位于应用支持目录下的
  /// migration_backup/ 子目录中，以时间戳命名。
  Future<String?> backupLegacyData() async {
    try {
      final legacyInfo = await detectLegacyData();
      if (!legacyInfo.hasAnyData || legacyInfo.directoryPath == null) {
        debugPrint('No legacy data to backup');
        return null;
      }

      // 获取应用支持目录
      final appSupportDir = await getApplicationSupportDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final backupDir =
          Directory('${appSupportDir.path}/migration_backup/$timestamp');

      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      // 复制所有存在的旧版数据文件
      final sourceDir = Directory(legacyInfo.directoryPath!);

      await for (final entity in sourceDir.list()) {
        if (entity is File) {
          final fileName = entity.path.split(Platform.pathSeparator).last;
          if (fileName == _configFileName ||
              fileName == _programsFileName ||
              fileName == _categoriesFileName ||
              fileName == _themeConfigFileName ||
              fileName == _customThemesFileName) {
            await entity.copy('${backupDir.path}/$fileName');
            debugPrint('Backed up: $fileName');
          }
        }
      }

      debugPrint('Legacy data backed up to: ${backupDir.path}');
      return backupDir.path;
    } catch (e) {
      debugPrint('Backup failed: $e');
      return null;
    }
  }

  /// 迁移后校验数据条目数量一致
  ///
  /// 对比源 JSON 文件中的数据条目数量与 Hive 中存储的条目数量，
  /// 确保迁移过程中没有数据丢失。
  Future<bool> verifyMigration() async {
    try {
      final legacyInfo = await detectLegacyData();
      if (!legacyInfo.hasAnyData || legacyInfo.directoryPath == null) {
        // 没有旧版数据，校验通过
        return true;
      }

      // 校验 config
      if (legacyInfo.hasConfig) {
        final configPath = '${legacyInfo.directoryPath}/$_configFileName';
        final configFile = File(configPath);
        if (await configFile.exists()) {
          final content = await configFile.readAsString(encoding: utf8);
          final jsonData = json.decode(content) as Map<String, dynamic>;

          // 检查 Hive 中是否有对应的键
          for (final key in jsonData.keys) {
            final hiveKey = 'config_$key';
            if (!_appDataBox.containsKey(hiveKey)) {
              debugPrint('Config verification failed: missing key $hiveKey');
              return false;
            }
          }
        }
      }

      // 校验 programs
      if (legacyInfo.hasPrograms) {
        final programsPath = '${legacyInfo.directoryPath}/$_programsFileName';
        final programsFile = File(programsPath);
        if (await programsFile.exists()) {
          final content = await programsFile.readAsString(encoding: utf8);
          final jsonData = json.decode(content) as List<dynamic>;

          final storedPrograms = _appDataBox.get('programs') as List<dynamic>?;
          if (storedPrograms == null || storedPrograms.length != jsonData.length) {
            debugPrint('Programs verification failed: '
                'source=${jsonData.length}, stored=${storedPrograms?.length ?? 0}');
            return false;
          }
        }
      }

      // 校验 categories
      if (legacyInfo.hasCategories) {
        final categoriesPath =
            '${legacyInfo.directoryPath}/$_categoriesFileName';
        final categoriesFile = File(categoriesPath);
        if (await categoriesFile.exists()) {
          final content = await categoriesFile.readAsString(encoding: utf8);
          final jsonData = json.decode(content) as List<dynamic>;

          final storedCategories =
              _appDataBox.get('categories') as List<dynamic>?;
          if (storedCategories == null ||
              storedCategories.length != jsonData.length) {
            debugPrint('Categories verification failed: '
                'source=${jsonData.length}, stored=${storedCategories?.length ?? 0}');
            return false;
          }
        }
      }

      // 校验 theme_config
      if (legacyInfo.hasThemeConfig) {
        final themeConfigPath =
            '${legacyInfo.directoryPath}/$_themeConfigFileName';
        final themeConfigFile = File(themeConfigPath);
        if (await themeConfigFile.exists()) {
          final content = await themeConfigFile.readAsString(encoding: utf8);
          final jsonData = json.decode(content) as Map<String, dynamic>;

          final storedConfig =
              _appDataBox.get('theme_config') as Map<dynamic, dynamic>?;
          if (storedConfig == null || storedConfig.length != jsonData.length) {
            debugPrint('Theme config verification failed');
            return false;
          }
        }
      }

      debugPrint('Migration verification passed');
      return true;
    } catch (e) {
      debugPrint('Migration verification failed: $e');
      return false;
    }
  }

  /// 标记迁移完成，避免重复迁移
  ///
  /// 在 Hive 中记录迁移完成状态、版本号和日期。
  Future<void> markMigrationComplete() async {
    try {
      await _migrationBox.put(
        _MigrationStorageKeys.migrationComplete,
        true,
      );
      await _migrationBox.put(
        _MigrationStorageKeys.migrationVersion,
        _currentMigrationVersion,
      );
      await _migrationBox.put(
        _MigrationStorageKeys.migrationDate,
        DateTime.now().toIso8601String(),
      );
      debugPrint('Migration marked as complete (v$_currentMigrationVersion)');
    } catch (e) {
      debugPrint('Failed to mark migration complete: $e');
    }
  }

  // ============================================================
  // 一键迁移
  // ============================================================

  /// 执行完整迁移流程
  ///
  /// 1. 备份旧版数据
  /// 2. 迁移配置
  /// 3. 迁移程序列表
  /// 4. 迁移分类
  /// 5. 迁移主题
  /// 6. 校验迁移
  /// 7. 标记迁移完成
  Future<List<MigrationResult>> migrateAll() async {
    final results = <MigrationResult>[];

    // 1. 备份旧版数据
    final backupPath = await backupLegacyData();
    if (backupPath != null) {
      results.add(MigrationResult(
        success: true,
        message: '备份完成: $backupPath',
      ));
    }

    // 2. 迁移配置
    results.add(await migrateConfig());

    // 3. 迁移程序列表
    results.add(await migratePrograms());

    // 4. 迁移分类
    results.add(await migrateCategories());

    // 5. 迁移主题
    results.add(await migrateThemes());

    // 6. 校验迁移
    final verified = await verifyMigration();
    if (!verified) {
      results.add(const MigrationResult(
        success: false,
        message: '迁移校验失败，数据条目不一致',
      ));
      return results;
    }

    // 7. 标记迁移完成
    await markMigrationComplete();

    results.add(const MigrationResult(
      success: true,
      message: '数据迁移全部完成',
    ));

    return results;
  }

  // ============================================================
  // 内部方法
  // ============================================================

  /// 检查是否已标记迁移完成
  bool _isMigrationComplete() {
    try {
      final value = _migrationBox.get(
        _MigrationStorageKeys.migrationComplete,
        defaultValue: false,
      );
      return (value as bool?) ?? false;
    } catch (e) {
      return false;
    }
  }

  /// 检测 %APPDATA%/ai_app/ 目录（仅 Windows）
  Future<LegacyDataInfo> _detectAppDataDir() async {
    if (!Platform.isWindows) {
      return const LegacyDataInfo();
    }

    try {
      final appDataDir = Platform.environment['APPDATA'];
      if (appDataDir == null) {
        return const LegacyDataInfo();
      }

      final aiAppDir = Directory('$appDataDir${Platform.pathSeparator}ai_app');
      if (!await aiAppDir.exists()) {
        return const LegacyDataInfo();
      }

      return _scanDirectoryForLegacyData(aiAppDir.path);
    } catch (e) {
      debugPrint('Failed to detect APPDATA dir: $e');
      return const LegacyDataInfo();
    }
  }

  /// 检测项目 config/ 目录
  Future<LegacyDataInfo> _detectProjectConfigDir() async {
    try {
      // 检查可执行文件同级目录下的 config/
      final exePath = Platform.resolvedExecutable;
      final exeDir = exePath.substring(
        0,
        exePath.lastIndexOf(Platform.pathSeparator),
      );
      final configDir =
          Directory('$exeDir${Platform.pathSeparator}config');

      if (await configDir.exists()) {
        final info = _scanDirectoryForLegacyData(configDir.path);
        if (info.hasAnyData) {
          return info;
        }
      }

      // 检查应用支持目录下的 config/
      final appSupportDir = await getApplicationSupportDirectory();
      final appConfigDir =
          Directory('${appSupportDir.path}${Platform.pathSeparator}config');

      if (await appConfigDir.exists()) {
        final info = _scanDirectoryForLegacyData(appConfigDir.path);
        if (info.hasAnyData) {
          return info;
        }
      }

      return const LegacyDataInfo();
    } catch (e) {
      debugPrint('Failed to detect project config dir: $e');
      return const LegacyDataInfo();
    }
  }

  /// 扫描目录中的旧版数据文件
  LegacyDataInfo _scanDirectoryForLegacyData(String dirPath) {
    bool hasConfig = false;
    bool hasPrograms = false;
    bool hasCategories = false;
    bool hasThemeConfig = false;
    bool hasCustomThemes = false;

    final configPath = '$dirPath${Platform.pathSeparator}$_configFileName';
    final programsPath = '$dirPath${Platform.pathSeparator}$_programsFileName';
    final categoriesPath =
        '$dirPath${Platform.pathSeparator}$_categoriesFileName';
    final themeConfigPath =
        '$dirPath${Platform.pathSeparator}$_themeConfigFileName';
    final customThemesPath =
        '$dirPath${Platform.pathSeparator}$_customThemesFileName';

    hasConfig = File(configPath).existsSync();
    hasPrograms = File(programsPath).existsSync();
    hasCategories = File(categoriesPath).existsSync();
    hasThemeConfig = File(themeConfigPath).existsSync();
    hasCustomThemes = File(customThemesPath).existsSync();

    return LegacyDataInfo(
      directoryPath: dirPath,
      hasConfig: hasConfig,
      hasPrograms: hasPrograms,
      hasCategories: hasCategories,
      hasThemeConfig: hasThemeConfig,
      hasCustomThemes: hasCustomThemes,
    );
  }

  // ============================================================
  // 公共属性
  // ============================================================

  /// 是否已初始化
  bool get isInitialized => _isInitialized;

  /// 获取迁移完成日期
  String? get migrationDate {
    try {
      final value = _migrationBox.get(
        _MigrationStorageKeys.migrationDate,
      );
      return value as String?;
    } catch (e) {
      return null;
    }
  }

  /// 获取迁移版本
  String? get migrationVersion {
    try {
      final value = _migrationBox.get(
        _MigrationStorageKeys.migrationVersion,
      );
      return value as String?;
    } catch (e) {
      return null;
    }
  }

  /// 是否已完成迁移
  bool get isMigrationDone => _isMigrationComplete();
}
