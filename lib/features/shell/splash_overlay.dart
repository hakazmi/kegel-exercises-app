import 'dart:async';
import 'dart:math' as math;

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
/// A calm breathing figure sits in a slowly breathing halo; a lens with the
/// pelvic floor pops in and points to his pelvis, then a daily motivation
/// line fades up. Meanwhile it warms up what the first screen needs
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
    duration: const Duration(milliseconds: 1600),
  )..forward();
  late final AnimationController _breath = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat(reverse: true);
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat();
  late final AnimationController _exit = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
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
    _breath.dispose();
    _pulse.dispose();
    _exit.dispose();
    super.dispose();
  }

  /// Rotates the line by day of year so each launch day feels fresh.
  String _motivation(AppLocalizations l10n) {
    final DateTime now = DateTime.now();
    final int dayOfYear = now.difference(DateTime(now.year)).inDays;
    return l10n.splashMotivation('d${dayOfYear % 4}');
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String motivation = _motivation(l10n);
    final EdgeInsets safe = MediaQuery.paddingOf(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppSystemUi.lightScreen,
      child: AnimatedBuilder(
        animation: Listenable.merge(<Listenable>[_intro, _exit]),
        builder: (BuildContext context, Widget? _) {
          final double t = _intro.value;
          final double out = Curves.easeIn.transform(_exit.value);
          final double brand =
              const Interval(0, 0.4, curve: Curves.easeOutCubic).transform(t);
          final double text =
              const Interval(0.6, 1, curve: Curves.easeOutCubic).transform(t);
          return IgnorePointer(
            ignoring: _exit.value > 0,
            child: Opacity(
              opacity: 1 - out,
              child: Transform.scale(
                scale: 1 + 0.05 * out,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        AppColors.mint,
                        AppColors.sessionBackground,
                        Color(0xFFDDF1E4),
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      safe.top + AppSpacing.lg,
                      AppSpacing.xl,
                      safe.bottom + AppSpacing.xl,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Opacity(
                          opacity: brand,
                          child: Transform.translate(
                            offset: Offset(0, -12 * (1 - brand)),
                            child: _BrandRow(name: l10n.appName),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: _BreathingSpotlight(
                              intro: _intro,
                              breath: _breath,
                              pulse: _pulse,
                            ),
                          ),
                        ),
                        Opacity(
                          opacity: text,
                          child: Transform.translate(
                            offset: Offset(0, 18 * (1 - text)),
                            child: Column(
                              children: [
                                Text(
                                  l10n.splashTagline.toUpperCase(),
                                  textAlign: TextAlign.center,
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 2,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  motivation,
                                  textAlign: TextAlign.center,
                                  style: AppTypography.title.copyWith(
                                    color: AppColors.textPrimary,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Center(child: _ProgressLine(progress: t)),
                      ],
                    ),
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

/// App mark and name centred at the top.
class _BrandRow extends StatelessWidget {
  const _BrandRow({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x221A7D43),
                blurRadius: 14,
                offset: Offset(0, 5),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Illustration(
            assetPath: 'assets/images/target.svg',
            semanticLabel: name,
            width: 22,
            height: 22,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          name,
          style: AppTypography.title.copyWith(letterSpacing: -0.3),
        ),
      ],
    );
  }
}

/// Calm breathing figure in a breathing halo, with a pelvic floor lens that
/// points to his pelvis via a dashed line and a pulsing marker.
class _BreathingSpotlight extends StatelessWidget {
  const _BreathingSpotlight({
    required this.intro,
    required this.breath,
    required this.pulse,
  });

  final Animation<double> intro;
  final Animation<double> breath;
  final Animation<double> pulse;

  static const String _figure = 'assets/positions/position_breathing_calm.png';
  static const String _pelvis = 'assets/images/onboarding/cutouts/pelvis.png';

  /// Cutout is 702x720; the pelvis sits at the centre of the shorts.
  static const double _figureAspect = 702 / 720;
  static const Offset _pelvisPoint = Offset(0.505, 0.77);

  /// Lens centre as a fraction of the figure box (upper right, clear space).
  static const Offset _lensCentre = Offset(0.84, 0.2);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints c) {
        final double maxW = math.min(c.maxWidth, 330);
        final double w = math.min(maxW, c.maxHeight * _figureAspect);
        final double h = w / _figureAspect;
        final double lens = w * 0.30;
        final Offset pelvis = Offset(w * _pelvisPoint.dx, h * _pelvisPoint.dy);
        final Offset lensCentre = Offset(w * _lensCentre.dx, h * _lensCentre.dy);
        return Semantics(
          image: true,
          label: AppLocalizations.of(context).splashImageLabel,
          child: SizedBox(
            width: w,
            height: h,
            child: AnimatedBuilder(
              animation: Listenable.merge(<Listenable>[intro, breath, pulse]),
              builder: (BuildContext context, Widget? _) {
                final double t = intro.value;
                final double figureIn =
                    const Interval(0, 0.45, curve: Curves.easeOutCubic)
                        .transform(t);
                final double lensIn =
                    const Interval(0.35, 0.7, curve: AppMotion.dropCurve)
                        .transform(t);
                final double lineIn =
                    const Interval(0.55, 0.85, curve: Curves.easeInOutCubic)
                        .transform(t);
                final double markerIn =
                    const Interval(0.75, 1, curve: Curves.easeOut).transform(t);
                final double b = Curves.easeInOutSine.transform(breath.value);
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Breathing halo behind the figure.
                    Positioned(
                      left: w * 0.5 - w * 0.47,
                      top: h * 0.53 - w * 0.47,
                      child: Opacity(
                        opacity: figureIn,
                        child: Transform.scale(
                          scale: 0.9 + 0.1 * b,
                          child: Container(
                            width: w * 0.94,
                            height: w * 0.94,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: <Color>[
                                  AppColors.accent.withValues(alpha: 0.22),
                                  AppColors.accent.withValues(alpha: 0.06),
                                  AppColors.accent.withValues(alpha: 0),
                                ],
                                stops: const <double>[0, 0.7, 1],
                              ),
                              border: Border.all(
                                color: AppColors.accent.withValues(
                                  alpha: 0.18 + 0.12 * b,
                                ),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Opacity(
                        opacity: figureIn,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - figureIn) - 3 * b),
                          child: Image.asset(
                            _figure,
                            fit: BoxFit.contain,
                            excludeFromSemantics: true,
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _PointerPainter(
                          from: lensCentre,
                          lensRadius: lens / 2,
                          to: pelvis,
                          progress: lineIn,
                          marker: markerIn,
                          pulse: pulse.value,
                        ),
                      ),
                    ),
                    Positioned(
                      left: lensCentre.dx - lens / 2,
                      top: lensCentre.dy - lens / 2,
                      width: lens,
                      height: lens,
                      child: Opacity(
                        opacity: lensIn.clamp(0.0, 1.0),
                        child: Transform.scale(
                          scale: 0.4 + 0.6 * lensIn,
                          child: Container(
                            padding: EdgeInsets.all(lens * 0.12),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.accent.withValues(alpha: 0.6),
                                width: 2,
                              ),
                              boxShadow: const <BoxShadow>[
                                BoxShadow(
                                  color: Color(0x2E1A7D43),
                                  blurRadius: 18,
                                  offset: Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              _pelvis,
                              fit: BoxFit.contain,
                              excludeFromSemantics: true,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

/// Dashed pointer drawn from the lens edge to the pelvis, then a pulsing
/// marker at the pelvis.
class _PointerPainter extends CustomPainter {
  _PointerPainter({
    required this.from,
    required this.lensRadius,
    required this.to,
    required this.progress,
    required this.marker,
    required this.pulse,
  });

  final Offset from;
  final double lensRadius;
  final Offset to;
  final double progress;
  final double marker;
  final double pulse;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset delta = to - from;
    final double length = delta.distance;
    if (length <= lensRadius + 8) {
      return;
    }
    final Offset dir = delta / length;
    final Offset start = from + dir * (lensRadius + 2);
    final double total = (length - lensRadius - 10) * progress;
    final Paint dash = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.8)
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    const double dashLen = 5;
    const double gap = 4;
    for (double d = 0; d < total; d += dashLen + gap) {
      final double end = d + dashLen > total ? total : d + dashLen;
      canvas.drawLine(start + dir * d, start + dir * end, dash);
    }
    if (marker <= 0) {
      return;
    }
    for (final double phase in <double>[pulse, (pulse + 0.5) % 1]) {
      final Paint ring = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = AppColors.accent.withValues(
          alpha: (1 - phase) * 0.65 * marker,
        );
      canvas.drawCircle(to, 7 + phase * 22, ring);
    }
    canvas.drawCircle(
      to,
      7 * marker,
      Paint()..color = AppColors.surface,
    );
    canvas.drawCircle(
      to,
      4.5 * marker,
      Paint()..color = AppColors.accent,
    );
  }

  @override
  bool shouldRepaint(_PointerPainter old) =>
      old.progress != progress ||
      old.marker != marker ||
      old.pulse != pulse ||
      old.from != from ||
      old.to != to;
}

/// Thin loading line that fills while the app warms up.
class _ProgressLine extends StatelessWidget {
  const _ProgressLine({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 3,
      child: ClipRRect(
        borderRadius: AppRadii.pillAll,
        child: ColoredBox(
          color: AppColors.sessionRingTrack,
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: Curves.easeInOutCubic.transform(progress),
              heightFactor: 1,
              child: const ColoredBox(color: AppColors.accent),
            ),
          ),
        ),
      ),
    );
  }
}
