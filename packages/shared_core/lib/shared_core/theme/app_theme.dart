import 'package:flutter/material.dart';

import 'app_typography.dart';
import 'app_spacing.dart';
import 'app_radius.dart';
import 'skins/default_light.dart';
import 'skins/default_dark.dart';
import 'skins/classic_blue.dart';
import 'skins/fresh_green.dart';
import 'skins/sunset_red.dart';
import 'skins/purple_soul.dart';
import 'skins/pink_man.dart';

enum AppThemeMode {
  light,
  dark,
  system,
}

enum SkinType {
  defaultLight,
  defaultDark,
  classicBlue,
  freshGreen,
  sunsetRed,
  purpleSoul,
  pinkMan,
}

class SkinConfig {
  final String name;
  final String displayName;
  final bool isDark;

  final Color bgPrimary;
  final Color bgSecondary;
  final Color bgTertiary;
  final Color cardBg;
  final Color cardHover;
  final Color sidebarBg;

  final Color textPrimary;
  final Color textSecondary;
  final Color textDisabled;

  final Color accent;
  final Color accentHover;
  final Color accentLight;

  final Color buttonBg;
  final Color buttonHover;
  final Color buttonText;
  final Color buttonSecondaryBg;
  final Color buttonSecondaryHover;
  final Color buttonSecondaryText;

  final Color border;
  final Color borderLight;

  final Color error;
  final Color success;
  final Color warning;
  final Color info;

  const SkinConfig({
    required this.name,
    required this.displayName,
    required this.isDark,
    required this.bgPrimary,
    required this.bgSecondary,
    required this.bgTertiary,
    required this.cardBg,
    required this.cardHover,
    required this.sidebarBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
    required this.accent,
    required this.accentHover,
    required this.accentLight,
    required this.buttonBg,
    required this.buttonHover,
    required this.buttonText,
    required this.buttonSecondaryBg,
    required this.buttonSecondaryHover,
    required this.buttonSecondaryText,
    required this.border,
    required this.borderLight,
    required this.error,
    required this.success,
    required this.warning,
    required this.info,
  });
}

class AppTheme {
  AppTheme._();

  static const List<SkinConfig> _skinList = [
    defaultLightSkin,
    defaultDarkSkin,
    classicBlueSkin,
    freshGreenSkin,
    sunsetRedSkin,
    purpleSoulSkin,
    pinkManSkin,
  ];

  static List<SkinConfig> get allSkins => _skinList;

  static const Set<String> darkSkinNames = {'default_dark'};

  static SkinConfig getSkinConfig(SkinType type) {
    return _skinList[type.index];
  }

  static SkinConfig? getSkinConfigByName(String name) {
    for (final skin in _skinList) {
      if (skin.name == name) return skin;
    }
    return null;
  }

  static ThemeData buildThemeData(SkinType skinType) {
    final skin = getSkinConfig(skinType);
    return _buildThemeDataFromConfig(skin);
  }

