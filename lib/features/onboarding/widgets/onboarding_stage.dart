import 'dart:math' as math;
import 'dart:ui' show ImageFilter, PathMetric;

import 'package:material_ui/material_ui.dart';

import '../../../app/theme/tokens.dart';
import '../../../core/motion/app_motion.dart';

/// Cut-out art for the onboarding heroes (background removed with rembg).
abstract final class OnboardingArt {
  static const String _dir = 'assets/images/onboarding/cutouts';
  static const String welcomeMan = '$_dir/welcome_man.png';
  static const String pelvis = '$_dir/pelvis.png';
  static const String goalShield = '$_dir/goal_shield.png';
  static const String safetyMan = '$_dir/safety_man.png';
  static const String xray = '$_dir/xray.jpg';
  static const String thinkingMan = '$_dir/thinking_man.png';
  static const String timeMan = '$_dir/time_man.png';
  static const String stopwatch = '$_dir/stopwatch.png';
  static const String tutorialWhere = '$_dir/tutorial_where.png';
  static const String tutorialFind = '$_dir/tutorial_find.png';

  /// Side-view X-ray style PF muscle demo (still frames + GIF).
  static const String sideSqueeze =
      'assets/images/onboarding/pf_side_squeeze.jpg';
  static const String sideRelax = 'assets/images/onboarding/pf_side_relax.jpg';
  static const String sideSqueezeRelaxGif =
      'assets/images/onboarding/pf_side_squeeze_relax.gif';
}

/// Open hero area (no card): soft pastel blobs, a glowing floor and the
/// scene's layers on top. Layers may overflow the top for a pop-out look.
class OnboardingStage extends StatelessWidget {
  const OnboardingStage({
    super.key,
    required this.height,
    required this.children,
    this.blob = AppColors.lavender,
    this.floor = AppColors.pistachio,
    this.semanticLabel,
  });

  final double height;
  final List<Widget> children;

  /// Colour of the large soft shape behind the scene.
  final Color blob;

  /// Colour of the glowing floor the figures stand on.
  final Color floor;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: semanticLabel != null,
      label: semanticLabel,
      child: SizedBox(
        height: height,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Big organic blob behind everything.
            Positioned(
              right: -40,
              top: height * 0.02,
              child: _Blob(
                width: height * 1.05,
                height: height * 0.9,
                color: blob.withValues(alpha: 0.35),
              ),
            ),
            Positioned(
              left: -50,
              top: height * 0.3,
              child: _Blob(
                width: height * 0.7,
                height: height * 0.6,
                color: floor.withValues(alpha: 0.3),
                flip: true,
              ),
            ),
            // Glowing floor ellipse.
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: height * 0.16,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 14, sigmaY: 6),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      radius: 0.9,
                      colors: <Color>[
                        floor.withValues(alpha: 0.75),
                        floor.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({
    required this.width,
    required this.height,
    required this.color,
    this.flip = false,
  });

  final double width;
  final double height;
  final Color color;
  final bool flip;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Transform.rotate(
        angle: flip ? -0.5 : 0.35,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(height * 0.6),
              topRight: Radius.circular(height * 0.4),
              bottomLeft: Radius.circular(height * 0.35),
              bottomRight: Radius.circular(height * 0.65),
            ),
          ),
        ),
      ),
    );
  }
}

/// A cut-out figure standing on the floor: soft contact shadow, optional
/// gentle float. Sized by [height]; width follows the image.
class CutoutFigure extends StatelessWidget {
  const CutoutFigure({
    super.key,
    required this.asset,
    required this.height,
    this.float = true,
    this.shadow = true,
    this.shadowWidth = 0.7,
    this.fadeBottom = false,
  });

  final String asset;
  final double height;
  final bool float;
  final bool shadow;

  /// Fades the bottom edge (for half-body cut-outs that end mid-frame).
  final bool fadeBottom;

