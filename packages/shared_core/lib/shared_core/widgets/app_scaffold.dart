/// 应用脚手架组件
///
/// 提供应用级别的页面结构：Header、Content、StatusBar 和可选侧边栏。
/// 对应 Python CustomTkinter 的 BaseApp 组件。
library;

import 'package:flutter/material.dart';

import 'app_header.dart';
import 'app_status_bar.dart';

/// 应用脚手架组件
///
/// 包含 AppHeader、内容区域、可选侧边栏导航和 AppStatusBar。
/// 支持响应式布局。
class AppScaffold extends StatelessWidget {
  /// 页面标题
  final String title;

  /// 主内容区域
  final Widget body;

  /// 左侧 leading 组件
  final Widget? leading;

  /// 右侧附加操作按钮
  final List<Widget>? headerActions;

  /// 是否显示状态栏
  final bool showStatusBar;

  /// 状态栏配置
  final String statusBarText;
  final double statusBarProgress;
  final bool showStatusBarProgress;
  final String? statusBarExtraInfo;

  /// 侧边栏（Drawer）
  final Widget? drawer;

  /// 是否显示主题切换按钮
  final bool showThemeToggle;

  /// 是否显示皮肤选择按钮
  final bool showSkinPicker;

  /// 底部固定组件（如 FAB）
  final Widget? floatingActionButton;

  /// 底部导航栏
  final Widget? bottomNavigationBar;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.leading,
    this.headerActions,
    this.showStatusBar = true,
    this.statusBarText = '就绪',
    this.statusBarProgress = 0.0,
    this.showStatusBarProgress = true,
    this.statusBarExtraInfo,
    this.drawer,
    this.showThemeToggle = true,
    this.showSkinPicker = true,
    this.floatingActionButton,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        title: title,
        leading: leading,
        actions: headerActions,
        showThemeToggle: showThemeToggle,
        showSkinPicker: showSkinPicker,
      ),
      body: Column(
        children: [
          Expanded(child: body),
          if (showStatusBar)
            AppStatusBar(
              statusText: statusBarText,
              progress: statusBarProgress,
              showProgress: showStatusBarProgress,
              extraInfo: statusBarExtraInfo,
            ),
        ],
      ),
      drawer: drawer,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

/// 响应式布局助手组件
///
/// 根据屏幕宽度自动调整布局，适用于平板和桌面设备。
class ResponsiveLayout extends StatelessWidget {
  /// 移动端布局
  final Widget mobile;

  /// 平板布局
  final Widget? tablet;

  /// 桌面布局
  final Widget? desktop;

  /// 平板断点宽度
  final double tabletBreakpoint;

  /// 桌面断点宽度
  final double desktopBreakpoint;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.tabletBreakpoint = 600,
    this.desktopBreakpoint = 1024,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (width >= desktopBreakpoint && desktop != null) {
          return desktop!;
        } else if (width >= tabletBreakpoint && tablet != null) {
          return tablet!;
        } else {
          return mobile;
        }
      },
    );
  }
}
