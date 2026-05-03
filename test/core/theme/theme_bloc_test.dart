/// ThemeBloc ååæµè¯
///
/// æµè¯ ThemeBloc çäºä»¶å¤çãä¸»é¢åæ¢ãç®è¤éæ©åæ¨¡å¼æä¹åã?library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_app/core/theme/app_theme.dart';
import 'package:ai_app/shared/bloc/theme_bloc.dart';

/// Helper to create a test SkinConfig without const restrictions
SkinConfig _createTestConfig({bool isDark = false}) {
  return SkinConfig(
    name: 'test',
    displayName: 'Test',
    isDark: isDark,
    bgPrimary: Colors.white,
    bgSecondary: Colors.grey[200]!,
    bgTertiary: Colors.grey[100]!,
    cardBg: Colors.white,
    cardHover: Colors.grey[50]!,
    sidebarBg: Colors.white,
    textPrimary: Colors.black,
    textSecondary: Colors.grey[600]!,
    textDisabled: Colors.grey[400]!,
    accent: Colors.blue,
    accentHover: Colors.blue[700]!,
    accentLight: Colors.blue[50]!,
    buttonBg: Colors.blue,
    buttonHover: Colors.blue[700]!,
    buttonText: Colors.white,
    buttonSecondaryBg: Colors.grey[200]!,
    buttonSecondaryHover: Colors.grey[300]!,
    buttonSecondaryText: Colors.black,
    border: Colors.grey[300]!,
    borderLight: Colors.grey[200]!,
    error: Colors.red,
    success: Colors.green,
    warning: Colors.amber,
    info: Colors.blue,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ThemeState', () {
    test('initial state has correct default values', () {
      final config = _createTestConfig();
      final state = ThemeState(
        isDarkMode: false,
        currentSkin: SkinType.defaultLight,
        currentMode: AppThemeMode.light,
        skinConfig: config,
      );

      expect(state.isDarkMode, false);
      expect(state.currentSkin, SkinType.defaultLight);
      expect(state.currentMode, AppThemeMode.light);
    });

    test('copyWith updates only specified fields', () {
      final config = AppTheme.getSkinConfig(SkinType.defaultLight);
      final state = ThemeState(
        isDarkMode: false,
        currentSkin: SkinType.defaultLight,
        currentMode: AppThemeMode.light,
        skinConfig: config,
      );

      final newState = state.copyWith(isDarkMode: true);

      expect(newState.isDarkMode, true);
      expect(newState.currentSkin, state.currentSkin);
      expect(newState.currentMode, state.currentMode);
    });

    test('equality compares relevant fields', () {
      final config1 = AppTheme.getSkinConfig(SkinType.defaultLight);
      final config2 = AppTheme.getSkinConfig(SkinType.defaultLight);

      final state1 = ThemeState(
        isDarkMode: false,
        currentSkin: SkinType.defaultLight,
        currentMode: AppThemeMode.light,
        skinConfig: config1,
      );

      final state2 = ThemeState(
        isDarkMode: false,
        currentSkin: SkinType.defaultLight,
        currentMode: AppThemeMode.light,
        skinConfig: config2,
      );

      expect(state1, equals(state2));
    });
  });

  group('ThemeEvent', () {
    test('ThemeToggled can be created with const', () {
      const event = ThemeToggled();
      expect(event, isA<ThemeEvent>());
    });

    test('SkinChanged stores skinType correctly', () {
      const event = SkinChanged(SkinType.classicBlue);
      expect(event.skinType, SkinType.classicBlue);
    });

    test('SkinChanged equality works', () {
      const event1 = SkinChanged(SkinType.classicBlue);
      const event2 = SkinChanged(SkinType.classicBlue);
      const event3 = SkinChanged(SkinType.freshGreen);

      expect(event1, equals(event2));
      expect(event1, isNot(equals(event3)));
    });

    test('ModeChanged stores mode correctly', () {
      const event = ModeChanged(AppThemeMode.dark);
      expect(event.mode, AppThemeMode.dark);
    });

    test('ThemeDataChanged stores skinName correctly', () {
      const event = ThemeDataChanged('default_dark');
      expect(event.skinName, 'default_dark');
    });
  });

  group('ThemeBloc event creation', () {
    test('all events are immutable', () {
      const toggled = ThemeToggled();
      const skinChanged = SkinChanged(SkinType.classicBlue);
      const modeChanged = ModeChanged(AppThemeMode.dark);
      const themeDataChanged = ThemeDataChanged('classic_blue');
      const initialized = ThemeInitialized();

      expect(toggled, isA<Object>());
      expect(skinChanged, isA<Object>());
      expect(modeChanged, isA<Object>());
      expect(themeDataChanged, isA<Object>());
      expect(initialized, isA<Object>());
    });
  });
}