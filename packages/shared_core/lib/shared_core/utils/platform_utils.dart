import 'dart:io';
import 'package:flutter/foundation.dart';

/// 平台检测工具类
/// 提供跨平台检测和平台信息获取功能
class PlatformUtils {
  /// 判断当前是否为 Windows 平台
  static bool isWindows() {
    return Platform.isWindows;
  }

  /// 判断当前是否为 Android 平台
  static bool isAndroid() {
    return Platform.isAndroid;
  }

  /// 判断当前是否为 iOS 平台
  static bool isIOS() {
    return Platform.isIOS;
  }

  /// 判断当前是否为 macOS 平台
  static bool isMacOS() {
    return Platform.isMacOS;
  }

  /// 判断当前是否为 Linux 平台
  static bool isLinux() {
    return Platform.isLinux;
  }

  /// 判断当前是否为 Fuchsia 平台
  static bool isFuchsia() {
    return Platform.isFuchsia;
  }

  /// 判断当前是否为桌面平台 (Windows, macOS, Linux)
  static bool isDesktop() {
    return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  }

  /// 判断当前是否为移动平台 (Android, iOS)
  static bool isMobile() {
    return Platform.isAndroid || Platform.isIOS;
  }

  /// 判断当前是否为 Web 平台
  /// 使用 flutter/foundation.dart 中的 kIsWeb 进行 Web 检测
  static bool isWeb() {
    return kIsWeb;
  }

  /// 获取当前平台名称字符串
  static String getPlatformName() {
    if (isWindows()) return 'Windows';
    if (isAndroid()) return 'Android';
    if (isIOS()) return 'iOS';
    if (isMacOS()) return 'macOS';
    if (isLinux()) return 'Linux';
    if (isFuchsia()) return 'Fuchsia';
    return 'Unknown';
  }

  /// 获取当前平台的本地化操作系统名称
  static String getLocalizedPlatformName() {
    if (isWindows()) return 'Windows';
    if (isAndroid()) return 'Android';
    if (isIOS()) return 'iOS';
    if (isMacOS()) return 'macOS';
    if (isLinux()) return 'Linux';
    if (isFuchsia()) return 'Fuchsia';
    return '未知平台';
  }

  /// 判断是否为调试环境
  static bool isDebugMode() {
    bool isDebug = false;
    assert(isDebug = true);
    return isDebug;
  }

  /// 判断是否为发布环境
  static bool isReleaseMode() {
    return !isDebugMode();
  }

  /// 获取平台图标（可用于 UI 显示）
  static String getPlatformIcon() {
    if (isWindows()) return '🖥️';
    if (isAndroid()) return '📱';
    if (isIOS()) return '🍎';
    if (isMacOS()) return '💻';
    if (isLinux()) return '🐧';
    return '❓';
  }
}
