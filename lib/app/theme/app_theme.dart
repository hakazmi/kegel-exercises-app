import 'package:material_ui/material_ui.dart';

import 'system_ui.dart';
import 'tokens.dart';

/// Builds the light app [ThemeData] and the dark [SessionTheme] for S2–S4.
abstract final class AppTheme {
  /// Light theme for onboarding, tabs, Learn, Settings and paywall.
  static ThemeData light() {
    const ColorScheme scheme = ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.textOnPrimary,
      secondary: AppColors.accent,
      onSecondary: AppColors.textOnPrimary,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.textSecondary,
      outline: AppColors.border,
      error: AppColors.goalGeneralFg,
      onError: AppColors.textOnPrimary,
    );

    const TextTheme textTheme = TextTheme(
      displayLarge: AppTypography.display,
      titleLarge: AppTypography.title,
      bodyLarge: AppTypography.body,
      bodyMedium: AppTypography.body,
      labelLarge: AppTypography.button,
      bodySmall: AppTypography.caption,
      labelSmall: AppTypography.caption,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: AppTypography.fontFamily,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        systemOverlayStyle: AppSystemUi.lightScreen,
        centerTitle: true,
      ),
      dividerColor: AppColors.border,
      cardTheme: const CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.lgAll),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.surface;
        }),
        checkColor: const WidgetStatePropertyAll<Color>(AppColors.textOnPrimary),
        side: const BorderSide(color: AppColors.borderStrong, width: 1.5),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.surfaceMuted,
      ),
    );
  }

  /// Dark theme used only inside session screens (countdown / player / done).
  static ThemeData session() {
    const ColorScheme scheme = ColorScheme.dark(
      primary: AppColors.accent,
      onPrimary: AppColors.ink,
      secondary: AppColors.success,
      onSecondary: AppColors.sessionText,
      surface: AppColors.sessionSurface,
      onSurface: AppColors.sessionText,
      onSurfaceVariant: AppColors.sessionTextSecondary,
      outline: AppColors.sessionRingTrack,
      error: AppColors.goalGeneralFg,
      onError: AppColors.sessionText,
    );

    final TextTheme textTheme = TextTheme(
      displayLarge: AppTypography.display.copyWith(color: AppColors.sessionText),
      titleLarge: AppTypography.title.copyWith(color: AppColors.sessionText),
      bodyLarge: AppTypography.body.copyWith(color: AppColors.sessionText),
      bodyMedium: AppTypography.body.copyWith(color: AppColors.sessionText),
      labelLarge: AppTypography.button.copyWith(color: AppColors.ink),
      bodySmall: AppTypography.caption.copyWith(
        color: AppColors.sessionTextSecondary,
      ),
      labelSmall: AppTypography.caption.copyWith(
        color: AppColors.sessionTextSecondary,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.sessionBackground,
      fontFamily: AppTypography.fontFamily,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.sessionBackground,
        foregroundColor: AppColors.sessionText,
        systemOverlayStyle: AppSystemUi.darkScreen,
      ),
    );
  }
}

/// Convenience accessor for session-only colours without rebuilding ThemeData.
abstract final class SessionTheme {
  static const Color background = AppColors.sessionBackground;
  static const Color surface = AppColors.sessionSurface;
  static const Color text = AppColors.sessionText;
  static const Color textSecondary = AppColors.sessionTextSecondary;
  static const Color ringTrack = AppColors.sessionRingTrack;
}
