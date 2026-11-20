import 'package:material_ui/material_ui.dart';

/// Design tokens extracted from the product screenshots and product decisions.
///
/// All colours, spacing, radii, type and elevation used in the UI must come
/// from this file. See `docs/design/tokens.md` for the approval list.
abstract final class AppColors {
  // Brand / semantic. Soft white app with charcoal CTAs and fresh green
  // accents (sample onboarding system). Primary is WCAG-safe on white.
  static const Color primary = Color(0xFF1A7D43);
  static const Color success = Color(0xFF1F8A4A);
  /// Pale green tint behind primary icons and selected cards.
  static const Color mint = Color(0xFFE7F6EC);
  static const Color accent = Color(0xFF1E9A54);

  // Surfaces (light app)
  static const Color background = Color(0xFFF5F6F8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFEEF0F3);
  static const Color border = Color(0xFFE2E5EA);
  static const Color borderStrong = Color(0xFF222222);

  // Ink / text (light) — charcoal buttons, dark navy headings.
  static const Color ink = Color(0xFF222222);
  static const Color textPrimary = Color(0xFF1A1C2E);
  /// Meets 4.5:1 on background, surface and surfaceMuted.
  static const Color textSecondary = Color(0xFF5E6272);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  /// Disabled icons (WCAG-exempt).
  static const Color textDisabled = Color(0xFFA3A8B3);
  /// Disabled control label (WCAG-exempt). Used on [buttonDisabled] fills.
  static const Color textDisabledLabel = Color(0xFF6E7380);
  /// Disabled primary button fill (WCAG-exempt).
  static const Color buttonDisabled = Color(0xFFD5D8DE);

  // Feature surfaces (session screens and highlight cards).
  static const Color sessionBackground = Color(0xFFEEF6F1);
  static const Color sessionSurface = Color(0xFFFFFFFF);
  static const Color sessionText = Color(0xFF1A1C2E);
  static const Color sessionTextSecondary = Color(0xFF5E6272);
  /// Decorative ring track (WCAG-exempt; no 3:1 requirement).
  static const Color sessionRingTrack = Color(0xFFCDEBD8);

  // Phase colours (session ring)
  static const Color phaseSqueezeHold = accent;
  static const Color phaseRelax = success;
  static const Color phaseRest = Color(0xFF6E7380);

  // Reference pastel accents for cards and illustrations (backgrounds only;
  // text on them is ink).
  static const Color lavender = Color(0xFFC4B5F5);
  static const Color peach = Color(0xFFFFBE5C);
  static const Color sky = Color(0xFFB4D2FF);
  static const Color blush = Color(0xFFF5BDE9);
  static const Color pistachio = Color(0xFFB9EBC6);

  // Goal chip backgrounds (pastel blue / lavender / orange / green / pink)
  static const Color goalBladderBg = Color(0xFFE3EEFF);
  static const Color goalErectionBg = Color(0xFFEEE8FF);
  static const Color goalEjaculationBg = Color(0xFFFFF0DA);
  static const Color goalSurgeryBg = Color(0xFFE6F7EC);
  static const Color goalGeneralBg = Color(0xFFFDEAF7);

  // Goal chip foregrounds
  static const Color goalBladderFg = Color(0xFF2852C4);
  static const Color goalErectionFg = Color(0xFF6B5CC7);
  static const Color goalEjaculationFg = Color(0xFFA14A00);
  static const Color goalSurgeryFg = Color(0xFF1C7A50);
  static const Color goalGeneralFg = Color(0xFFB02A7E);

  // Misc
  static const Color streakBg = Color(0xFFFFF0DA);
  static const Color streakFg = Color(0xFFA14A00);
  static const Color scrim = Color(0x661A1C2E);
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
      color: Color(0x1417151F),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> level2 = <BoxShadow>[
    BoxShadow(
      color: Color(0x1A17151F),
      blurRadius: 16,
      offset: Offset(0, 6),
    ),
  ];
}

/// One level's colours (light theme): a bright [base] for its cover panel,
/// a pale [tint] for its day cards, and a [deep] shade for text on either.
class LevelPalette {
  const LevelPalette({
    required this.base,
    required this.tint,
    required this.deep,
  });

  final Color base;
  final Color tint;
  final Color deep;

  /// Level 1 lavender, 2 peach, 3 sky, 4 blush, 5 pistachio. Text on [base] and
  /// [tint] is [AppColors.ink] (≥ 10:1) or [deep] (≥ 4.5:1).
  static const List<LevelPalette> levels = <LevelPalette>[
    LevelPalette(base: Color(0xFFB9A8F7), tint: Color(0xFFEFEBFF), deep: Color(0xFF2E1F7A)),
    LevelPalette(base: Color(0xFFFFBE5C), tint: Color(0xFFFFF1DC), deep: Color(0xFF6B3A00)),
    LevelPalette(base: Color(0xFFB4D2FF), tint: Color(0xFFE9F2FF), deep: Color(0xFF123E7A)),
    LevelPalette(base: Color(0xFFF5BDE9), tint: Color(0xFFFDEDF8), deep: Color(0xFF7A1E62)),
    LevelPalette(base: Color(0xFFB9EBC6), tint: Color(0xFFEAF8EE), deep: Color(0xFF0E5A3A)),
  ];

  /// Palette for level [id] (1-based; clamps into range).
  static LevelPalette of(int id) => levels[(id - 1).clamp(0, levels.length - 1)];

  /// Calm lavender used for rest days.
  static const LevelPalette rest = LevelPalette(
    base: Color(0xFFE4DEFF),
    tint: Color(0xFFF4F1FF),
    deep: Color(0xFF4B3BC4),
  );
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
