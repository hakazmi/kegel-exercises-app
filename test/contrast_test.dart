import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:kegelexercisesapp/app/theme/tokens.dart';
import 'package:material_ui/material_ui.dart';

/// WCAG contrast pair under test.
class _Pair {
  const _Pair({
    required this.name,
    required this.foreground,
    required this.background,
    required this.minRatio,
    this.isGraphic = false,
  });

  final String name;
  final Color foreground;
  final Color background;
  final double minRatio;
  final bool isGraphic;
}

double _channel(double c) {
  final double s =
      c <= 0.04045 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
  return s;
}

double relativeLuminance(Color color) {
  final double r = _channel(color.r);
  final double g = _channel(color.g);
  final double b = _channel(color.b);
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

double contrastRatio(Color a, Color b) {
  final double l1 = relativeLuminance(a);
  final double l2 = relativeLuminance(b);
  final double lighter = math.max(l1, l2);
  final double darker = math.min(l1, l2);
  return (lighter + 0.05) / (darker + 0.05);
}

String _hex(Color c) {
  final int value = c.toARGB32() & 0xFFFFFF;
  return '#${value.toRadixString(16).padLeft(6, '0').toUpperCase()}';
}

String _table(_Pair pair, {required bool includePass}) {
  final double ratio = contrastRatio(pair.foreground, pair.background);
  final StringBuffer row = StringBuffer()
    ..write('| ${pair.name} | ${_hex(pair.foreground)} | ${_hex(pair.background)} | ')
    ..write(ratio.toStringAsFixed(2));
  if (includePass) {
    final bool pass = ratio + 0.0001 >= pair.minRatio;
    row.write(' | ${pair.minRatio.toStringAsFixed(1)} | ${pass ? 'yes' : 'NO'} |');
  } else {
    row.write(' |');
  }
  return row.toString();
}

List<_Pair> _requiredPairs() {
  const double normal = 4.5;
  const double largeOrGraphic = 3.0;

  return <_Pair>[
    const _Pair(
      name: 'textPrimary on background',
      foreground: AppColors.textPrimary,
      background: AppColors.background,
      minRatio: normal,
    ),
    const _Pair(
      name: 'textPrimary on surface',
      foreground: AppColors.textPrimary,
      background: AppColors.surface,
      minRatio: normal,
    ),
    const _Pair(
      name: 'textSecondary on background',
      foreground: AppColors.textSecondary,
      background: AppColors.background,
      minRatio: normal,
    ),
    const _Pair(
      name: 'textSecondary on surface',
      foreground: AppColors.textSecondary,
      background: AppColors.surface,
      minRatio: normal,
    ),
    const _Pair(
      name: 'textSecondary on surfaceMuted',
      foreground: AppColors.textSecondary,
      background: AppColors.surfaceMuted,
      minRatio: normal,
    ),
    const _Pair(
      name: 'display (28/extraBold) on background',
      foreground: AppColors.textPrimary,
      background: AppColors.background,
      minRatio: largeOrGraphic,
    ),
    const _Pair(
      name: 'title (20/bold) on surface',
      foreground: AppColors.textPrimary,
      background: AppColors.surface,
      minRatio: largeOrGraphic,
    ),
    const _Pair(
      name: 'PrimaryButton text on ink',
      foreground: AppColors.textOnPrimary,
      background: AppColors.ink,
      minRatio: normal,
    ),
    const _Pair(
      name: 'SecondaryButton text on surface',
      foreground: AppColors.textPrimary,
      background: AppColors.surface,
      minRatio: normal,
    ),
    const _Pair(
      name: 'selected card title on surface',
      foreground: AppColors.textPrimary,
      background: AppColors.surface,
      minRatio: normal,
    ),
    const _Pair(
      name: 'selected card subtitle on surface',
      foreground: AppColors.textSecondary,
      background: AppColors.surface,
      minRatio: normal,
    ),
    const _Pair(
      name: 'selected radio fill on surface (graphic)',
      foreground: AppColors.primary,
      background: AppColors.surface,
      minRatio: largeOrGraphic,
      isGraphic: true,
    ),
    const _Pair(
      name: 'goalBladder Fg on Bg (graphic)',
      foreground: AppColors.goalBladderFg,
      background: AppColors.goalBladderBg,
      minRatio: largeOrGraphic,
      isGraphic: true,
    ),
    const _Pair(
      name: 'goalErection Fg on Bg (graphic)',
      foreground: AppColors.goalErectionFg,
      background: AppColors.goalErectionBg,
      minRatio: largeOrGraphic,
      isGraphic: true,
    ),
    const _Pair(
      name: 'goalEjaculation Fg on Bg (graphic)',
      foreground: AppColors.goalEjaculationFg,
      background: AppColors.goalEjaculationBg,
      minRatio: largeOrGraphic,
      isGraphic: true,
    ),
    const _Pair(
      name: 'goalSurgery Fg on Bg (graphic)',
      foreground: AppColors.goalSurgeryFg,
      background: AppColors.goalSurgeryBg,
      minRatio: largeOrGraphic,
      isGraphic: true,
    ),
    const _Pair(
      name: 'goalGeneral Fg on Bg (graphic)',
      foreground: AppColors.goalGeneralFg,
      background: AppColors.goalGeneralBg,
      minRatio: largeOrGraphic,
      isGraphic: true,
    ),
    const _Pair(
      name: 'streak Fg on Bg (graphic)',
      foreground: AppColors.streakFg,
      background: AppColors.streakBg,
      minRatio: largeOrGraphic,
      isGraphic: true,
    ),
    const _Pair(
      name: 'primary on surface (graphic/icon)',
      foreground: AppColors.primary,
      background: AppColors.surface,
      minRatio: largeOrGraphic,
      isGraphic: true,
    ),
    const _Pair(
      name: 'primary on background (graphic/icon)',
      foreground: AppColors.primary,
      background: AppColors.background,
      minRatio: largeOrGraphic,
      isGraphic: true,
    ),
    const _Pair(
      name: 'primary on mint (graphic/icon)',
      foreground: AppColors.primary,
      background: AppColors.mint,
      minRatio: largeOrGraphic,
      isGraphic: true,
    ),
    const _Pair(
      name: 'TextLink primary on background',
      foreground: AppColors.primary,
      background: AppColors.background,
      minRatio: normal,
    ),
    const _Pair(
      name: 'TextLink primary on surface',
      foreground: AppColors.primary,
      background: AppColors.surface,
      minRatio: normal,
    ),
    const _Pair(
      name: 'tab selected (ink) on surface',
      foreground: AppColors.ink,
      background: AppColors.surface,
      minRatio: normal,
    ),
    const _Pair(
      name: 'tab unselected (textSecondary) on surface',
      foreground: AppColors.textSecondary,
      background: AppColors.surface,
      minRatio: normal,
    ),
    const _Pair(
      name: 'tab icon selected on surface (graphic)',
      foreground: AppColors.ink,
      background: AppColors.surface,
      minRatio: largeOrGraphic,
      isGraphic: true,
    ),
    const _Pair(
      name: 'sessionText on sessionBackground',
      foreground: AppColors.sessionText,
      background: AppColors.sessionBackground,
      minRatio: normal,
    ),
    const _Pair(
      name: 'sessionText on sessionSurface',
      foreground: AppColors.sessionText,
      background: AppColors.sessionSurface,
      minRatio: normal,
    ),
    const _Pair(
      name: 'sessionTextSecondary on sessionBackground',
      foreground: AppColors.sessionTextSecondary,
      background: AppColors.sessionBackground,
      minRatio: normal,
    ),
    const _Pair(
      name: 'sessionTextSecondary on sessionSurface',
      foreground: AppColors.sessionTextSecondary,
      background: AppColors.sessionSurface,
      minRatio: normal,
    ),
    const _Pair(
      name: 'phaseSqueezeHold on sessionBackground (ring)',
      foreground: AppColors.phaseSqueezeHold,
      background: AppColors.sessionBackground,
      minRatio: largeOrGraphic,
      isGraphic: true,
    ),
    const _Pair(
      name: 'phaseRelax on sessionBackground (ring)',
      foreground: AppColors.phaseRelax,
      background: AppColors.sessionBackground,
      minRatio: largeOrGraphic,
      isGraphic: true,
    ),
    const _Pair(
      name: 'phaseRest on sessionBackground (ring)',
      foreground: AppColors.phaseRest,
      background: AppColors.sessionBackground,
      minRatio: largeOrGraphic,
      isGraphic: true,
    ),
    const _Pair(
      name: 'accent on sessionBackground (graphic)',
      foreground: AppColors.accent,
      background: AppColors.sessionBackground,
      minRatio: largeOrGraphic,
      isGraphic: true,
    ),
  ];
}

/// Disabled controls and decorative tracks — reported, not asserted.
List<_Pair> _exemptPairs() {
  return const <_Pair>[
    _Pair(
      name: 'PrimaryButton disabled label on buttonDisabled',
      foreground: AppColors.textDisabledLabel,
      background: AppColors.buttonDisabled,
      minRatio: 0,
    ),
    _Pair(
      name: 'SecondaryButton disabled label on surface',
      foreground: AppColors.textDisabledLabel,
      background: AppColors.surface,
      minRatio: 0,
    ),
    _Pair(
      name: 'textDisabled (icon) on surface',
      foreground: AppColors.textDisabled,
      background: AppColors.surface,
      minRatio: 0,
    ),
    _Pair(
      name: 'sessionRingTrack on sessionBackground (decorative)',
      foreground: AppColors.sessionRingTrack,
      background: AppColors.sessionBackground,
      minRatio: 0,
    ),
  ];
}

void main() {
  test('WCAG contrast for theme colour pairs', () {
    final List<_Pair> pairs = _requiredPairs();
    final StringBuffer table = StringBuffer()
      ..writeln('| Pair | Fg | Bg | Ratio | Min | Pass |')
      ..writeln('| --- | --- | --- | ---: | ---: | --- |');

    final List<String> failures = <String>[];

    for (final _Pair pair in pairs) {
      final double ratio = contrastRatio(pair.foreground, pair.background);
      final bool pass = ratio + 0.0001 >= pair.minRatio;
      table.writeln(_table(pair, includePass: true));
      if (!pass) {
        failures.add(
          '${pair.name}: ${ratio.toStringAsFixed(2)} < ${pair.minRatio} '
          '(${_hex(pair.foreground)} on ${_hex(pair.background)})',
        );
      }
    }

    final StringBuffer exempt = StringBuffer()
      ..writeln('| Pair | Fg | Bg | Ratio |')
      ..writeln('| --- | --- | --- | ---: |');
    for (final _Pair pair in _exemptPairs()) {
      exempt.writeln(_table(pair, includePass: false));
    }

    // ignore: avoid_print
    print('\n${table.toString()}');
    // ignore: avoid_print
    print('exempt (disabled or decorative)\n${exempt.toString()}');

    expect(
      failures,
      isEmpty,
      reason: 'Contrast failures:\n${failures.join('\n')}',
    );
  });
}
