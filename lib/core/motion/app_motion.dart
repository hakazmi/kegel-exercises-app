import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

/// Motion language for the app.
///
/// Mirrors the PoseCoach dashboard: cards slide in from the left or right
/// (64 dp, decelerate), hero panels drop in from above with a small
/// overshoot, entries are staggered, numbers count up, and a few quiet loops
/// (pulse, float, nudge) mark what is active.
///
/// [reduce] turns every animation into its end state. `test/flutter_test_config.dart`
/// sets it so widget tests never wait on loops. The system "remove
/// animations" setting has the same effect at runtime.
abstract final class AppMotion {
  /// Global switch: true renders end states only (tests, accessibility).
  static bool reduce = false;

  static const Duration slide = Duration(milliseconds: 460);
  static const Duration drop = Duration(milliseconds: 560);
  static const Duration quick = Duration(milliseconds: 220);
  static const Duration countUp = Duration(milliseconds: 900);
  static const Duration staggerStep = Duration(milliseconds: 60);

  static const double slideDistance = 64;
  static const double dropDistance = 42;

  /// Decelerate, like Android DecelerateInterpolator(1.6).
  static const Curve slideCurve = Curves.easeOutQuart;

  /// Gentle overshoot, like OvershootInterpolator(1.15).
  static const Curve dropCurve = Cubic(0.34, 1.32, 0.64, 1);

  /// Stagger delay for the [index]th entry in a list.
  static Duration stagger(int index, {Duration base = Duration.zero}) =>
      base + staggerStep * index;

  /// True when animations should be skipped for this context.
  static bool isReduced(BuildContext context) =>
      reduce || (MediaQuery.maybeDisableAnimationsOf(context) ?? false);
}

/// Direction a [Reveal] enters from.
enum RevealFrom { left, right, drop, rise, fade }

/// One-shot entrance: fades in while sliding from a side, dropping from
/// above, or rising from below. Plays once per widget instance.
class Reveal extends StatefulWidget {
  const Reveal({
    super.key,
    required this.child,
    this.from = RevealFrom.rise,
    this.delay = Duration.zero,
    this.duration,
    this.distance,
  });

  final Widget child;
  final RevealFrom from;
  final Duration delay;
  final Duration? duration;
  final double? distance;

  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _timer;
  bool _started = false;

  bool get _isDrop => widget.from == RevealFrom.drop;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration ?? (_isDrop ? AppMotion.drop : AppMotion.slide),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) {
      return;
    }
    _started = true;
    if (AppMotion.isReduced(context)) {
      _controller.value = 1;
      return;
    }
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      _timer = Timer(widget.delay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Curve curve = _isDrop ? AppMotion.dropCurve : AppMotion.slideCurve;
    final double distance = widget.distance ??
        (_isDrop ? AppMotion.dropDistance : AppMotion.slideDistance);
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (BuildContext context, Widget? child) {
        final double t = _controller.value;
        if (t >= 1) {
          return child!;
        }
        final double eased = curve.transform(t);
        final double remaining = 1 - eased;
        final Offset offset = switch (widget.from) {
          RevealFrom.left => Offset(-distance * remaining, 0),
          RevealFrom.right => Offset(distance * remaining, 0),
          RevealFrom.drop => Offset(0, -distance * remaining),
          RevealFrom.rise => Offset(0, distance * 0.5 * remaining),
          RevealFrom.fade => Offset.zero,
        };
        // Opacity uses the un-overshot value so it never exceeds 1.
        final double opacity = Curves.easeOut.transform(t).clamp(0.0, 1.0);
        return Opacity(
          opacity: opacity,
          child: Transform.translate(offset: offset, child: child),
        );
      },
    );
  }
}

/// Integer that counts up to [value] (and animates between later values).
///
/// Screen readers get the final text only.
class CountUpText extends StatelessWidget {
  const CountUpText({
    super.key,
    required this.value,
    required this.format,
    this.style,
    this.delay = Duration.zero,
    this.textAlign,
  });

  final int value;
  final String Function(int value) format;
  final TextStyle? style;
  final Duration delay;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final String finalText = format(value);
    if (AppMotion.isReduced(context) || value == 0) {
      return Text(finalText, style: style, textAlign: textAlign);
    }
    return Semantics(
      label: finalText,
      child: ExcludeSemantics(
        child: _DelayedTween(
          delay: delay,
          end: value.toDouble(),
          duration: AppMotion.countUp,
          builder: (BuildContext context, double v) => Text(
            format(v.round()),
            style: style,
            textAlign: textAlign,
          ),
        ),
      ),
    );
  }
}

