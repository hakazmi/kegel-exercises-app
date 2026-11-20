import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/l10n/app_localizations.dart';
import '../../app/theme/system_ui.dart';
import '../../app/theme/tokens.dart';
import '../../core/data/providers.dart';
import '../../core/motion/app_motion.dart';
import '../../core/widgets/illustration.dart';

/// Branded launch overlay shown over the router on cold start.
///
/// It continues the native launch screen (same dark colour), animates the
/// mark and name, and meanwhile warms up what the first screen needs
/// (database, content, today's plan), so Today is already built when the
/// overlay fades out. It stays at least [minimum] and at most [maximum].
class SplashOverlay extends ConsumerStatefulWidget {
  const SplashOverlay({
    super.key,
    required this.onFinished,
    this.minimum = const Duration(milliseconds: 1300),
    this.maximum = const Duration(seconds: 4),
  });

  final VoidCallback onFinished;
  final Duration minimum;
  final Duration maximum;

  @override
  ConsumerState<SplashOverlay> createState() => _SplashOverlayState();
}

class _SplashOverlayState extends ConsumerState<SplashOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..forward();
  late final AnimationController _exit = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
  );

  @override
  void initState() {
    super.initState();
    unawaited(_run());
  }

  Future<void> _run() async {
    await Future.wait<void>(<Future<void>>[
      Future<void>.delayed(widget.minimum),
      _warmUp().timeout(widget.maximum, onTimeout: () {}),
    ]);
    if (!mounted) {
      return;
    }
    await _exit.forward();
    if (mounted) {
      widget.onFinished();
    }
  }

  /// Loads what Today needs so it is ready behind the overlay.
  Future<void> _warmUp() async {
    try {
      final bool onboarded = ref.read(userProfileProvider).onboardingDone;
      await Future.wait<Object?>(<Future<Object?>>[
        ref.read(exercisesProvider.future),
        ref.read(levelsProvider.future),
        if (onboarded) ref.read(todayPlanProvider.future),
        if (onboarded) ref.read(sessionsProvider.future),
      ]);
    } on Object {
      // The screens show their own errors; never block launch.
    }
  }

  @override
  void dispose() {
    _intro.dispose();
    _exit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppSystemUi.darkScreen,
      child: AnimatedBuilder(
        animation: Listenable.merge(<Listenable>[_intro, _exit]),
        builder: (BuildContext context, Widget? _) {
          final double t = _intro.value;
          final double out = Curves.easeIn.transform(_exit.value);
          final double mark =
              const Interval(0, 0.6, curve: AppMotion.dropCurve).transform(t);
          final double text =
              const Interval(0.35, 0.85, curve: Curves.easeOutCubic).transform(t);
          final double line =
              const Interval(0.5, 1, curve: Curves.easeInOutCubic).transform(t);
          return IgnorePointer(
            ignoring: _exit.value > 0,
            child: Opacity(
              opacity: 1 - out,
              child: Transform.scale(
                scale: 1 + 0.06 * out,
                child: ColoredBox(
                  color: AppColors.sessionBackground,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Accent glow that grows with the mark.
                      Container(
                        width: 360 * (0.6 + 0.4 * mark),
                        height: 360 * (0.6 + 0.4 * mark),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: <Color>[
                              AppColors.accent.withValues(alpha: 0.22 * mark),
                              AppColors.accent.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Transform.scale(
                            scale: 0.4 + 0.6 * mark,
                            child: Opacity(
                              opacity: mark.clamp(0.0, 1.0),
                              child: PulseHalo(
                                color: AppColors.accent,
                                size: 96,
                                child: Container(
                                  width: 96,
                                  height: 96,
                                  decoration: BoxDecoration(
                                    color: AppColors.sessionSurface,
                                    borderRadius: BorderRadius.circular(28),
                                    border: Border.all(
                                      color: AppColors.accent,
                                      width: 2,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Illustration(
                                    assetPath: 'assets/images/target.svg',
                                    semanticLabel: l10n.appName,
                                    width: 52,
                                    height: 52,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          Opacity(
                            opacity: text,
                            child: Transform.translate(
                              offset: Offset(0, 16 * (1 - text)),
                              child: Column(
                                children: [
                                  Text(
                                    l10n.appName,
                                    textAlign: TextAlign.center,
                                    style: AppTypography.display.copyWith(
                                      color: AppColors.sessionText,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.xxs),
                                  Text(
                                    l10n.splashTagline.toUpperCase(),
                                    textAlign: TextAlign.center,
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.accent,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          SizedBox(
                            width: 120,
                            height: 3,
                            child: ClipRRect(
                              borderRadius: AppRadii.pillAll,
                              child: ColoredBox(
                                color: AppColors.sessionRingTrack,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: FractionallySizedBox(
                                    widthFactor: line,
                                    heightFactor: 1,
                                    child: const ColoredBox(
                                      color: AppColors.accent,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
