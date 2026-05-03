/// 应用圆角系统
///
/// 定义统一的圆角令牌，确保界面元素圆角的一致性。
library;

/// 圆角设计令牌
///
/// 提供从 0 到全圆的圆角体系，用于卡片、按钮、输入框等组件。
class AppRadius {
  AppRadius._();

  /// none - 0px (直角、无圆角)
  static const double none = 0.0;

  /// xs - 2px (极小圆角)
  static const double xs = 2.0;

  /// sm - 4px (小圆角、按钮默认)
  static const double sm = 4.0;

  /// md - 6px (标准圆角、卡片、输入框)
  static const double md = 6.0;

  /// lg - 8px (大圆角、浮层、对话框)
  static const double lg = 8.0;

  /// xl - 12px (较大圆角、模态框)
  static const double xl = 12.0;

  /// xxl - 16px (大圆角、特殊卡片)
  static const double xxl = 16.0;

  /// full - 9999px (全圆角、圆形按钮、头像)
  static const double full = 9999.0;

  /// 获取圆角值数组
  static const List<double> values = [none, xs, sm, md, lg, xl, xxl, full];
}