/// Animates 0 → [end] after [delay]; later changes animate from the
/// current value.
class _DelayedTween extends StatefulWidget {
  const _DelayedTween({
    required this.end,
    required this.duration,
    required this.builder,
    this.delay = Duration.zero,
  });

  final double end;
  final Duration duration;
  final Duration delay;
  final Widget Function(BuildContext context, double value) builder;

  @override
  State<_DelayedTween> createState() => _DelayedTweenState();
}

class _DelayedTweenState extends State<_DelayedTween> {
  double _target = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.delay == Duration.zero) {
      _target = widget.end;
    } else {
      _timer = Timer(widget.delay, () {
        if (mounted) {
          setState(() => _target = widget.end);
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant _DelayedTween oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.end != widget.end && _timer?.isActive != true) {
      _target = widget.end;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: _target),
      duration: widget.duration,
      curve: Curves.easeOutCubic,
      builder: (BuildContext context, double v, Widget? _) =>
          widget.builder(context, v),
    );
  }
}

/// Progress value (0..1) that fills from 0 on first build and eases to
/// new values afterwards.
class AnimatedFraction extends StatelessWidget {
  const AnimatedFraction({
    super.key,
    required this.value,
    required this.builder,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 1100),
  });

  final double value;
  final Duration delay;
  final Duration duration;
  final Widget Function(BuildContext context, double value) builder;

  @override
  Widget build(BuildContext context) {
    final double clamped = value.clamp(0.0, 1.0);
    if (AppMotion.isReduced(context)) {
      return builder(context, clamped);
    }
    return _DelayedTween(
      end: clamped,
      delay: delay,
      duration: duration,
      builder: builder,
    );
  }
}

/// Base for the quiet looping effects; stops when motion is reduced.
abstract class _LoopState<T extends StatefulWidget> extends State<T>
    with SingleTickerProviderStateMixin {
  AnimationController? controller;

  Duration get period;
  bool get reverse => false;
  bool get active => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    final bool run = active && !AppMotion.isReduced(context);
    if (run && controller == null) {
      controller = AnimationController(vsync: this, duration: period)
        ..repeat(reverse: reverse);
    } else if (!run && controller != null) {
      controller!.dispose();
      controller = null;
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

/// Soft expanding halo behind [child] to mark the active step.
class PulseHalo extends StatefulWidget {
  const PulseHalo({
    super.key,
    required this.child,
    required this.color,
    this.size = 36,
    this.active = true,
  });

  final Widget child;
  final Color color;
  final double size;
  final bool active;

  @override
  State<PulseHalo> createState() => _PulseHaloState();
}

class _PulseHaloState extends _LoopState<PulseHalo> {
  @override
  Duration get period => const Duration(milliseconds: 1800);

  @override
  bool get active => widget.active;

  @override
  Widget build(BuildContext context) {
    final AnimationController? c = controller;
    if (c == null) {
      return widget.child;
    }
    return AnimatedBuilder(
      animation: c,
      child: widget.child,
      builder: (BuildContext context, Widget? child) {
        final double t = c.value;
        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            for (final double phase in <double>[0, 0.5])
              _haloRing((t + phase) % 1),
            child!,
          ],
        );
      },
    );
  }

  Widget _haloRing(double t) {
    final double scale = 1 + 0.75 * Curves.easeOut.transform(t);
    return IgnorePointer(
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withValues(alpha: 0.28 * (1 - t)),
          ),
        ),
      ),
    );
  }
}

/// Gentle up-and-down float (icons, illustrations).
class FloatBob extends StatefulWidget {
  const FloatBob({
    super.key,
    required this.child,
    this.lift = 4,
    this.period = const Duration(milliseconds: 2400),
  });

  final Widget child;
  final double lift;
  final Duration period;

  @override
  State<FloatBob> createState() => _FloatBobState();
}

class _FloatBobState extends _LoopState<FloatBob> {
  @override
  Duration get period => widget.period;

  @override
  bool get reverse => true;