  /// Shadow width as a fraction of the figure's laid-out width.
  final double shadowWidth;

  @override
  Widget build(BuildContext context) {
    Widget image = Image.asset(
      asset,
      height: height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      gaplessPlayback: true,
      excludeFromSemantics: true,
    );
    if (fadeBottom) {
      image = ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (Rect r) => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: <double>[0, 0.78, 1],
          colors: <Color>[
            Color(0xFFFFFFFF),
            Color(0xFFFFFFFF),
            Color(0x00FFFFFF),
          ],
        ).createShader(r),
        child: image,
      );
    }
    final Widget figure = float
        ? FloatBob(
            lift: 4,
            period: const Duration(milliseconds: 3200),
            child: image,
          )
        : image;
    if (!shadow) {
      return figure;
    }
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        Positioned(
          bottom: -height * 0.02,
          child: FractionalTranslation(
            translation: Offset.zero,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 3),
              child: Container(
                width: height * 0.45 * shadowWidth / 0.7,
                height: height * 0.05,
                decoration: BoxDecoration(
                  color: AppColors.ink.withValues(alpha: 0.35),
                  borderRadius: AppRadii.pillAll,
                ),
              ),
            ),
          ),
        ),
        figure,
      ],
    );
  }
}

/// Frosted white tile holding an image or icon, with an optional green
/// check badge on its corner.
class GlassTile extends StatelessWidget {
  const GlassTile({
    super.key,
    required this.size,
    required this.child,
    this.badge = false,
    this.badgeRight = false,
    this.padding = AppSpacing.xs,
    this.tint = AppColors.surface,
  });

  final double size;
  final Widget child;
  final bool badge;

  /// Badge on the top-right corner instead of the top-left.
  final bool badgeRight;
  final double padding;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Container(
              padding: EdgeInsets.all(padding),
              decoration: BoxDecoration(
                color: tint.withValues(alpha: 0.82),
                borderRadius: BorderRadius.circular(size * 0.2),
                border: Border.all(color: AppColors.surface, width: 3),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.22),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(size * 0.14),
                child: child,
              ),
            ),
          ),
          if (badge)
            Positioned(
              top: -10,
              left: badgeRight ? null : -10,
              right: badgeRight ? -10 : null,
              child: const _CheckBadge(),
            ),
        ],
      ),
    );
  }
}

class _CheckBadge extends StatelessWidget {
  const _CheckBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: AppColors.success,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.surface, width: 3),
        boxShadow: AppElevation.level1,
      ),
      child: const Icon(
        Icons.check_rounded,
        size: 16,
        color: AppColors.textOnPrimary,
      ),
    );
  }
}

/// Three chevrons pointing up that light up in turn ("lift").
class RisingChevrons extends StatefulWidget {
  const RisingChevrons({super.key, this.color = AppColors.accent, this.size = 30});

  final Color color;
  final double size;

  @override
  State<RisingChevrons> createState() => _RisingChevronsState();
}

