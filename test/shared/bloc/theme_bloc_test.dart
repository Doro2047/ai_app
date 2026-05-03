import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_app/core/theme/app_theme.dart';
import 'package:ai_app/shared/bloc/theme_bloc.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ThemeBloc', () {
    test('initial state has defaultLight skin and light mode', () {
      final bloc = ThemeBloc();
      expect(bloc.state.isDarkMode, false);
      expect(bloc.state.currentSkin, SkinType.defaultLight);
      expect(bloc.state.currentMode, AppThemeMode.light);
      expect(bloc.state.skinConfig.name, 'default_light');
    });

    blocTest<ThemeBloc, ThemeState>(
      'ThemeToggled toggles isDarkMode from false to true',
      build: () => ThemeBloc(),
      act: (bloc) => bloc.add(const ThemeToggled()),
      verify: (bloc) {
        expect(bloc.state.isDarkMode, true);
        expect(bloc.state.currentSkin, SkinType.defaultLight);
        expect(bloc.state.currentMode, AppThemeMode.light);
      },
    );

    blocTest<ThemeBloc, ThemeState>(
      'ThemeToggled toggles isDarkMode from true to false',
      build: () => ThemeBloc(),
      seed: () => ThemeState(
        isDarkMode: true,
        currentSkin: SkinType.defaultLight,
        currentMode: AppThemeMode.dark,
        skinConfig: AppTheme.getSkinConfig(SkinType.defaultLight),
      ),
      act: (bloc) => bloc.add(const ThemeToggled()),
      verify: (bloc) {
        expect(bloc.state.isDarkMode, false);
      },
    );

    blocTest<ThemeBloc, ThemeState>(
      'ThemeToggled in system mode switches to specific mode',
      build: () => ThemeBloc(),
      seed: () => ThemeState(
        isDarkMode: false,
        currentSkin: SkinType.defaultLight,
        currentMode: AppThemeMode.system,
        skinConfig: AppTheme.getSkinConfig(SkinType.defaultLight),
      ),
      act: (bloc) => bloc.add(const ThemeToggled()),
      verify: (bloc) {
        expect(bloc.state.isDarkMode, true);
        expect(bloc.state.currentMode, AppThemeMode.dark);
      },
    );

    blocTest<ThemeBloc, ThemeState>(
      'SkinChanged updates currentSkin and skinConfig',
      build: () => ThemeBloc(),
      act: (bloc) => bloc.add(const SkinChanged(SkinType.classicBlue)),
      verify: (bloc) {
        expect(bloc.state.currentSkin, SkinType.classicBlue);
        expect(bloc.state.skinConfig.name, 'classic_blue');
      },
    );

    blocTest<ThemeBloc, ThemeState>(
      'SkinChanged to dark skin sets isDarkMode true',
      build: () => ThemeBloc(),
      act: (bloc) => bloc.add(const SkinChanged(SkinType.defaultDark)),
      verify: (bloc) {
        expect(bloc.state.currentSkin, SkinType.defaultDark);
        expect(bloc.state.isDarkMode, true);
        expect(bloc.state.skinConfig.isDark, true);
      },
    );

    blocTest<ThemeBloc, ThemeState>(
      'SkinChanged to light skin sets isDarkMode false',
      build: () => ThemeBloc(),
      seed: () => ThemeState(
        isDarkMode: true,
        currentSkin: SkinType.defaultDark,
        currentMode: AppThemeMode.dark,
        skinConfig: AppTheme.getSkinConfig(SkinType.defaultDark),
      ),
      act: (bloc) => bloc.add(const SkinChanged(SkinType.freshGreen)),
      verify: (bloc) {
        expect(bloc.state.currentSkin, SkinType.freshGreen);
        expect(bloc.state.isDarkMode, false);
        expect(bloc.state.skinConfig.isDark, false);
      },
    );

    blocTest<ThemeBloc, ThemeState>(
      'ModeChanged to dark sets isDarkMode true',
      build: () => ThemeBloc(),
      act: (bloc) => bloc.add(const ModeChanged(AppThemeMode.dark)),
      verify: (bloc) {
        expect(bloc.state.currentMode, AppThemeMode.dark);
        expect(bloc.state.isDarkMode, true);
      },
    );

    blocTest<ThemeBloc, ThemeState>(
      'ModeChanged to light sets isDarkMode false',
      build: () => ThemeBloc(),
      seed: () => ThemeState(
        isDarkMode: true,
        currentSkin: SkinType.defaultDark,
        currentMode: AppThemeMode.dark,
        skinConfig: AppTheme.getSkinConfig(SkinType.defaultDark),
      ),
      act: (bloc) => bloc.add(const ModeChanged(AppThemeMode.light)),
      verify: (bloc) {
        expect(bloc.state.currentMode, AppThemeMode.light);
        expect(bloc.state.isDarkMode, false);
      },
    );

    blocTest<ThemeBloc, ThemeState>(
      'ModeChanged to system keeps current isDarkMode',
      build: () => ThemeBloc(),
      act: (bloc) => bloc.add(const ModeChanged(AppThemeMode.system)),
      verify: (bloc) {
        expect(bloc.state.currentMode, AppThemeMode.system);
        expect(bloc.state.isDarkMode, false);
      },
    );

    blocTest<ThemeBloc, ThemeState>(
      'ThemeDataChanged with valid skin name updates skinConfig',
      build: () => ThemeBloc(),
      act: (bloc) => bloc.add(const ThemeDataChanged('classic_blue')),
      verify: (bloc) {
        expect(bloc.state.skinConfig.name, 'classic_blue');
        expect(bloc.state.isDarkMode, false);
      },
    );

    blocTest<ThemeBloc, ThemeState>(
      'ThemeDataChanged with invalid skin name does not change state',
      build: () => ThemeBloc(),
      act: (bloc) => bloc.add(const ThemeDataChanged('nonexistent_skin')),
      verify: (bloc) {
        expect(bloc.state.currentSkin, SkinType.defaultLight);
        expect(bloc.state.skinConfig.name, 'default_light');
      },
    );
  });
}
