/// 应用间距系统
///
/// 定义统一的间距令牌，确保界面元素间距的一致性和节奏感。
library;

/// 间距设计令牌
///
/// 提供 7 级间距体系，从 4px 到 32px，
/// 用于组件内边距、外边距、元素间隔等场景。
class AppSpacing {
  AppSpacing._();

  /// xxs - 2px (极小间距、图标与文字间距)
  static const double xxs = 2.0;

  /// xs - 4px (紧凑间距、内联元素间隔)
  static const double xs = 4.0;

  /// sm - 8px (小间距、表单元素间距)
  static const double sm = 8.0;

  /// md - 12px (标准间距、卡片内边距)
  static const double md = 12.0;

  /// lg - 16px (大间距、section 间距)
  static const double lg = 16.0;

  /// xl - 20px (较大间距、区块间距)
  static const double xl = 20.0;

  /// xxl - 24px (大区块间距)
  static const double xxl = 24.0;

  /// xxxl - 32px (超大间距、页面级间距)
  static const double xxxl = 32.0;

  /// 获取间距值数组
  static const List<double> values = [xxs, xs, sm, md, lg, xl, xxl, xxxl];
}