class _RisingChevronsState extends State<RisingChevrons>
    with SingleTickerProviderStateMixin {
  AnimationController? _c;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!AppMotion.isReduced(context) && _c == null) {
      _c = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1600),
      )..repeat();
    }
  }

  @override
  void dispose() {
    _c?.dispose();
    super.dispose();
  }

  Widget _column(double t) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < 3; i++)
          Transform.translate(
            offset: Offset(0, -i * widget.size * 0.06),
            child: Opacity(
              // Bottom chevron lights first, then the ones above it.
              opacity: _opacity(t, 2 - i),
              child: SizedBox(
                width: widget.size,
                height: widget.size * 0.62,
                child: OverflowBox(
                  maxHeight: widget.size,
                  child: Icon(
                    Icons.keyboard_arrow_up_rounded,
                    size: widget.size,
                    color: widget.color,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  double _opacity(double t, int index) {
    final double phase = (t * 3 - index) % 3;
    final double v = phase < 1 ? 1 - phase : 0;
    return 0.25 + 0.75 * v;
  }

  @override
  Widget build(BuildContext context) {
    final AnimationController? c = _c;
    if (c == null) {
      return _column(0.34);
    }
    return AnimatedBuilder(
      animation: c,
      builder: (BuildContext context, Widget? _) => _column(c.value),
    );
  }
}

/// Tilted ring orbiting an object, with a small bead travelling along it.
class OrbitRing extends StatefulWidget {
  const OrbitRing({
    super.key,
    required this.width,
    required this.height,
    this.color = AppColors.accent,
  });

  final double width;
  final double height;
  final Color color;

  @override
  State<OrbitRing> createState() => _OrbitRingState();
}

class _OrbitRingState extends State<OrbitRing>
    with SingleTickerProviderStateMixin {
  AnimationController? _c;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!AppMotion.isReduced(context) && _c == null) {
      _c = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 5200),
      )..repeat();
    }
  }

  @override
  void dispose() {
    _c?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AnimationController? c = _c;
    Widget paint(double t) => CustomPaint(
          size: Size(widget.width, widget.height),
          painter: _OrbitPainter(t: t, color: widget.color),
        );
    return IgnorePointer(
      child: c == null
          ? paint(0.62)
          : AnimatedBuilder(
              animation: c,
              builder: (BuildContext context, Widget? _) => paint(c.value),
            ),
    );
  }
}

class _OrbitPainter extends CustomPainter {
  _OrbitPainter({required this.t, required this.color});

  final double t;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect oval = Offset.zero & size;
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(-0.12);
    canvas.translate(-size.width / 2, -size.height / 2);
    final Paint ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..shader = SweepGradient(
        colors: <Color>[
          color.withValues(alpha: 0.05),
          color.withValues(alpha: 0.7),
          color.withValues(alpha: 0.05),
        ],
        transform: GradientRotation(t * 2 * math.pi),
      ).createShader(oval);
    canvas.drawOval(oval.deflate(2), ring);
    final double a = t * 2 * math.pi;
    final Offset bead = Offset(
      size.width / 2 + (size.width / 2 - 2) * math.cos(a),
      size.height / 2 + (size.height / 2 - 2) * math.sin(a),
    );
    canvas.drawCircle(
      bead,
      7,
      Paint()..color = color.withValues(alpha: 0.35),
    );
    canvas.drawCircle(bead, 4.5, Paint()..color = color);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_OrbitPainter old) => old.t != t || old.color != color;
}

/// Curved dotted line between two points in the stage, ending in a dot
/// (links a tile to the part of the body it shows).
class ConnectorLine extends StatelessWidget {
  const ConnectorLine({
    super.key,
    required this.from,
    required this.to,
    this.color = AppColors.accent,
  });

  final Offset from;
  final Offset to;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _ConnectorPainter(from: from, to: to, color: color),
        ),
      ),
    );
  }
}

class _ConnectorPainter extends CustomPainter {
  _ConnectorPainter({required this.from, required this.to, required this.color});

  final Offset from;
  final Offset to;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = Path()
      ..moveTo(from.dx, from.dy)
      ..quadraticBezierTo(from.dx, to.dy, to.dx, to.dy);
    final Paint line = Paint()
      ..color = color.withValues(alpha: 0.7)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (final PathMetric m in path.computeMetrics()) {
      double d = 0;
      while (d < m.length) {
        canvas.drawPath(m.extractPath(d, math.min(d + 6, m.length)), line);
        d += 11;
      }
    }
    canvas.drawCircle(to, 7, Paint()..color = color.withValues(alpha: 0.25));
    canvas.drawCircle(to, 4, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_ConnectorPainter old) =>
      old.from != from || old.to != to || old.color != color;
}