  @override
  Widget build(BuildContext context) {
    final AnimationController? c = controller;
    if (c == null) {
      return widget.child;
    }
    return AnimatedBuilder(
      animation: c,
      child: widget.child,
      builder: (BuildContext context, Widget? child) {
        final double y =
            -widget.lift * Curves.easeInOut.transform(c.value);
        return Transform.translate(offset: Offset(0, y), child: child);
      },
    );
  }
}

/// Small "go" nudge to the right, twice, then a pause (CTA arrows).
class NudgeArrow extends StatefulWidget {
  const NudgeArrow({
    super.key,
    this.icon = Icons.arrow_forward_rounded,
    this.color,
    this.size = 20,
  });

  final IconData icon;
  final Color? color;
  final double size;

  @override
  State<NudgeArrow> createState() => _NudgeArrowState();
}

class _NudgeArrowState extends _LoopState<NudgeArrow> {
  @override
  Duration get period => const Duration(milliseconds: 2400);

  // 0 → 1 → 0 → 1 → 0, then rest — same keyframes as the PoseCoach CTA.
  static double _shift(double t) {
    if (t >= 4 / 6) {
      return 0;
    }
    final double local = (t * 6) % 2;
    return local <= 1 ? local : 2 - local;
  }

  @override
  Widget build(BuildContext context) {
    final Widget icon =
        Icon(widget.icon, size: widget.size, color: widget.color);
    final AnimationController? c = controller;
    if (c == null) {
      return icon;
    }
    return AnimatedBuilder(
      animation: c,
      child: icon,
      builder: (BuildContext context, Widget? child) => Transform.translate(
        offset: Offset(4 * Curves.easeInOut.transform(_shift(c.value)), 0),
        child: child,
      ),
    );
  }
}

