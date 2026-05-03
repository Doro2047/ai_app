/// 语言区域 BLoC 状态管理
///
/// 使用 flutter_bloc 和 hive 实现语言区域状态管理，支持：
/// - 运行时语言切换（中文/英文）
/// - 语言偏好持久化（使用 Hive 存储）
/// - 跟随系统语言设置
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

// ============================================================
// 事件定义
// ============================================================

/// 语言区域事件基类
@immutable
abstract class LocaleEvent {
  const LocaleEvent();
}

/// 语言初始化事件
class LocaleInitialized extends LocaleEvent {
  const LocaleInitialized();
}

/// 语言切换事件
class LocaleChanged extends LocaleEvent {
  /// 目标语言区域
  final Locale locale;

  const LocaleChanged(this.locale);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocaleChanged &&
        other.locale.languageCode == locale.languageCode;
  }

  @override
  int get hashCode => locale.languageCode.hashCode;
}

// ============================================================
// 状态定义
// ============================================================

/// 语言区域状态
@immutable
class LocaleState {
  /// 当前语言区域
  final Locale locale;

  /// 支持的语言区域列表
  static const List<Locale> supportedLocales = [
    Locale('zh'),
    Locale('en'),
  ];

  const LocaleState({this.locale = const Locale('zh')});

  /// 复制状态并更新指定字段
  LocaleState copyWith({Locale? locale}) {
    return LocaleState(locale: locale ?? this.locale);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocaleState &&
        other.locale.languageCode == locale.languageCode;
  }

  @override
  int get hashCode => locale.languageCode.hashCode;

  @override
  String toString() => 'LocaleState(locale: ${locale.languageCode})';
}

// ============================================================
// BLoC 定义
// ============================================================

/// Hive Box 名称
const String _localeBoxName = 'locale_box';

/// Hive 存储键名
class _LocaleStorageKeys {
  static const String languageCode = 'language_code';
}

/// 语言区域 BLoC
///
/// 管理应用程序的语言区域状态，包括：
/// - 运行时语言切换
/// - 语言偏好持久化
/// - 从 Hive 恢复上次选择的语言
class LocaleBloc extends Bloc<LocaleEvent, LocaleState> {
  /// Hive Box 实例
  late Box _localeBox;

  /// 是否已初始化
  bool _isInitialized = false;

  LocaleBloc() : super(const LocaleState()) {
    on<LocaleInitialized>(_onInitialized);
    on<LocaleChanged>(_onChanged);
  }

  /// 初始化 BLoC
  Future<void> init() async {
    try {
      // 初始化 Hive
      if (!Hive.isAdapterRegistered(0)) {
        await Hive.initFlutter();
      }

      // 打开语言区域存储 Box
      _localeBox = await Hive.openBox(_localeBoxName);

      // 触发初始化事件
      add(const LocaleInitialized());
    } catch (e) {
      debugPrint('LocaleBloc init failed: $e');
      _isInitialized = true;
    }
  }

  /// 关闭 BLoC
  @override
  Future<void> close() async {
    try {
      await _localeBox.close();
    } catch (e) {
      debugPrint('LocaleBloc close failed: $e');
    }
    return super.close();
  }

  // ============================================================
  // 事件处理
  // ============================================================

  /// 处理语言初始化事件
  Future<void> _onInitialized(
    LocaleInitialized event,
    Emitter<LocaleState> emit,
  ) async {
    try {
      // 从 Hive 读取存储的语言偏好
      final savedLanguageCode = _localeBox.get(
        _LocaleStorageKeys.languageCode,
      ) as String?;

      if (savedLanguageCode != null) {
        // 恢复保存的语言
        final savedLocale = _getLocaleByCode(savedLanguageCode);
        emit(LocaleState(locale: savedLocale));
        debugPrint('LocaleBloc initialized: locale=$savedLanguageCode');
      } else {
        // 首次使用，尝试使用系统语言
        final systemLocale = _getSystemLocale();
        emit(LocaleState(locale: systemLocale));
        debugPrint('LocaleBloc initialized with system locale: ${systemLocale.languageCode}');
      }

      _isInitialized = true;
    } catch (e) {
      debugPrint('LocaleBloc initialization failed: $e');
      emit(const LocaleState());
      _isInitialized = true;
    }
  }

  /// 处理语言切换事件
  void _onChanged(
    LocaleChanged event,
    Emitter<LocaleState> emit,
  ) {
    emit(LocaleState(locale: event.locale));
    _saveLanguageCode(event.locale.languageCode);
    debugPrint('Locale changed: ${event.locale.languageCode}');
  }

  // ============================================================
  // 辅助方法
  // ============================================================

  /// 根据语言代码获取 Locale
  Locale _getLocaleByCode(String code) {
    // 检查是否在支持列表中
    for (final supported in LocaleState.supportedLocales) {
      if (supported.languageCode == code) {
        return supported;
      }
    }
    // 不支持的语言默认返回中文
    return const Locale('zh');
  }

  /// 获取系统语言区域
  Locale _getSystemLocale() {
    // 尝试从平台获取系统语言
    try {
      final systemLocales = WidgetsBinding.instance.platformDispatcher.locales;
      if (systemLocales.isNotEmpty) {
        // 查找系统语言是否在支持列表中
        for (final systemLocale in systemLocales) {
          for (final supported in LocaleState.supportedLocales) {
            if (supported.languageCode == systemLocale.languageCode) {
              return supported;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Failed to get system locale: $e');
    }
    // 默认中文
    return const Locale('zh');
  }

  // ============================================================
  // 持久化存储
  // ============================================================

  /// 保存语言代码偏好
  void _saveLanguageCode(String code) {
    try {
      _localeBox.put(_LocaleStorageKeys.languageCode, code);
    } catch (e) {
      debugPrint('Failed to save language code: $e');
    }
  }

  // ============================================================
  // 公共属性
  // ============================================================

  /// 是否已初始化
  bool get isInitialized => _isInitialized;

  /// 获取当前语言代码
  String get currentLanguageCode => state.locale.languageCode;

  /// 是否为中文
  bool get isZh => state.locale.languageCode == 'zh';

  /// 是否为英文
  bool get isEn => state.locale.languageCode == 'en';
}
