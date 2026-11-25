import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:material_ui/material_ui.dart';

import '../../app/l10n/app_localizations.dart';
import '../../app/theme/tokens.dart';
import '../motion/app_motion.dart';

/// Body position shown for a plan day (decorative, day 1–7 of each week).
///
/// Assets are background-removed cutouts (transparent PNG) made from the
/// position photos with rembg (u2net_human_seg).
enum DayPose {
  standing('assets/positions/position_standing.png'),
  sitting('assets/positions/position_sitting.png'),
  lyingOnBack('assets/positions/position_lying_on_back.png'),
  gluteBridge('assets/positions/position_glute_bridge.png'),
  squatting('assets/positions/position_squatting.png'),
  kneeling('assets/positions/position_kneeling.png'),
  restBreathing('assets/positions/position_breathing_calm.png');

  const DayPose(this.asset);

  final String asset;

  /// Wide poses (lying, bridge) sit lower and wider in the panel.
  bool get isWide => this == lyingOnBack || this == gluteBridge;

  /// Training day: 1 standing, 2 sitting, 3 lying, 4 bridge, 5 squat,
  /// 6 kneeling, repeating. Calm breathing is only for rest days
  /// ([restBreathing]), which sit between every six training days.
  static DayPose forDay(int day) => values[(math.max(day, 1) - 1) % 6];

  /// Training days shown before each rest-day card in a level's strip.
  static const int trainingDaysPerWeek = 6;

  String label(AppLocalizations l10n) => switch (this) {
    DayPose.standing => l10n.poseStanding,
    DayPose.sitting => l10n.poseSitting,
    DayPose.lyingOnBack => l10n.poseLyingOnBack,
    DayPose.gluteBridge => l10n.poseGluteBridge,
    DayPose.squatting => l10n.poseSquatting,
    DayPose.kneeling => l10n.poseKneeling,
    DayPose.restBreathing => l10n.poseRestBreathing,
  };
}

/// Cut-out figure standing on a dark panel and popping out above it.
///
/// The panel has an accent spotlight and floor; the figure (transparent
/// PNG) stands on the floor with a soft contact shadow and rises past the
/// panel's top edge by [overflowTop]. A slight perspective tilt sways
/// gently for depth (static when [animate] is false or motion is reduced).
class PosePanel extends StatefulWidget {
  const PosePanel({
    super.key,
    required this.pose,
    required this.width,
    required this.height,
    this.animate = true,
    this.dimmed = false,
    this.overflowTop = 0.28,
    this.semanticLabel,
  });

  final DayPose pose;
  final double width;

  /// Height of the panel itself; the figure extends above it.
  final double height;
  final bool animate;

  /// Greys the figure (locked days).
  final bool dimmed;

  /// How far the figure rises above the panel, as a fraction of [height].
  final double overflowTop;
  final String? semanticLabel;

  @override
  State<PosePanel> createState() => _PosePanelState();
}

