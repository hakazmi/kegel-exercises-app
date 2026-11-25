import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';

import '../../app/l10n/app_localizations.dart';
import '../../app/theme/tokens.dart';
import '../../core/motion/app_motion.dart';

/// Side "X-ray" view of the male pelvis with the pelvic floor drawn live:
/// on Squeeze the glowing muscle sling lifts up and in, ripples pulse under
/// it and an up arrow shows the direction; on Relax it lowers back down.
///
/// The body is a still image (sling removed); the sling is painted on top
/// and morphs between its relaxed and lifted shapes, so it always matches
/// the practice timer.
/// What the side demo highlights besides the muscle itself.
enum SideDemoMode {
  /// The pelvic floor lifting and lowering.
  kegel,

  /// After urinating: the squeeze pushes the last drops out of the urethra.
  afterDribble,

  /// Urge control: the bladder's urge signal calms while you squeeze.
  urgeControl,
}

class SidePelvicDemo extends StatefulWidget {
  const SidePelvicDemo({
    super.key,
    required this.squeezing,
    this.mode = SideDemoMode.kegel,
    this.size = 280,
    this.squeezeTime = const Duration(milliseconds: 1200),
    this.relaxTime = const Duration(milliseconds: 2000),
  });

  /// True while the user should squeeze (and hold); false to relax.
  final bool squeezing;
  final SideDemoMode mode;
  final double size;

  /// How long the lift and the release take on screen.
  final Duration squeezeTime;
  final Duration relaxTime;

  static const String baseAsset = 'assets/images/onboarding/pf_side_base.jpg';

  @override
  State<SidePelvicDemo> createState() => _SidePelvicDemoState();
}

