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
class SidePelvicDemo extends StatefulWidget {
  const SidePelvicDemo({
    super.key,
    required this.squeezing,
    this.size = 280,
    this.squeezeTime = const Duration(milliseconds: 1200),
    this.relaxTime = const Duration(milliseconds: 2000),
  });

  /// True while the user should squeeze (and hold); false to relax.
  final bool squeezing;
  final double size;

  /// How long the lift and the release take on screen.
  final Duration squeezeTime;
  final Duration relaxTime;

  static const String baseAsset =
      'assets/images/onboarding/pf_side_base.jpg';

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
  });

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
        <Color>[body.withValues(alpha: 0.9), body, body.withValues(alpha: 0.85)],
        <double>[0, 0.5, 1],
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24 - 4 * t // a touch thinner as it shortens
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

    // Direction arrow: up while squeezing, down while letting go.
    // The down arrow fades out as the sling settles back to rest.
    final double arrowA = squeezing ? 0.4 + 0.6 * t : 0;
    final double relaxA = squeezing ? 0 : t;
    if (arrowA > 0.02) {
      _arrow(canvas, _perineum + Offset(0, 60 - 30 * t), up: true, alpha: arrowA);
    }
    if (relaxA > 0.02) {
      _arrow(canvas, _perineum + Offset(0, 10 + 40 * (1 - t)), up: false, alpha: relaxA * 0.8);
    }

    canvas.restore();
  }

  void _arrow(Canvas canvas, Offset c, {required bool up, required double alpha}) {
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

  @override
  bool shouldRepaint(_SlingPainter old) =>
      old.lift != lift || old.pulse != pulse || old.squeezing != squeezing;
}
