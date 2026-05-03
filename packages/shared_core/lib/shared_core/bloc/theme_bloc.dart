/// 主题 BLoC 状态管理
///
/// 使用 flutter_bloc 和 hive 实现主题状态管理，支持：
/// - 主题切换（亮色/暗色）
/// - 皮肤选择（7种预设皮肤）
/// - 模式切换（亮色/暗色/跟随系统）
/// - 主题偏好持久化（使用 Hive 存储）
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../theme/app_theme.dart';

// ============================================================
// 事件定义
// ============================================================

/// 主题事件基类
@immutable
abstract class ThemeEvent {
  const ThemeEvent();
}

/// 切换主题事件（亮色 <-> 暗色）
class ThemeToggled extends ThemeEvent {
  const ThemeToggled();
}

/// 皮肤改变事件
class SkinChanged extends ThemeEvent {
  /// 皮肤类型
  final SkinType skinType;

  const SkinChanged(this.skinType);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SkinChanged && other.skinType == skinType;
  }

  @override
  int get hashCode => skinType.hashCode;
}

/// 模式改变事件（亮色/暗色/跟随系统）
class ModeChanged extends ThemeEvent {
  /// 主题模式
  final AppThemeMode mode;

  const ModeChanged(this.mode);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ModeChanged && other.mode == mode;
  }

  @override
  int get hashCode => mode.hashCode;
}

/// 主题初始化事件
class ThemeInitialized extends ThemeEvent {
  const ThemeInitialized();
}

/// 主题数据改变事件（用于手动设置 ThemeData）
class ThemeDataChanged extends ThemeEvent {
  /// 皮肤名称
  final String skinName;

  const ThemeDataChanged(this.skinName);
}

// ============================================================
// 状态定义
// ============================================================

/// 主题状态
@immutable
class ThemeState {
  /// 是否为暗色模式
  final bool isDarkMode;

  /// 当前皮肤类型
  final SkinType currentSkin;

  /// 当前主题模式
  final AppThemeMode currentMode;

  /// 当前皮肤配置
  final SkinConfig skinConfig;

  const ThemeState({
    this.isDarkMode = false,
    this.currentSkin = SkinType.defaultLight,
    this.currentMode = AppThemeMode.light,
    required this.skinConfig,
  });

  /// 创建初始状态
  factory ThemeState.initial(SkinConfig initialConfig) {
    return ThemeState(
      isDarkMode: initialConfig.isDark,
      currentSkin: SkinType.defaultLight,
      currentMode: AppThemeMode.light,
      skinConfig: initialConfig,
    );
  }

  /// 复制状态并更新指定字段
  ThemeState copyWith({
    bool? isDarkMode,
    SkinType? currentSkin,
    AppThemeMode? currentMode,
    SkinConfig? skinConfig,
  }) {
    return ThemeState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      currentSkin: currentSkin ?? this.currentSkin,
      currentMode: currentMode ?? this.currentMode,
      skinConfig: skinConfig ?? this.skinConfig,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ThemeState &&
        other.isDarkMode == isDarkMode &&
        other.currentSkin == currentSkin &&
        other.currentMode == currentMode &&
        other.skinConfig.name == skinConfig.name;
  }

  @override
  int get hashCode {
    return Object.hash(
      isDarkMode,
      currentSkin,
      currentMode,
      skinConfig.name,
    );
  }

  @override
  String toString() {
    return 'ThemeState(isDarkMode: $isDarkMode, currentSkin: $currentSkin, '
        'currentMode: $currentMode, skinName: ${skinConfig.name})';
  }
}

// ============================================================
// BLoC 定义
// ============================================================

/// Hive Box 名称
const String _themeBoxName = 'theme_box';

/// Hive 存储键名
class _ThemeStorageKeys {
  static const String isDarkMode = 'is_dark_mode';
  static const String currentSkin = 'current_skin';
  static const String currentMode = 'current_mode';
}

