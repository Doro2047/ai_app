
/// 应用配置模型
/// 使用 Hive Box 进行存储
class AppConfig {
  String appName;
  String version;
  bool isDarkMode;
  String languageCode;
  bool notificationsEnabled;
  int themeColor;
  bool autoUpdate;
  String lastBackupPath;

  AppConfig({
    this.appName = 'AI App',
    this.version = '1.0.0',
    this.isDarkMode = false,
    this.languageCode = 'zh',
    this.notificationsEnabled = true,
    this.themeColor = 0xFF2196F3,
    this.autoUpdate = true,
    this.lastBackupPath = '',
  });

  /// 从 JSON 创建
  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      appName: json['appName'] as String? ?? 'AI App',
      version: json['version'] as String? ?? '1.0.0',
      isDarkMode: json['isDarkMode'] as bool? ?? false,
      languageCode: json['languageCode'] as String? ?? 'zh',
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      themeColor: json['themeColor'] as int? ?? 0xFF2196F3,
      autoUpdate: json['autoUpdate'] as bool? ?? true,
      lastBackupPath: json['lastBackupPath'] as String? ?? '',
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'appName': appName,
      'version': version,
      'isDarkMode': isDarkMode,
      'languageCode': languageCode,
      'notificationsEnabled': notificationsEnabled,
      'themeColor': themeColor,
      'autoUpdate': autoUpdate,
      'lastBackupPath': lastBackupPath,
    };
  }

  /// 复制并修改
  AppConfig copyWith({
    String? appName,
    String? version,
    bool? isDarkMode,
    String? languageCode,
    bool? notificationsEnabled,
    int? themeColor,
    bool? autoUpdate,
    String? lastBackupPath,
  }) {
    return AppConfig(
      appName: appName ?? this.appName,
      version: version ?? this.version,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      languageCode: languageCode ?? this.languageCode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      themeColor: themeColor ?? this.themeColor,
      autoUpdate: autoUpdate ?? this.autoUpdate,
      lastBackupPath: lastBackupPath ?? this.lastBackupPath,
    );
  }
}