/// Small floating round glass bubble with an icon (thought bubbles etc.).
class IconBubble extends StatelessWidget {
  const IconBubble({
    super.key,
    required this.icon,
    required this.color,
    this.size = 46,
    this.delay = Duration.zero,
  });

  final IconData icon;
  final Color color;
  final double size;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return Reveal(
      from: RevealFrom.fade,
      delay: delay,
      child: FloatBob(
        lift: 5,
        period: Duration(milliseconds: 2600 + delay.inMilliseconds),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: color.withValues(alpha: 0.18),
                blurRadius: 18,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: color, size: size * 0.5),
        ),
      ),
    );
  }
}

/// O3: the man with the sore spot and an X-ray of the pelvic floor in a
/// glass tile with a check badge.
class SafetyScene extends StatelessWidget {
  const SafetyScene({super.key, required this.semanticLabel});

  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return OnboardingStage(
      height: 196,
      semanticLabel: semanticLabel,
      blob: AppColors.pistachio,
      floor: AppColors.pistachio,
      children: [
        const Positioned(
          left: 0,
          bottom: 0,
          child: CutoutFigure(
            asset: OnboardingArt.safetyMan,
            height: 196,
            shadow: false,
            fadeBottom: true,
          ),
        ),
        Positioned(
          right: 8,
          top: 30,
          child: Reveal(
            from: RevealFrom.right,
            delay: const Duration(milliseconds: 220),
            child: FloatBob(
              lift: 4,
              period: const Duration(milliseconds: 2800),
              child: GlassTile(
                size: 138,
                badge: true,
                padding: 4,
                child: Image.asset(
                  OnboardingArt.xray,
                  fit: BoxFit.cover,
                  excludeFromSemantics: true,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// O4: the thinking man with floating thought bubbles.
class ExperienceScene extends StatelessWidget {
  const ExperienceScene({super.key, required this.semanticLabel});

  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return OnboardingStage(
      height: 200,
      semanticLabel: semanticLabel,
      blob: AppColors.sky,
      floor: AppColors.lavender,
      children: const [
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Center(
            child: CutoutFigure(
              asset: OnboardingArt.thinkingMan,
              height: 200,
              shadow: false,
              fadeBottom: true,
            ),
          ),
        ),
        Positioned(
          left: 16,
          top: 28,
          child: IconBubble(
            icon: Icons.question_mark_rounded,
            color: AppColors.primary,
            delay: Duration(milliseconds: 200),
          ),
        ),
        Positioned(
          left: 52,
          top: 104,
          child: IconBubble(
            icon: Icons.fitness_center_rounded,
            color: AppColors.success,
            size: 38,
            delay: Duration(milliseconds: 420),
          ),
        ),
        Positioned(
          right: 26,
          top: 64,
          child: IconBubble(
            icon: Icons.lightbulb_rounded,
            color: AppColors.goalEjaculationFg,
            delay: Duration(milliseconds: 320),
          ),
        ),
      ],
    );
  }
}

/// O5: the calm sitting man with a 3D stopwatch beside him.
class TimeScene extends StatelessWidget {
  const TimeScene({super.key, required this.semanticLabel});

  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return OnboardingStage(
      height: 196,
      semanticLabel: semanticLabel,
      blob: AppColors.pistachio,
      floor: AppColors.pistachio,
      children: [
        Positioned(
          left: 4,
          bottom: 14,
          child: Reveal(
            from: RevealFrom.left,
            delay: const Duration(milliseconds: 200),
            child: Transform.rotate(
              angle: -0.12,
              child: const CutoutFigure(
                asset: OnboardingArt.stopwatch,
                height: 140,
                shadowWidth: 0.9,
              ),
            ),
          ),
        ),
        const Positioned(
          right: 0,
          bottom: 4,
          child: CutoutFigure(
            asset: OnboardingArt.timeMan,
            height: 186,
            shadowWidth: 1.2,
          ),
        ),
      ],
    );
  }
}