/// 主题 BLoC
///
/// 管理应用程序的主题状态，包括：
/// - 亮色/暗色模式切换
/// - 皮肤选择和切换
/// - 系统主题模式支持
/// - 主题偏好持久化
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  /// Hive Box 实例
  late Box _themeBox;

  /// 是否已初始化
  bool _isInitialized = false;

  ThemeBloc() : super(_createInitialState()) {
    on<ThemeInitialized>(_onInitialized);
    on<ThemeToggled>(_onToggled);
    on<SkinChanged>(_onSkinChanged);
    on<ModeChanged>(_onModeChanged);
    on<ThemeDataChanged>(_onThemeDataChanged);
  }

  /// 创建初始状态（在初始化事件触发前使用默认值）
  static ThemeState _createInitialState() {
    final defaultConfig = AppTheme.getSkinConfig(SkinType.defaultLight);
    return ThemeState.initial(defaultConfig);
  }

  /// 初始化 BLoC
  Future<void> init() async {
    try {
      // 初始化 Hive
      if (!Hive.isAdapterRegistered(0)) {
        await Hive.initFlutter();
      }

      // 打开主题存储 Box
      _themeBox = await Hive.openBox(_themeBoxName);

      // 触发初始化事件
      add(const ThemeInitialized());
    } catch (e) {
      debugPrint('ThemeBloc init failed: $e');
      // 使用默认状态
      _isInitialized = true;
    }
  }

  /// 关闭 BLoC
  @override
  Future<void> close() async {
    try {
      await _themeBox.close();
    } catch (e) {
      debugPrint('ThemeBloc close failed: $e');
    }
    return super.close();
  }

  // ============================================================
  // 事件处理
  // ============================================================

  /// 处理主题初始化事件
  Future<void> _onInitialized(
    ThemeInitialized event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      // 从 Hive 读取存储的主题偏好
      final savedIsDarkMode = _themeBox.get(
        _ThemeStorageKeys.isDarkMode,
        defaultValue: false,
      ) as bool;
      final savedSkinName = _themeBox.get(
        _ThemeStorageKeys.currentSkin,
        defaultValue: SkinType.defaultLight.name,
      ) as String;
      final savedModeIndex = _themeBox.get(
        _ThemeStorageKeys.currentMode,
        defaultValue: AppThemeMode.light.index,
      ) as int;

      // 恢复皮肤类型
      final savedSkin = _getSkinTypeByName(savedSkinName) ?? SkinType.defaultLight;

      // 恢复主题模式
      final savedMode = AppThemeMode.values[savedModeIndex.clamp(
        0,
        AppThemeMode.values.length - 1,
      )];

      // 获取皮肤配置
      final skinConfig = AppTheme.getSkinConfig(savedSkin);

      // 根据模式决定实际的亮暗状态
      final isDarkMode = _resolveDarkMode(savedMode, savedIsDarkMode);

      emit(ThemeState(
        isDarkMode: isDarkMode,
        currentSkin: savedSkin,
        currentMode: savedMode,
        skinConfig: skinConfig,
      ));

      _isInitialized = true;
      debugPrint('ThemeBloc initialized: mode=$savedMode, skin=$savedSkinName, isDark=$isDarkMode');
    } catch (e) {
      debugPrint('ThemeBloc initialization failed: $e');
      // 使用默认状态
      emit(_createInitialState());
      _isInitialized = true;
    }
  }

  /// 处理主题切换事件
  void _onToggled(
    ThemeToggled event,
    Emitter<ThemeState> emit,
  ) {
    final newState = state.copyWith(
      isDarkMode: !state.isDarkMode,
    );

    // 如果当前是跟随系统模式，切换到具体模式
    if (state.currentMode == AppThemeMode.system) {
      final newMode = state.isDarkMode ? AppThemeMode.light : AppThemeMode.dark;
      emit(newState.copyWith(currentMode: newMode));
      _saveMode(newMode);
    } else {
      emit(newState);
    }

    _saveDarkMode(newState.isDarkMode);
    _saveSkinConfig(newState.skinConfig);
    debugPrint('Theme toggled: isDark=${newState.isDarkMode}');
  }

  /// 处理皮肤改变事件
  void _onSkinChanged(
    SkinChanged event,
    Emitter<ThemeState> emit,
  ) {
    final skinConfig = AppTheme.getSkinConfig(event.skinType);

    emit(state.copyWith(
      currentSkin: event.skinType,
      skinConfig: skinConfig,
      isDarkMode: skinConfig.isDark,
    ));

    _saveSkin(event.skinType);
    _saveDarkMode(skinConfig.isDark);
    debugPrint('Skin changed: ${event.skinType.name}');
  }

  /// 处理模式改变事件
  void _onModeChanged(
    ModeChanged event,
    Emitter<ThemeState> emit,
  ) {
    final isDarkMode = _resolveDarkMode(event.mode, state.isDarkMode);

    emit(state.copyWith(
      currentMode: event.mode,
      isDarkMode: isDarkMode,
    ));

    _saveMode(event.mode);
    debugPrint('Mode changed: ${event.mode.name}, isDark=$isDarkMode');
  }

  /// 处理主题数据改变事件
  void _onThemeDataChanged(
    ThemeDataChanged event,
    Emitter<ThemeState> emit,
  ) {
    final skinConfig = AppTheme.getSkinConfigByName(event.skinName);
    if (skinConfig != null) {
      final skinType = _getSkinTypeByName(event.skinName) ?? state.currentSkin;

      emit(state.copyWith(
        currentSkin: skinType,
        skinConfig: skinConfig,
        isDarkMode: skinConfig.isDark,
      ));

      _saveSkin(skinType);
      _saveDarkMode(skinConfig.isDark);
      debugPrint('Theme data changed: ${event.skinName}');
    }
  }

  // ============================================================
  // 辅助方法
  // ============================================================

  /// 根据模式解析实际的亮暗状态
  bool _resolveDarkMode(AppThemeMode mode, bool currentIsDark) {
    switch (mode) {
      case AppThemeMode.light:
        return false;
      case AppThemeMode.dark:
        return true;
      case AppThemeMode.system:
        // 在实际应用中，这里应该读取系统主题设置
        // 暂时保持当前状态
        return currentIsDark;
    }
  }

  /// 根据名称获取皮肤类型
  SkinType? _getSkinTypeByName(String name) {
    try {
      return SkinType.values.firstWhere((type) => type.name == name);
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // 持久化存储
  // ============================================================

  /// 保存亮暗模式偏好
  void _saveDarkMode(bool isDark) {
    try {
      _themeBox.put(_ThemeStorageKeys.isDarkMode, isDark);
    } catch (e) {
      debugPrint('Failed to save dark mode: $e');
    }
  }

  /// 保存皮肤类型偏好
  void _saveSkin(SkinType skin) {
    try {
      _themeBox.put(_ThemeStorageKeys.currentSkin, skin.name);
    } catch (e) {
      debugPrint('Failed to save skin: $e');
    }
  }

  /// 保存主题模式偏好
  void _saveMode(AppThemeMode mode) {
    try {
      _themeBox.put(_ThemeStorageKeys.currentMode, mode.index);
    } catch (e) {
      debugPrint('Failed to save mode: $e');
    }
  }

  /// 保存皮肤配置（用于同步亮暗状态）
  void _saveSkinConfig(SkinConfig config) {
    // 亮暗状态和皮肤类型已经在其他方法中保存
    // 这里保留扩展点
  }

  // ============================================================
  // 公共属性
  // ============================================================

  /// 是否已初始化
  bool get isInitialized => _isInitialized;

  /// 获取所有可用皮肤列表
  List<SkinConfig> get availableSkins => AppTheme.allSkins;

  /// 获取当前 ThemeData
  ThemeData get currentThemeData => AppTheme.buildThemeData(state.currentSkin);
}