  static ThemeData _buildThemeDataFromConfig(SkinConfig skin) {
    final isDark = skin.isDark;

    final colorScheme = ColorScheme(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primary: skin.accent,
      onPrimary: skin.buttonText,
      secondary: skin.info,
      onSecondary: skin.buttonText,
      tertiary: skin.accentLight,
      onTertiary: isDark ? skin.textPrimary : skin.bgPrimary,
      error: skin.error,
      onError: skin.buttonText,
      surface: skin.bgPrimary,
      onSurface: skin.textPrimary,
      surfaceContainerHighest: skin.bgSecondary,
      onSurfaceVariant: skin.textSecondary,
      outline: skin.border,
      outlineVariant: skin.borderLight,
      shadow: isDark ? Colors.black54 : Colors.black12,
      scrim: isDark ? Colors.black54 : Colors.black26,
      inverseSurface: isDark ? skin.bgSecondary : skin.bgTertiary,
      onInverseSurface: isDark ? skin.textPrimary : skin.textSecondary,
      inversePrimary: skin.accentHover,
    );

    final textTheme = TextTheme(
      displayLarge: AppTypography.title4.copyWith(color: skin.textPrimary),
      displayMedium: AppTypography.title3.copyWith(color: skin.textPrimary),
      displaySmall: AppTypography.title2.copyWith(color: skin.textPrimary),
      headlineLarge: AppTypography.title1.copyWith(color: skin.textPrimary),
      headlineMedium: AppTypography.medium.copyWith(
        color: skin.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: AppTypography.regular.copyWith(
        color: skin.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: AppTypography.title1.copyWith(color: skin.textPrimary),
      titleMedium: AppTypography.medium.copyWith(color: skin.textPrimary),
      titleSmall: AppTypography.regularBold.copyWith(color: skin.textPrimary),
      bodyLarge: AppTypography.regular.copyWith(color: skin.textPrimary),
      bodyMedium: AppTypography.regular.copyWith(color: skin.textPrimary),
      bodySmall: AppTypography.small.copyWith(color: skin.textSecondary),
      labelLarge: AppTypography.medium.copyWith(
        color: skin.textPrimary,
        fontWeight: FontWeight.w500,
      ),
      labelMedium: AppTypography.small.copyWith(
        color: skin.textSecondary,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: AppTypography.small2.copyWith(color: skin.textDisabled),
    );

    return ThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: skin.bgPrimary,
      canvasColor: skin.bgPrimary,
      cardColor: skin.cardBg,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: skin.bgSecondary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: skin.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: skin.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: skin.accent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: skin.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: skin.error, width: 2),
        ),
        hintStyle: AppTypography.regular.copyWith(color: skin.textDisabled),
        labelStyle: AppTypography.regular.copyWith(color: skin.textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: skin.buttonBg,
          foregroundColor: skin.buttonText,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: AppTypography.regularBold,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: skin.accent,
          side: BorderSide(color: skin.border),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: AppTypography.regularBold,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: skin.accent,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          textStyle: AppTypography.regularBold,
        ),
      ),
      cardTheme: CardThemeData(
        color: skin.cardBg,
        elevation: isDark ? 2 : 1,
        shadowColor: isDark ? Colors.black54 : Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: skin.border, width: 0.5),
        ),
        margin: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
          horizontal: AppSpacing.md,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: skin.bgPrimary,
        foregroundColor: skin.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: isDark ? Colors.black54 : Colors.black12,
        centerTitle: true,
        titleTextStyle: AppTypography.title1.copyWith(
          color: skin.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: skin.textPrimary),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: skin.bgPrimary,
        selectedItemColor: skin.accent,
        unselectedItemColor: skin.textDisabled,
        selectedLabelStyle: AppTypography.smallBold,
        unselectedLabelStyle: AppTypography.small,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? skin.bgTertiary : skin.bgSecondary,
        contentTextStyle: AppTypography.regular.copyWith(
          color: skin.textPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: skin.bgPrimary,
        elevation: isDark ? 8 : 4,
        shadowColor: isDark ? Colors.black54 : Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        titleTextStyle: AppTypography.title2.copyWith(
          color: skin.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: AppTypography.regular.copyWith(
          color: skin.textPrimary,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: skin.bgSecondary,
        selectedColor: skin.accentLight,
        labelStyle: AppTypography.small.copyWith(color: skin.textPrimary),
        secondaryLabelStyle: AppTypography.small.copyWith(
          color: skin.accent,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: skin.accent,
        unselectedLabelColor: skin.textDisabled,
        indicatorColor: skin.accent,
        labelStyle: AppTypography.medium.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTypography.medium,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: skin.accent,
        linearTrackColor: skin.bgTertiary,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? skin.accent
              : skin.border,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xs),
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? skin.accent
              : skin.border,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? skin.accent
              : skin.textDisabled,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? skin.accentLight
              : skin.bgTertiary,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: skin.borderLight,
        thickness: 1,
        space: 1,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isDark ? skin.bgTertiary : skin.bgSecondary,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        textStyle: AppTypography.small2.copyWith(
          color: skin.textPrimary,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: skin.bgPrimary,
        elevation: isDark ? 8 : 4,
        shadowColor: isDark ? Colors.black54 : Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        textStyle: AppTypography.regular.copyWith(color: skin.textPrimary),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        titleTextStyle: AppTypography.regularBold.copyWith(
          color: skin.textPrimary,
        ),
        subtitleTextStyle: AppTypography.small.copyWith(
          color: skin.textSecondary,
        ),
        iconColor: skin.textSecondary,
        selectedTileColor: skin.accentLight,
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: AppTypography.regular.copyWith(color: skin.textPrimary),
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(skin.bgPrimary),
          elevation: WidgetStatePropertyAll(isDark ? 8.0 : 4.0),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: skin.accent,
        inactiveTrackColor: skin.bgTertiary,
        thumbColor: skin.accent,
        overlayColor: skin.accent.withOpacity(0.1),
        valueIndicatorColor: skin.accent,
        valueIndicatorTextStyle: AppTypography.small.copyWith(
          color: skin.buttonText,
        ),
      ),
    );
  }

  static Brightness getSystemBrightness() {
    return WidgetsBinding.instance.platformDispatcher.platformBrightness;
  }

  static bool isDarkMode(AppThemeMode mode, SkinType skinType) {
    switch (mode) {
      case AppThemeMode.light:
        return false;
      case AppThemeMode.dark:
        return true;
      case AppThemeMode.system:
        return getSystemBrightness() == Brightness.dark ||
            darkSkinNames.contains(skinType.name);
    }
  }

  static ThemeData getThemeData(AppThemeMode mode, SkinType skinType) {
    final isDark = isDarkMode(mode, skinType);
    final targetSkin = isDark ? SkinType.defaultDark : SkinType.defaultLight;

    if (skinType == targetSkin) {
      return buildThemeData(skinType);
    }

    return buildThemeData(targetSkin);
  }
}
