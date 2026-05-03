import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/theme/app_theme.dart';
import '../core/constants/app_constants.dart';
import '../shared/bloc/theme_bloc.dart';
import '../shared/bloc/locale_bloc.dart';
import 'routes/app_router.dart';
import 'app_localizations.dart';
import 'app_di.dart';

/// 应用根 Widget
class AiApp extends StatelessWidget {
  /// 初始路由（支持命令行参数传入，实现工具独立启动）
  final String initialRoute;

  const AiApp({super.key, this.initialRoute = AppRoutes.home});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeBloc>(
          create: (_) => getIt<ThemeBloc>(),
        ),
        BlocProvider<LocaleBloc>(
          create: (_) => getIt<LocaleBloc>(),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return BlocBuilder<LocaleBloc, LocaleState>(
            builder: (context, localeState) {
              final themeData = AppTheme.buildThemeData(themeState.currentSkin);
              final themeMode = _resolveThemeMode(themeState.currentMode);

              return MaterialApp.router(
                title: AppConstants.appName,
                debugShowCheckedModeBanner: false,
                theme: themeData,
                themeMode: themeMode,
                routerConfig: AppRouter.createRouter(initialLocation: initialRoute),
                locale: localeState.locale,
                localizationsDelegates: LocalizationHelper.localizationsDelegates,
                supportedLocales: LocalizationHelper.supportedLocales,
              );
            },
          );
        },
      ),
    );
  }

  ThemeMode _resolveThemeMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}
