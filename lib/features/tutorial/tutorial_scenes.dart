import 'package:material_ui/material_ui.dart';

import '../../app/theme/tokens.dart';
import '../../core/motion/app_motion.dart';
import '../onboarding/widgets/onboarding_stage.dart';

/// "Where the muscles are": the man lying on his back, a glowing band at
/// the pelvis, and a round inset of the pelvic floor linked to it.
class MusclesScene extends StatelessWidget {
  const MusclesScene({super.key, required this.semanticLabel});

  final String semanticLabel;

  static const double _height = 240;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints box) {
        final double w = box.maxWidth;
        final double figW = w;
        final double figH = figW * 371 / 900;
        // The hips sit a little left of centre in the cut-out.
        final Offset hips = Offset(w * 0.5, _height - figH * 0.5);
        const double inset = 104;
        final Offset insetCentre = Offset(w * 0.47, inset / 2 + 6);
        return OnboardingStage(
          height: _height,
          semanticLabel: semanticLabel,
          blob: AppColors.pistachio,
          floor: AppColors.lavender,
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: CutoutFigure(
                asset: OnboardingArt.tutorialWhere,
                height: figH,
                float: false,
                shadowWidth: 2.2,
              ),
            ),
            Positioned(
              left: hips.dx - 34,
              top: hips.dy - 34,
              child: const PulseGlow(color: AppColors.success, size: 68),
            ),
            ConnectorLine(
              from: Offset(insetCentre.dx, insetCentre.dy + inset / 2),
              to: hips,
              color: AppColors.success,
            ),
            Positioned(
              left: insetCentre.dx - inset / 2,
              top: insetCentre.dy - inset / 2,
              child: Reveal(
                from: RevealFrom.drop,
                delay: const Duration(milliseconds: 200),
                child: Container(
                  width: inset,
                  height: inset,
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surface, width: 3),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: AppColors.success.withValues(alpha: 0.25),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    OnboardingArt.pelvis,
                    fit: BoxFit.contain,
                    excludeFromSemantics: true,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// "How to find them": side-view X-ray squeeze ↔ relax cycle.
class FindScene extends StatelessWidget {
  const FindScene({super.key, required this.semanticLabel});

  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      image: true,
      child: AspectRatio(
        aspectRatio: 1,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadii.xlAll,
            border: Border.all(color: AppColors.border),
            boxShadow: AppElevation.level2,
          ),
          child: ClipRRect(
            borderRadius: AppRadii.xlAll,
            child: ColoredBox(
              color: const Color(0xFF111111),
              child: Image.asset(
                OnboardingArt.sideSqueezeRelaxGif,
                fit: BoxFit.cover,
                gaplessPlayback: true,
                errorBuilder: (
                  BuildContext context,
                  Object error,
                  StackTrace? stackTrace,
                ) {
                  return Image.asset(
                    OnboardingArt.sideSqueeze,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Soft glow that breathes in and out (a muscle area being worked).
class PulseGlow extends StatefulWidget {
  const PulseGlow({super.key, required this.color, required this.size});

  final Color color;
  final double size;

  @override
  State<PulseGlow> createState() => _PulseGlowState();
}

class _PulseGlowState extends State<PulseGlow>
    with SingleTickerProviderStateMixin {
  AnimationController? _c;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!AppMotion.isReduced(context) && _c == null) {
      _c = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1800),
      )..repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _c?.dispose();
    super.dispose();
  }

  Widget _glow(double t) => IgnorePointer(
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: <Color>[
                widget.color.withValues(alpha: 0.35 + 0.3 * t),
                widget.color.withValues(alpha: 0),
              ],
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final AnimationController? c = _c;
    if (c == null) {
      return _glow(0.6);
    }
    return AnimatedBuilder(
      animation: c,
      builder: (BuildContext context, Widget? _) =>
          _glow(Curves.easeInOut.transform(c.value)),
    );
  }
}

/// Green arrow that rises and fades, over and over ("lift up").
class LiftArrow extends StatefulWidget {
  const LiftArrow({super.key});

  @override
  State<LiftArrow> createState() => _LiftArrowState();
}

class _LiftArrowState extends State<LiftArrow>
    with SingleTickerProviderStateMixin {
  AnimationController? _c;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!AppMotion.isReduced(context) && _c == null) {
      _c = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1500),
      )..repeat();
    }
  }

  @override
  void dispose() {
    _c?.dispose();
    super.dispose();
  }

  Widget _arrow(double t) {
    return SizedBox(
      width: 48,
      height: 96,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            bottom: 20 * t,
            child: Opacity(
              opacity: (1 - t * 0.7).clamp(0.0, 1.0),
              child: const Icon(
                Icons.arrow_upward_rounded,
                size: 48,
                color: AppColors.success,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AnimationController? c = _c;
    if (c == null) {
      return _arrow(0.3);
    }
    return AnimatedBuilder(
      animation: c,
      builder: (BuildContext context, Widget? _) =>
          _arrow(Curves.easeOut.transform(c.value)),
    );
  }
}
