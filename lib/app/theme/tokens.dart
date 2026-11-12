import 'package:material_ui/material_ui.dart';

/// Design tokens extracted from the product screenshots and product decisions.
///
/// All colours, spacing, radii, type and elevation used in the UI must come
/// from this file. See `docs/design/tokens.md` for the approval list.
abstract final class AppColors {
  // Brand / semantic
  static const Color primary = Color(0xFF0B7A4B);
  static const Color success = Color(0xFF0B7A4B);
  static const Color mint = Color(0xFFEAF7F0);
  static const Color accent = Color(0xFF1AAE68);

  // Surfaces (light app)
  static const Color background = Color(0xFFF5F7F6);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFEEF1F0);
  static const Color border = Color(0xFFDCE3E0);
  static const Color borderStrong = Color(0xFF0E1412);

  // Ink / text (light)
  static const Color ink = Color(0xFF0E1412);
  static const Color textPrimary = Color(0xFF0E1412);
  /// Darkened from screenshot `#6F7974` to meet 4.5:1 on background / surfaceMuted.
  static const Color textSecondary = Color(0xFF66706B);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  /// Disabled icons (WCAG-exempt).
  static const Color textDisabled = Color(0xFF9AA39F);
  /// Disabled control label (WCAG-exempt). Used on [buttonDisabled] fills.
  static const Color textDisabledLabel = Color(0xFF6F7974);
  /// Disabled primary button fill (WCAG-exempt).
  static const Color buttonDisabled = Color(0xFFCBD2D0);

  // Session (dark)
  static const Color sessionBackground = Color(0xFF0E1412);
  static const Color sessionSurface = Color(0xFF1A221F);
  static const Color sessionText = Color(0xFFFFFFFF);
  static const Color sessionTextSecondary = Color(0xFF9AA39F);
  /// Decorative ring track (WCAG-exempt; no 3:1 requirement).
  static const Color sessionRingTrack = Color(0xFF2A3430);

  // Phase colours (session ring)
  static const Color phaseSqueezeHold = accent;
  static const Color phaseRelax = success;
  static const Color phaseRest = Color(0xFF6F7974);

  // Goal chip backgrounds
  static const Color goalBladderBg = Color(0xFFE6EEFF);
  static const Color goalErectionBg = Color(0xFFEAF7F0);
  static const Color goalEjaculationBg = Color(0xFFFFF1E3);
  static const Color goalSurgeryBg = Color(0xFFF1EAFE);
  static const Color goalGeneralBg = Color(0xFFFFE9EE);

  // Goal chip foregrounds
  static const Color goalBladderFg = Color(0xFF3257D6);
  static const Color goalErectionFg = Color(0xFF0B7A4B);
  static const Color goalEjaculationFg = Color(0xFFB4520F);
  static const Color goalSurgeryFg = Color(0xFF6B3FC9);
  static const Color goalGeneralFg = Color(0xFFC2334F);

  // Misc
  static const Color streakBg = Color(0xFFFFF1E3);
  static const Color streakFg = Color(0xFFB4520F);
  static const Color scrim = Color(0x660E1412);
}

/// Spacing scale in logical pixels.
abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;

  /// Minimum interactive control size (Material / a11y).
  static const double minTouchTarget = 48;
}

/// Corner radii.
abstract final class AppRadii {
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double pill = 999;

  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlAll = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius pillAll = BorderRadius.all(Radius.circular(pill));
}

/// Manrope type scale. Uses the bundled family when available.
abstract final class AppTypography {
  static const String fontFamily = 'Manrope';

  static const TextStyle display = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    height: 1.25,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  static const TextStyle title = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    height: 1.3,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 1.45,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    height: 1.4,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 1.25,
    fontWeight: FontWeight.w700,
    color: AppColors.textOnPrimary,
  );
}

/// Elevation / shadow tokens.
abstract final class AppElevation {
  static const List<BoxShadow> none = <BoxShadow>[];

  static const List<BoxShadow> level1 = <BoxShadow>[
    BoxShadow(
      color: Color(0x140E1412),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> level2 = <BoxShadow>[
    BoxShadow(
      color: Color(0x1A0E1412),
      blurRadius: 16,
      offset: Offset(0, 6),
    ),
  ];
}

/// Session phase used by [SessionRing] colour mapping.
enum SessionPhase { squeeze, hold, relax, rest }

/// Maps a [SessionPhase] to its ring fill colour.
Color phaseColor(SessionPhase phase) {
  switch (phase) {
    case SessionPhase.squeeze:
    case SessionPhase.hold:
      return AppColors.phaseSqueezeHold;
    case SessionPhase.relax:
      return AppColors.phaseRelax;
    case SessionPhase.rest:
      return AppColors.phaseRest;
  }
}