class _PosePanelState extends State<PosePanel>
    with SingleTickerProviderStateMixin {
  AnimationController? _sway;

  static const Color _black = Color(0xFF000000);

  static const ColorFilter _grey = ColorFilter.matrix(<double>[
    0.3, 0.3, 0.3, 0, 0, //
    0.3, 0.3, 0.3, 0, 0, //
    0.3, 0.3, 0.3, 0, 0, //
    0, 0, 0, 0.55, 0,
  ]);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bool run = widget.animate && !AppMotion.isReduced(context);
    if (run && _sway == null) {
      _sway = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 4200),
      )..repeat(reverse: true);
    } else if (!run && _sway != null) {
      _sway!.dispose();
      _sway = null;
    }
  }

  @override
  void dispose() {
    _sway?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double w = widget.width;
    final double h = widget.height;
    final double rise = h * widget.overflowTop;
    final double radius = w * 0.14;
    final bool wide = widget.pose.isWide;
    // Feet rest on the "floor" a little above the panel's bottom edge.
    final double floor = h * 0.1;
    final double figureHeight = wide ? h * 0.78 : h + rise - floor;
    final double figureWidth = wide ? w * 1.18 : w * 1.02;
    final int cacheWidth =
        (figureWidth * MediaQuery.devicePixelRatioOf(context)).round();

    Widget figure = Image.asset(
      widget.pose.asset,
      fit: BoxFit.contain,
      alignment: Alignment.bottomCenter,
      cacheWidth: cacheWidth,
      filterQuality: FilterQuality.medium,
      gaplessPlayback: true,
      excludeFromSemantics: true,
    );
    if (widget.dimmed) {
      figure = ColorFiltered(colorFilter: _grey, child: figure);
    }

    final Widget panel = SizedBox(
      width: w,
      height: h + rise,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // Panel: dark card, spotlight, floor line.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: h,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[AppColors.sessionSurface, _black],
                ),
                border: Border.all(
                  color: AppColors.accent.withValues(
                    alpha: widget.dimmed ? 0.12 : 0.5,
                  ),
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: _black.withValues(alpha: 0.3),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(radius),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0, 0.1),
                      radius: 0.8,
                      colors: <Color>[
                        AppColors.accent.withValues(
                          alpha: widget.dimmed ? 0.04 : 0.34,
                        ),
                        AppColors.accent.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Contact shadow on the floor.
          Positioned(
            bottom: floor - h * 0.04,
            width: w * (wide ? 0.95 : 0.7),
            height: h * 0.1,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 6, sigmaY: 3),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(w),
                  color: _black.withValues(alpha: 0.75),
                ),
              ),
            ),
          ),
          // Soft glow behind the figure so it separates from the panel.
          Positioned(
            bottom: floor,
            width: w * 0.8,
            height: (wide ? figureHeight : figureHeight * 0.8),
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: <Color>[
                      AppColors.accent.withValues(
                        alpha: widget.dimmed ? 0 : 0.18,
                      ),
                      AppColors.accent.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // The figure, standing on the floor and rising above the panel.
          Positioned(
            bottom: floor,
            width: figureWidth,
            height: figureHeight,
            child: figure,
          ),
        ],
      ),
    );

    final Widget labelled = Semantics(
      image: true,
      label: widget.semanticLabel,
      child: panel,
    );

    final AnimationController? sway = _sway;
    if (sway == null) {
      return Transform(
        alignment: Alignment.bottomCenter,
        transform: _tilt(0.5),
        child: labelled,
      );
    }
    return AnimatedBuilder(
      animation: sway,
      child: labelled,
      builder: (BuildContext context, Widget? child) => Transform(
        alignment: Alignment.bottomCenter,
        transform: _tilt(Curves.easeInOut.transform(sway.value)),
        child: child,
      ),
    );
  }

  /// Perspective tilt; [t] 0..1 sways the panel left/right a little.
  Matrix4 _tilt(double t) {
    final double y = -0.14 + 0.18 * t;
    return Matrix4.identity()
      ..setEntry(3, 2, 0.0014)
      ..rotateX(0.05)
      ..rotateY(y);
  }
}

/// Just the cut-out figure with a soft back glow and floor shadow — no
/// card. Place it so it overlaps the top edge of a panel to pop out of it.
class PoseFigure extends StatelessWidget {
  const PoseFigure({
    super.key,
    required this.pose,
    required this.width,
    required this.height,
    this.dimmed = false,
    this.glow = true,
    this.glowColor = AppColors.accent,
    this.semanticLabel,
  });

  final DayPose pose;
  final double width;
  final double height;
  final bool dimmed;
  final bool glow;

  /// Colour of the soft glow behind the figure (match the panel it sits on).
  final Color glowColor;
  final String? semanticLabel;

  static const ColorFilter _grey = ColorFilter.matrix(<double>[
    0.3, 0.3, 0.3, 0, 0, //
    0.3, 0.3, 0.3, 0, 0, //
    0.3, 0.3, 0.3, 0, 0, //
    0, 0, 0, 0.5, 0,
  ]);

  @override
  Widget build(BuildContext context) {
    Widget image = Image.asset(
      pose.asset,
      fit: BoxFit.contain,
      alignment: Alignment.bottomCenter,
      cacheWidth: (width * MediaQuery.devicePixelRatioOf(context)).round(),
      filterQuality: FilterQuality.medium,
      gaplessPlayback: true,
      excludeFromSemantics: true,
    );
    if (dimmed) {
      image = ColorFiltered(colorFilter: _grey, child: image);
    }
    return Semantics(
      image: true,
      label: semanticLabel,
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            if (glow && !dimmed)
              Positioned(
                bottom: height * 0.05,
                width: width * 0.95,
                height: height * 0.8,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: <Color>[
                        glowColor.withValues(alpha: 0.45),
                        glowColor.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            Positioned(
              bottom: -height * 0.015,
              width: width * (pose.isWide ? 0.95 : 0.7),
              height: height * 0.06,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 2.5),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(width),
                    color: const Color(0xFF000000).withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
            Positioned.fill(child: image),
          ],
        ),
      ),
    );
  }
}
