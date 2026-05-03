/// 应用字体排印系统
///
/// 定义 8 级字体体系（10px-36px），包含字体族、字重、行高等排版属性。
/// 使用系统原生字体栈，确保跨平台一致性。
library;

import 'package:flutter/material.dart';

/// 字体排版设计令牌
///
/// 提供 8 级字体尺寸体系以及字体族、行高、字重等排版属性。
/// 支持根据 DPI 自动缩放。
class AppTypography {
  AppTypography._();

  // ============================================================
  // 字体族
  // ============================================================

  /// Windows 系统字体
  static const String _windowsFont = 'Segoe UI';

  /// macOS 系统字体
  static const String _macOSFont = '.AppleSystemUIFont';

  /// Linux 系统字体
  static const String _linuxFont = 'Ubuntu';

  /// 中文字体
  static const String _chineseFont = 'Microsoft YaHei UI';

  /// 中文字体（macOS）
  static const String _chineseFontMacOS = 'PingFang SC';

  /// 等宽字体
  static const String monoFont = 'Consolas';

  /// 主要字体族（带中文回退）
  static const String fontFamily = _chineseFont;

  /// 主要字体族（macOS）
  static const String fontFamilyMacOS = _chineseFontMacOS;

  /// 等宽字体族
  static const String fontFamilyMono = monoFont;

  // ============================================================
  // 8 级字体尺寸体系
  // ============================================================

  /// small2 - 10px (极小辅助文字、角标)
  static const double small2Size = 10.0;

  /// small - 12px (辅助文字、标签、说明)
  static const double smallSize = 12.0;

  /// regular - 14px (正文、默认字号)
  static const double regularSize = 14.0;

  /// medium - 16px (强调正文、次要标题)
  static const double mediumSize = 16.0;

  /// title1 - 18px (小标题、分区标题)
  static const double title1Size = 18.0;

  /// title2 - 20px (中标题)
  static const double title2Size = 20.0;

  /// title3 - 24px (大标题、页面标题)
  static const double title3Size = 24.0;

  /// title4 - 36px (超大标题、英雄文字)
  static const double title4Size = 36.0;

  // ============================================================
  // 图标尺寸
  // ============================================================

  /// 标准图标尺寸
  static const double iconSize = 24.0;

  /// 大图标尺寸
  static const double iconSizeLarge = 28.0;

  /// 超大图标尺寸
  static const double iconSizeExtraLarge = 36.0;

  // ============================================================
  // 行高
  // ============================================================

  /// 紧凑行高 - 1.3 (标题、按钮)
  static const double lineHeightTight = 1.3;

  /// 标准行高 - 1.5 (正文)
  static const double lineHeightNormal = 1.5;

  /// 宽松行高 - 1.6 (长文本、描述)
  static const double lineHeightRelaxed = 1.6;

  // ============================================================
  // TextStyle 预设
  // ============================================================

  /// 创建 TextStyle 的辅助方法
  static TextStyle _createTextStyle({
    required double fontSize,
    FontWeight fontWeight = FontWeight.normal,
    double height = lineHeightNormal,
    String? fontFamily,
    Color? color,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      fontFamily: fontFamily ?? AppTypography.fontFamily,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  /// small2 样式 - 10px
  static TextStyle get small2 => _createTextStyle(
        fontSize: small2Size,
        height: lineHeightTight,
      );

  /// small2 Bold 样式
  static TextStyle get small2Bold => small2.copyWith(
        fontWeight: FontWeight.bold,
      );

  /// small 样式 - 12px
  static TextStyle get small => _createTextStyle(
        fontSize: smallSize,
        height: lineHeightTight,
      );

  /// small Bold 样式
  static TextStyle get smallBold => small.copyWith(
        fontWeight: FontWeight.bold,
      );

  /// regular 样式 - 14px (正文默认)
  static TextStyle get regular => _createTextStyle(
        fontSize: regularSize,
        height: lineHeightNormal,
      );

  /// regular Bold 样式
  static TextStyle get regularBold => regular.copyWith(
        fontWeight: FontWeight.bold,
      );

  /// medium 样式 - 16px
  static TextStyle get medium => _createTextStyle(
        fontSize: mediumSize,
        height: lineHeightNormal,
      );

  /// medium Bold 样式
  static TextStyle get mediumBold => medium.copyWith(
        fontWeight: FontWeight.bold,
      );

  /// title1 样式 - 18px
  static TextStyle get title1 => _createTextStyle(
        fontSize: title1Size,
        fontWeight: FontWeight.w600,
        height: lineHeightTight,
      );

  /// title2 样式 - 20px
  static TextStyle get title2 => _createTextStyle(
        fontSize: title2Size,
        fontWeight: FontWeight.w600,
        height: lineHeightTight,
      );

  /// title3 样式 - 24px
  static TextStyle get title3 => _createTextStyle(
        fontSize: title3Size,
        fontWeight: FontWeight.bold,
        height: lineHeightTight,
        letterSpacing: -0.5,
      );

  /// title4 样式 - 36px
  static TextStyle get title4 => _createTextStyle(
        fontSize: title4Size,
        fontWeight: FontWeight.bold,
        height: lineHeightTight,
        letterSpacing: -1.0,
      );

  // ============================================================
  // 等宽字体样式
  // ============================================================

  /// 等宽字体 small 样式
  static TextStyle get monoSmall => small.copyWith(
        fontFamily: fontFamilyMono,
      );

  /// 等宽字体 regular 样式
  static TextStyle get monoRegular => regular.copyWith(
        fontFamily: fontFamilyMono,
      );

  /// 等宽字体 medium 样式
  static TextStyle get monoMedium => medium.copyWith(
        fontFamily: fontFamilyMono,
      );

  // ============================================================
  // 缩放支持
  // ============================================================

  /// 默认缩放因子
  static const double defaultScaleFactor = 1.0;

  /// 根据缩放因子计算字体大小
  static double scaleFontSize(double baseSize, double scaleFactor) {
    return baseSize * scaleFactor;
  }

  /// 根据 DPI 推荐缩放因子
  static double scaleFactorForDpi(double dpi) {
    if (dpi <= 96) return 1.0;
    if (dpi <= 120) return 1.1;
    if (dpi <= 144) return 1.2;
    if (dpi <= 168) return 1.35;
    return 1.5;
  }
}
