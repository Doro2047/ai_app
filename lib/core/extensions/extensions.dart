import 'package:flutter/material.dart';

/// BuildContext 扩展
extension BuildContextX on BuildContext {
  /// 获取主题数据
  ThemeData get theme => Theme.of(this);

  /// 获取文本主题
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// 获取颜色方案
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// 获取媒体尺寸
  Size get mediaSize => MediaQuery.sizeOf(this);

  /// 获取媒体宽度
  double get mediaWidth => MediaQuery.sizeOf(this).width;

  /// 获取媒体高度
  double get mediaHeight => MediaQuery.sizeOf(this).height;

  /// 获取底部导航栏高度
  double get bottomPadding => MediaQuery.paddingOf(this).bottom;

  /// 获取顶部状态栏高度
  double get topPadding => MediaQuery.paddingOf(this).top;

  /// 导航返回
  void pop<T extends Object?>([T? result]) => Navigator.of(this).pop(result);

  /// 导航到命名路由
  Future<T?> pushNamed<T extends Object?>(String name, {Object? arguments}) {
    return Navigator.of(this).pushNamed(name, arguments: arguments);
  }

  /// 替换当前路由
  Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    String name, {
    TO? result,
    Object? arguments,
  }) {
    return Navigator.of(this).pushReplacementNamed(name, result: result, arguments: arguments);
  }

  /// 显示 SnackBar
  void showSnackBar(String message, {Duration? duration}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration ?? const Duration(seconds: 2),
      ),
    );
  }

  /// 显示错误 SnackBar
  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: theme.colorScheme.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

/// String 扩展
extension StringX on String {
  /// 首字母大写
  String capitalize() => '${this[0].toUpperCase()}${substring(1)}';

  /// 检查是否为空或空白
  bool get isBlank => isEmpty || trim().isEmpty;

  /// 检查是否非空且非空白
  bool get isNotBlank => !isBlank;
}

/// int 扩展
extension IntX on int {
  /// 将毫秒转换为秒
  int get toSeconds => this ~/ 1000;

  /// 将秒转换为毫秒
  int get toMilliseconds => this * 1000;
}

/// DateTime 扩展
extension DateTimeX on DateTime {
  /// 格式化为中文日期字符串
  String toChineseDateString() {
    return '$year年${month.toString().padLeft(2, '0')}月${day.toString().padLeft(2, '0')}日';
  }
}