class _SidePelvicDemoState extends State<SidePelvicDemo>
    with TickerProviderStateMixin {
  late final AnimationController _lift = AnimationController(
    vsync: this,
    value: widget.squeezing ? 1 : 0,
  );
  AnimationController? _pulse;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!AppMotion.isReduced(context) && _pulse == null) {
      _pulse = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1400),
      )..repeat();
    }
  }

  @override
  void didUpdateWidget(covariant SidePelvicDemo old) {
    super.didUpdateWidget(old);
    if (old.squeezing != widget.squeezing) {
      if (AppMotion.isReduced(context)) {
        _lift.value = widget.squeezing ? 1 : 0;
      } else {
        _lift.animateTo(
          widget.squeezing ? 1 : 0,
          duration: widget.squeezing ? widget.squeezeTime : widget.relaxTime,
          curve: widget.squeezing ? Curves.easeOutCubic : Curves.easeInOutSine,
        );
      }
    }
  }

  @override
  void dispose() {
    _lift.dispose();
    _pulse?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Listenable anim = Listenable.merge(<Listenable?>[_lift, _pulse]);
    return Semantics(
      image: true,
      label: l10n.pfDemoSemantic,
      excludeSemantics: true,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: _SlingPainter.backdrop,
          borderRadius: AppRadii.xlAll,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.ink.withValues(alpha: 0.25),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              SidePelvicDemo.baseAsset,
              fit: BoxFit.cover,
              gaplessPlayback: true,
              excludeFromSemantics: true,
            ),
            AnimatedBuilder(
              animation: anim,
              builder: (BuildContext context, Widget? _) => CustomPaint(
                painter: _SlingPainter(
                  lift: _lift.value,
                  pulse: _pulse?.value ?? 0.35,
                  squeezing: widget.squeezing,
                  mode: widget.mode,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Paints the sling, ripples and arrow in the base image's 900×900 space.
class _SlingPainter extends CustomPainter {
  _SlingPainter({
    required this.lift,
    required this.pulse,
    required this.squeezing,
    this.mode = SideDemoMode.kegel,
  });

  final SideDemoMode mode;

  /// 0 = relaxed shape, 1 = lifted (squeezed) shape.
  final double lift;

  /// 0–1 looping value for the ripples.
  final double pulse;
  final bool squeezing;

  static const Color backdrop = Color(0xFF0D0D0D);
  static const Color _muscle = Color(0xFFFF4A1C);
  static const Color _muscleHot = Color(0xFFFF7A3D);
  static const double _space = 900;

  // Main sling: tailbone (left) → under the bladder → toward the pubic
  // bone (right). Relaxed and lifted control points.
  static const List<Offset> _mainRelax = <Offset>[
    Offset(200, 218),
    Offset(262, 345),
    Offset(400, 402),
    Offset(498, 384),
    Offset(580, 366),
    Offset(640, 330),
    Offset(676, 306),
  ];
  static const List<Offset> _mainLift = <Offset>[
    Offset(196, 200),
    Offset(262, 300),
    Offset(400, 352),
    Offset(498, 336),
    Offset(580, 320),
    Offset(640, 292),
    Offset(680, 276),
  ];

  // Second, lower front strand.
  static const List<Offset> _frontRelax = <Offset>[
    Offset(430, 398),
    Offset(520, 410),
    Offset(600, 388),
    Offset(664, 330),
  ];
  static const List<Offset> _frontLift = <Offset>[
    Offset(430, 352),
    Offset(520, 362),
    Offset(600, 342),
    Offset(668, 296),
  ];

  /// Where the ripples and the arrow sit (just under the sling's low point).
  static const Offset _perineum = Offset(430, 440);

  List<Offset> _mix(List<Offset> a, List<Offset> b, double t) => <Offset>[
    for (int i = 0; i < a.length; i++) Offset.lerp(a[i], b[i], t)!,
  ];

  Path _main(List<Offset> p) => Path()
    ..moveTo(p[0].dx, p[0].dy)
    ..cubicTo(p[1].dx, p[1].dy, p[2].dx, p[2].dy, p[3].dx, p[3].dy)
    ..cubicTo(p[4].dx, p[4].dy, p[5].dx, p[5].dy, p[6].dx, p[6].dy);

  Path _front(List<Offset> p) => Path()
    ..moveTo(p[0].dx, p[0].dy)
    ..cubicTo(p[1].dx, p[1].dy, p[2].dx, p[2].dy, p[3].dx, p[3].dy);

  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.width / _space;
    canvas.save();
    canvas.scale(s);

    final double t = Curves.easeInOut.transform(lift.clamp(0.0, 1.0));
    final Path main = _main(_mix(_mainRelax, _mainLift, t));
    final Path front = _front(_mix(_frontRelax, _frontLift, t));
    final Color body = Color.lerp(_muscle, _muscleHot, t)!;

    // Ripples under the sling while it works (squeeze / hold).
    final double rippleStrength = t;
    if (rippleStrength > 0.02) {
      final Offset c = _perineum + Offset(0, -40 * t);
      for (int i = 0; i < 3; i++) {
        final double phase = (pulse + i / 3) % 1;
        final double r = 40 + 90 * phase;
        final double a = (1 - phase) * 0.55 * rippleStrength;
        canvas.drawArc(
          Rect.fromCircle(center: c, radius: r),
          math.pi * 0.15,
          math.pi * 0.7,
          false,
          Paint()
            ..color = _muscle.withValues(alpha: a)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 5
            ..strokeCap = StrokeCap.round,
        );
      }
    }

    // Soft outer glow, then the muscle body, then a bright core line.
    final Paint glow = Paint()
      ..color = body.withValues(alpha: 0.45 + 0.25 * t)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 46
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22);
    canvas.drawPath(main, glow);
    canvas.drawPath(front, glow..strokeWidth = 30);

    final Paint muscle = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(200, 220),
        const Offset(680, 300),
        <Color>[
          body.withValues(alpha: 0.9),
          body,
          body.withValues(alpha: 0.85),
        ],
        <double>[0, 0.5, 1],
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth =
          24 -
          4 *
              t // a touch thinner as it shortens
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(main, muscle);
    canvas.drawPath(front, muscle..strokeWidth = 14 - 2 * t);

    canvas.drawPath(
      main,
      Paint()
        ..color = const Color(0xFFFFC2A6).withValues(alpha: 0.55 + 0.3 * t)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );

    switch (mode) {
      case SideDemoMode.afterDribble:
        _drops(canvas, t);
      case SideDemoMode.urgeControl:
        _urge(canvas, t);
      case SideDemoMode.kegel:
        break;
    }

    // Direction arrow: up while squeezing, down while letting go.
    // The down arrow fades out as the sling settles back to rest.
    final double arrowA = squeezing ? 0.4 + 0.6 * t : 0;
    final double relaxA = squeezing ? 0 : t;
    if (arrowA > 0.02) {
      _arrow(
        canvas,
        _perineum + Offset(0, 60 - 30 * t),
        up: true,
        alpha: arrowA,
      );
    }
    if (relaxA > 0.02) {
      _arrow(
        canvas,
        _perineum + Offset(0, 10 + 40 * (1 - t)),
        up: false,
        alpha: relaxA * 0.8,
      );
    }

    canvas.restore();
  }

  void _arrow(
    Canvas canvas,
    Offset c, {
    required bool up,
    required double alpha,
  }) {
    final double d = up ? -1 : 1;
    final Path p = Path()
      ..moveTo(c.dx, c.dy + d * 34)
      ..lineTo(c.dx - 26, c.dy + d * 6)
      ..lineTo(c.dx - 11, c.dy + d * 6)
      ..lineTo(c.dx - 11, c.dy - d * 30)
      ..lineTo(c.dx + 11, c.dy - d * 30)
      ..lineTo(c.dx + 11, c.dy + d * 6)
      ..lineTo(c.dx + 26, c.dy + d * 6)
      ..close();
    canvas.drawPath(
      p,
      Paint()
        ..color = const Color(0xFFFFFFFF).withValues(alpha: alpha * 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    canvas.drawPath(
      p,
      Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: alpha),
    );
  }

  // Urethra inside the penis (900-space), then the fall below the tip.
  static const Offset _u0 = Offset(776, 333);
  static const Offset _u1 = Offset(796, 392);
  static const Offset _u2 = Offset(803, 455);
  static const Offset _tip = Offset(803, 505);
  static const Offset _floor = Offset(803, 640);
  static const Offset _bladder = Offset(468, 190);

  Offset _urethraAt(double u) {
    // 0–0.7 inside the urethra (cubic), 0.7–1 falling from the tip.
    if (u < 0.7) {
      final double k = u / 0.7;
      final double a = 1 - k;
      return _u0 * (a * a * a) +
          _u1 * (3 * a * a * k) +
          _u2 * (3 * a * k * k) +
          _tip * (k * k * k);
    }
    final double k = (u - 0.7) / 0.3;
    return Offset.lerp(_tip, _floor, k * k)!;
  }

  /// After-dribble: a faint urethra line, and on the squeeze the last drops
  /// travel out along it and fall away.
  void _drops(Canvas canvas, double t) {
    final Path tube = Path()
      ..moveTo(_u0.dx, _u0.dy)
      ..cubicTo(_u1.dx, _u1.dy, _u2.dx, _u2.dy, _tip.dx, _tip.dy);
    canvas.drawPath(
      tube,
      Paint()
        ..color = const Color(0xFFFFD36B).withValues(alpha: 0.18 + 0.25 * t)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    if (!squeezing || t < 0.15) {
      return;
    }
    for (int i = 0; i < 3; i++) {
      final double u = (pulse + i / 3) % 1;
      final Offset p = _urethraAt(u);
      final double a =
          (u < 0.1 ? u / 0.1 : (u > 0.85 ? (1 - u) / 0.15 : 1)) * t;
      final double r = 9;
      // Teardrop: a circle with a point trailing upward.
      final Path drop = Path()
        ..moveTo(p.dx, p.dy - r * 2)
        ..quadraticBezierTo(p.dx + r, p.dy - r * 0.4, p.dx + r, p.dy)
        ..arcToPoint(Offset(p.dx - r, p.dy), radius: Radius.circular(r))
        ..quadraticBezierTo(p.dx - r, p.dy - r * 0.4, p.dx, p.dy - r * 2)
        ..close();
      canvas.drawPath(
        drop,
        Paint()
          ..color = const Color(0xFFFFC93C).withValues(alpha: 0.45 * a)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
      canvas.drawPath(
        drop,
        Paint()..color = const Color(0xFFFFD86B).withValues(alpha: a),
      );
    }
  }

  /// Urge control: warm "urge" waves pulse out of the bladder while
  /// relaxed; on the squeeze they fade and a calm green halo settles.
  void _urge(Canvas canvas, double t) {
    final double urge = 1 - t;
    if (urge > 0.03) {
      for (int i = 0; i < 3; i++) {
        final double ph = (pulse + i / 3) % 1;
        canvas.drawCircle(
          _bladder,
          70 + 70 * ph,
          Paint()
            ..color = _muscle.withValues(alpha: (1 - ph) * 0.6 * urge)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 5,
        );
      }
    }
    if (t > 0.03) {
      canvas.drawCircle(
        _bladder,
        96,
        Paint()
          ..color = const Color(0xFF34C77B).withValues(alpha: 0.35 * t)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 12
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
      canvas.drawCircle(
        _bladder,
        96,
        Paint()
          ..color = const Color(0xFF34C77B).withValues(alpha: 0.8 * t)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }
  }

  @override
  bool shouldRepaint(_SlingPainter old) =>
      old.lift != lift ||
      old.pulse != pulse ||
      old.squeezing != squeezing ||
      old.mode != mode;
}

/// The side X-ray demo running on its own: squeeze (lift and hold), then
/// relax, over and over, with the current phase shown in a label.
class SidePelvicDemoLoop extends StatefulWidget {
  const SidePelvicDemoLoop({
    super.key,
    this.mode = SideDemoMode.kegel,
    this.size = 300,
    this.squeeze = const Duration(milliseconds: 3000),
    this.relax = const Duration(milliseconds: 3000),
  });

  final SideDemoMode mode;
  final double size;
  final Duration squeeze;
  final Duration relax;

  @override
  State<SidePelvicDemoLoop> createState() => _SidePelvicDemoLoopState();
}

class _SidePelvicDemoLoopState extends State<SidePelvicDemoLoop> {
  bool _squeezing = false;
  Timer? _timer;
  bool _running = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_running && !AppMotion.isReduced(context)) {
      _running = true;
      // Start relaxed for a beat so the first lift is visible.
      _timer = Timer(const Duration(milliseconds: 700), _flip);
    }
  }

  void _flip() {
    if (!mounted) {
      return;
    }
    setState(() => _squeezing = !_squeezing);
    _timer = Timer(_squeezing ? widget.squeeze : widget.relax, _flip);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    // With reduced motion, show the lifted (squeezed) position still.
    final bool squeezing = _running ? _squeezing : true;
    return Stack(
      children: [
        SidePelvicDemo(
          squeezing: squeezing,
          size: widget.size,
          mode: widget.mode,
        ),
        Positioned(
          left: AppSpacing.sm,
          top: AppSpacing.sm,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: squeezing ? AppColors.success : AppColors.surface,
              borderRadius: AppRadii.pillAll,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  squeezing
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  size: 14,
                  color: squeezing ? AppColors.textOnPrimary : AppColors.ink,
                ),
                const SizedBox(width: 4),
                Text(
                  (squeezing
                          ? l10n.t1PhaseSqueeze
                          : (widget.mode == SideDemoMode.urgeControl
                                ? l10n.hgUrgeLabel
                                : l10n.t1PhaseRelax))
                      .toUpperCase(),
                  style: AppTypography.caption.copyWith(
                    color: squeezing ? AppColors.textOnPrimary : AppColors.ink,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
