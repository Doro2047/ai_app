/// 应用常量定义
class AppConstants {
  AppConstants._();

  // 应用信息
  static const String appName = 'AI Apps 工具集';
  static const String appVersion = '3.0.0';
  static const String apiBaseUrl = 'https://api.free-ai-app.com';

  // 存储键
  static const String hiveBoxName = 'app_data';
  static const String keyTheme = 'theme_mode';
  static const String keyLanguage = 'language_code';
  static const String keyOnboardingCompleted = 'onboarding_completed';

  // 网络相关
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;
  static const int sendTimeout = 30000;

  // 分页相关
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // 文件相关
  static const int maxFileSize = 50 * 1024 * 1024; // 50MB
  static const List<String> allowedImageExtensions = [
    '.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp',
  ];
}
