import 'dart:io';
import 'package:path/path.dart' as p;

/// 路径安全工具类
/// 用于防止路径遍历攻击，确保文件操作安全
class PathSecurity {
  PathSecurity._();

  /// 规范化并验证路径
  ///
  /// 确保路径在指定的基路径内，防止路径遍历攻击
  ///
  /// [path] 要验证的路径
  /// [basePath] 允许的基路径
  /// 返回安全的规范化路径
  /// 抛出 [SecurityException] 如果检测到路径遍历攻击
  static String normalizeAndValidate(String path, String basePath) {
    final normalized = p.normalize(path);
    final absoluteBase = p.normalize(basePath);
    final absolutePath = p.isAbsolute(normalized)
        ? normalized
        : p.join(absoluteBase, normalized);

    // 确保路径在基路径内
    if (!p.isWithin(absoluteBase, absolutePath)) {
      throw SecurityException('Path traversal attempt detected: $path');
    }

    return absolutePath;
  }

  /// 安全地连接路径
  ///
  /// [base] 基路径
  /// [parts] 路径组件
  /// 返回安全的完整路径
  static String safeJoin(String base, List<String> parts) {
    String path = base;
    for (final part in parts) {
      // 验证每个路径组件不包含路径遍历
      if (part == '..' || part == '.' || part.contains(Platform.pathSeparator)) {
        throw SecurityException('Invalid path component: $part');
      }
      path = p.join(path, part);
    }
    return p.normalize(path);
  }

  /// 检查路径是否包含非法字符
  ///
  /// [path] 要检查的路径
  /// [platform] 平台类型，默认当前平台
  /// 返回 true 如果路径包含非法字符
  static bool hasInvalidChars(String path, {String? platform}) {
    final targetPlatform = platform ?? Platform.operatingSystem;
    final invalidChars = _getInvalidChars(targetPlatform);

    for (final char in invalidChars) {
      if (path.contains(char)) {
        return true;
      }
    }

    return false;
  }

  /// 检查路径长度是否有效
  ///
  /// [path] 要检查的路径
  /// 返回 true 如果路径长度有效
  static bool isValidLength(String path) {
    if (Platform.isWindows) {
      // Windows MAX_PATH 限制
      return path.length <= 260;
    }
    // 其他平台没有严格限制
    return path.length <= 4096;
  }

  /// 获取非法字符列表
  static List<String> _getInvalidChars(String platform) {
    if (platform == 'windows') {
      return ['<', '>', ':', '"', '/', '\\', '|', '?', '*', '\x00'];
    }
    // Unix-like 系统
    return ['\x00'];
  }
}

/// 安全异常
class SecurityException implements Exception {
  final String message;

  SecurityException(this.message);

  @override
  String toString() => 'SecurityException: $message';
}
