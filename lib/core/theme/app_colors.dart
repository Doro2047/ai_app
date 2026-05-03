/// 应用颜色常量定义
///
/// 定义所有颜色常量，使用亮色/暗色双值格式。
/// 通过 ThemeData 的 ColorScheme 来管理颜色。
library;

import 'package:flutter/material.dart';

/// 设计令牌 - 语义化颜色定义
///
/// 每个颜色包含亮色和暗色两个值，用于在不同模式下提供合适的视觉效果。
class AppColors {
  AppColors._();

  // ============================================================
  // 背景色
  // ============================================================

  /// 主背景色
  static const Color bgPrimaryLight = Color(0xFFFFFFFF);
  static const Color bgPrimaryDark = Color(0xFF0F172A);

  /// 次背景色（面板、侧栏）
  static const Color bgSecondaryLight = Color(0xFFF8FAFC);
  static const Color bgSecondaryDark = Color(0xFF1E293B);

  /// 第三背景色（标签页、分段控件）
  static const Color bgTertiaryLight = Color(0xFFE2E8F0);
  static const Color bgTertiaryDark = Color(0xFF334155);

  /// 卡片背景色
  static const Color cardBgLight = Color(0xFFFFFFFF);
  static const Color cardBgDark = Color(0xFF1E293B);

  /// 卡片悬停色
  static const Color cardHoverLight = Color(0xFFEFF6FF);
  static const Color cardHoverDark = Color(0xFF334155);

  /// 侧边栏背景色
  static const Color sidebarBgLight = Color(0xFFF8FAFC);
  static const Color sidebarBgDark = Color(0xFF1A2332);

  /// 顶部栏背景色
  static const Color headerBgLight = Color(0xFFFFFFFF);
  static const Color headerBgDark = Color(0xFF0F172A);

  /// 状态栏背景色
  static const Color statusBarBgLight = Color(0xFFF8FAFC);
  static const Color statusBarBgDark = Color(0xFF1E293B);

  // ============================================================
  // 文本色
  // ============================================================

  /// 主文本色（标题、正文）
  static const Color textPrimaryLight = Color(0xFF1F2937);
  static const Color textPrimaryDark = Color(0xFFF1F5F9);

  /// 次文本色（描述、辅助文字）
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  /// 禁用文本色
  static const Color textDisabledLight = Color(0xFF9CA3AF);
  static const Color textDisabledDark = Color(0xFF64748B);

  // ============================================================
  // 强调色/品牌色
  // ============================================================

  /// 强调色（链接、选中态）
  static const Color accentLight = Color(0xFF3B82F6);
  static const Color accentDark = Color(0xFF60A5FA);

  /// 强调色悬停
  static const Color accentHoverLight = Color(0xFF2563EB);
  static const Color accentHoverDark = Color(0xFF3B82F6);

  /// 强调色浅色变体
  static const Color accentLightVariant = Color(0xFF93C5FD);
  static const Color accentDarkVariant = Color(0xFF93C5FD);

  // ============================================================
  // 按钮色
  // ============================================================

  /// 主按钮背景
  static const Color buttonPrimaryBgLight = Color(0xFF3B82F6);
  static const Color buttonPrimaryBgDark = Color(0xFF3B82F6);

  /// 主按钮悬停
  static const Color buttonPrimaryHoverLight = Color(0xFF2563EB);
  static const Color buttonPrimaryHoverDark = Color(0xFF2563EB);

  /// 主按钮文本
  static const Color buttonPrimaryTextLight = Color(0xFFFFFFFF);
  static const Color buttonPrimaryTextDark = Color(0xFFFFFFFF);

  /// 次按钮背景
  static const Color buttonSecondaryBgLight = Color(0xFFF8FAFC);
  static const Color buttonSecondaryBgDark = Color(0xFF1E293B);

  /// 次按钮悬停
  static const Color buttonSecondaryHoverLight = Color(0xFFE2E8F0);
  static const Color buttonSecondaryHoverDark = Color(0xFF334155);

  /// 次按钮文本
  static const Color buttonSecondaryTextLight = Color(0xFF1F2937);
  static const Color buttonSecondaryTextDark = Color(0xFFF1F5F9);

  // ============================================================
  // 输入框
  // ============================================================

  /// 输入框背景
  static const Color inputBgLight = Color(0xFFF8FAFC);
  static const Color inputBgDark = Color(0xFF1E293B);

  /// 输入框聚焦环
  static const Color inputFocusRingLight = Color(0xFF93C5FD);
  static const Color inputFocusRingDark = Color(0xFF93C5FD);

  // ============================================================
  // 边框
  // ============================================================

  /// 标准边框
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color borderDark = Color(0xFF475569);

  /// 浅色边框
  static const Color borderLightVariant = Color(0xFFF3F4F6);
  static const Color borderDarkVariant = Color(0xFF64748B);

  // ============================================================
  // 状态色
  // ============================================================

  /// 错误/危险
  static const Color errorLight = Color(0xFFEF4444);
  static const Color errorDark = Color(0xFFF87171);

  /// 成功/确认
  static const Color successLight = Color(0xFF10B981);
  static const Color successDark = Color(0xFF34D399);

  /// 警告/注意
  static const Color warningLight = Color(0xFFF59E0B);
  static const Color warningDark = Color(0xFFFBBF24);

  /// 信息/提示
  static const Color infoLight = Color(0xFF0EA5E9);
  static const Color infoDark = Color(0xFF60A5FA);

  // ============================================================
  // 滚动条
  // ============================================================

  /// 滚动条轨道
  static const Color scrollbarBgLight = Color(0xFFF1F5F9);
  static const Color scrollbarBgDark = Color(0xFF1A2332);

  /// 滚动条滑块
  static const Color scrollbarHandleLight = Color(0xFFCBD5E1);
  static const Color scrollbarHandleDark = Color(0xFF475569);

  // ============================================================
  // 工具方法
  // ============================================================

  /// 根据是否为暗色模式获取对应的颜色
  static Color resolve(Color light, Color dark, bool isDark) {
    return isDark ? dark : light;
  }

  /// 将十六进制颜色字符串转换为 Color 对象
  static Color fromHex(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }

  /// 创建亮色/暗色双值颜色对象
  static ColorPair createColorPair({required Color light, required Color dark}) {
    return ColorPair(light: light, dark: dark);
  }
}

/// 亮色/暗色双值颜色容器
///
/// 用于在不同主题模式下自动选择合适的颜色。
class ColorPair {
  /// 亮色模式下的颜色
  final Color light;

  /// 暗色模式下的颜色
  final Color dark;

  const ColorPair({required this.light, required this.dark});

  /// 根据是否为暗色模式获取对应的颜色
  Color resolve(bool isDark) => isDark ? dark : light;
}