/// Diagonal light sweep across [child] every few seconds (premium CTA sheen).
class ShimmerSweep extends StatefulWidget {
  const ShimmerSweep({
    super.key,
    required this.child,
    required this.borderRadius,
    this.active = true,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final bool active;

  @override
  State<ShimmerSweep> createState() => _ShimmerSweepState();
}

class _ShimmerSweepState extends _LoopState<ShimmerSweep> {
  @override
  Duration get period => const Duration(milliseconds: 3600);

  @override
  bool get active => widget.active;

  @override
  Widget build(BuildContext context) {
    final AnimationController? c = controller;
    if (c == null) {
      return widget.child;
    }
    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: ClipRRect(
              borderRadius: widget.borderRadius,
              child: AnimatedBuilder(
                animation: c,
                builder: (BuildContext context, Widget? _) {
                  // Sweep during the first 35% of the period, then rest.
                  final double t = (c.value / 0.35).clamp(0.0, 1.0);
                  if (t >= 1) {
                    return const SizedBox.shrink();
                  }
                  return FractionalTranslation(
                    translation: Offset(-1.2 + 2.4 * t, 0),
                    child: const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: <Color>[
                            Color(0x00FFFFFF),
                            Color(0x26FFFFFF),
                            Color(0x00FFFFFF),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Scales down slightly while pressed and gives a light haptic tick.
class PressScale extends StatefulWidget {
  const PressScale({
    super.key,
    required this.child,
    required this.onTap,
    this.scale = 0.97,
    this.haptic = true,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final bool haptic;
  final String? semanticLabel;

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool _down = false;

  void _set(bool down) {
    if (_down != down && mounted) {
      setState(() => _down = down);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool enabled = widget.onTap != null;
    final bool reduced = AppMotion.isReduced(context);
    return Semantics(
      button: enabled,
      enabled: enabled,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => _set(true) : null,
        onTapCancel: enabled ? () => _set(false) : null,
        onTapUp: enabled ? (_) => _set(false) : null,
        onTap: enabled
            ? () {
                if (widget.haptic) {
                  unawaited(HapticFeedback.selectionClick());
                }
                widget.onTap!();
              }
            : null,
        child: AnimatedScale(
          scale: _down && !reduced ? widget.scale : 1,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}

/// Circle that pops in and draws a check mark (completion moments).
class AnimatedCheckBadge extends StatefulWidget {
  const AnimatedCheckBadge({
    super.key,
    required this.size,
    required this.color,
    required this.checkColor,
    this.play = true,
    this.delay = Duration.zero,
    this.strokeWidth,
  });

  final double size;
  final Color color;
  final Color checkColor;

  /// When false the badge renders complete with no animation.
  final bool play;
  final Duration delay;
  final double? strokeWidth;

  @override
  State<AnimatedCheckBadge> createState() => _AnimatedCheckBadgeState();
}

class _AnimatedCheckBadgeState extends State<AnimatedCheckBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );
  Timer? _timer;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      _started = true;
      _run();
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedCheckBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.play && !oldWidget.play) {
      _controller.value = 0;
      _run();
    }
  }

  void _run() {
    if (!widget.play || AppMotion.isReduced(context)) {
      _controller.value = 1;
      return;
    }
    _timer?.cancel();
    _timer = Timer(widget.delay, () {
      if (mounted) {
        _controller.forward(from: 0);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? _) {
        final double t = _controller.value;
        final double pop = const Interval(0, 0.55, curve: AppMotion.dropCurve)
            .transform(t);
        final double draw =
            const Interval(0.35, 1, curve: Curves.easeOutCubic).transform(t);
        return Transform.scale(
          scale: pop,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: CustomPaint(
              painter: _CheckPainter(
                fill: widget.color,
                stroke: widget.checkColor,
                progress: draw,
                strokeWidth: widget.strokeWidth ?? widget.size * 0.1,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CheckPainter extends CustomPainter {
  _CheckPainter({
    required this.fill,
    required this.stroke,
    required this.progress,
    required this.strokeWidth,
  });

  final Color fill;
  final Color stroke;
  final double progress;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset c = size.center(Offset.zero);
    canvas.drawCircle(c, size.width / 2, Paint()..color = fill);
    if (progress <= 0) {
      return;
    }
    final Path path = Path()
      ..moveTo(size.width * 0.28, size.height * 0.52)
      ..lineTo(size.width * 0.44, size.height * 0.67)
      ..lineTo(size.width * 0.73, size.height * 0.36);
    final Path partial = Path();
    for (final ui in path.computeMetrics()) {
      partial.addPath(ui.extractPath(0, ui.length * progress), Offset.zero);
    }
    canvas.drawPath(
      partial,
      Paint()
        ..color = stroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _CheckPainter old) =>
      old.progress != progress || old.fill != fill || old.stroke != stroke;
}

/// Expanding rings and small sparks around a completion badge.
///
/// Calm, clinical celebration: no confetti, no emoji.
class CompletionBurst extends StatefulWidget {
  const CompletionBurst({
    super.key,
    required this.size,
    required this.color,
    this.delay = const Duration(milliseconds: 250),
  });

  final double size;
  final Color color;
  final Duration delay;

  @override
  State<CompletionBurst> createState() => _CompletionBurstState();
}

class _CompletionBurstState extends State<CompletionBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );
  Timer? _timer;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) {
      return;
    }
    _started = true;
    if (AppMotion.isReduced(context)) {
      _controller.value = 1;
      return;
    }
    _timer = Timer(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? _) => CustomPaint(
          size: Size.square(widget.size),
          painter: _BurstPainter(t: _controller.value, color: widget.color),
        ),
      ),
    );
  }
}

class _BurstPainter extends CustomPainter {
  _BurstPainter({required this.t, required this.color});

  final double t;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (t <= 0 || t >= 1) {
      return;
    }
    final Offset c = size.center(Offset.zero);
    final double r = size.width / 2;
    for (int i = 0; i < 2; i++) {
      final double local = ((t - i * 0.18) / 0.82).clamp(0.0, 1.0);
      if (local <= 0) {
        continue;
      }
      final double eased = Curves.easeOutCubic.transform(local);
      canvas.drawCircle(
        c,
        r * (0.45 + 0.55 * eased),
        Paint()
          ..color = color.withValues(alpha: 0.35 * (1 - local))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
    const int sparks = 10;
    final double travel = Curves.easeOutQuart.transform(t);
    for (int i = 0; i < sparks; i++) {
      final double angle = (math.pi * 2 / sparks) * i + 0.3;
      final double dist = r * (0.5 + 0.45 * travel);
      final Offset p = c + Offset(math.cos(angle), math.sin(angle)) * dist;
      canvas.drawCircle(
        p,
        (i.isEven ? 3.0 : 2.0) * (1 - t),
        Paint()..color = color.withValues(alpha: 1 - t),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BurstPainter old) => old.t != t;
}
