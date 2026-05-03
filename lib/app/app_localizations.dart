import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../l10n/app_localizations.dart';

export '../l10n/app_localizations.dart';

/// 本地化辅助方法
class LocalizationHelper {
  LocalizationHelper._();

  /// 获取当前本地化实例
  static AppLocalizations of(BuildContext context) {
    return AppLocalizations.of(context);
  }

  /// 支持的本地化列表
  static const List<Locale> supportedLocales = [
    Locale('zh'),
    Locale('en'),
  ];

  /// 本地化委托
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];
}
