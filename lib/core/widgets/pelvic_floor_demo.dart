import 'dart:async';
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:video_player/video_player.dart';

import '../../app/l10n/app_localizations.dart';
import '../../app/theme/tokens.dart';
import '../motion/app_motion.dart';

/// What the pelvic floor is doing in the demo.
enum PfPhase { rest, squeeze, hold, relax }

/// Video assets for the 3D pelvic-floor demo (cropped, no audio).
abstract final class PfDemoAssets {
  /// Relaxed → squeezed (about 3 s).
  static const String squeeze = 'assets/videos/pf_squeeze.mp4';

  /// Squeezed → relaxed (about 3 s).
  static const String relax = 'assets/videos/pf_relax.mp4';

  /// Still frames used when motion is reduced or video is unavailable.
  static const String relaxedStill = 'assets/videos/pf_relaxed.jpg';
  static const String squeezedStill = 'assets/videos/pf_squeezed.jpg';

  /// Natural length of each clip.
  static const Duration clipLength = Duration(milliseconds: 3000);

  /// Width / height of the clips (840 × 402): the whole pelvis in view.
  static const double aspect = 840 / 402;

  /// Studio grey behind the model, used to fill any letterbox.
  static const Color backdrop = Color(0xFFE6E7E3);
}

/// The 3D pelvic floor following a phase:
///
/// * squeeze — plays the squeeze clip over [motion] (sped up as needed);
/// * hold — the squeeze clip stays frozen on its last frame;
/// * relax — plays the relax clip over [motion];
/// * rest — shows the relaxed muscles.
///
/// Changing [cycle] restarts the current phase's clip (next rep). With
/// reduced motion, in tests, or if the video cannot load, it cross-fades
/// between two still frames instead.
class PelvicFloorVideo extends StatefulWidget {
  const PelvicFloorVideo({
    super.key,
    required this.phase,
    this.motion = PfDemoAssets.clipLength,
    this.cycle = 0,
    this.paused = false,
    this.fit = BoxFit.cover,
  });

  final PfPhase phase;

  /// How long the squeeze or relax movement should take on screen.
  final Duration motion;
  final int cycle;
  final bool paused;
  final BoxFit fit;

  @override
  State<PelvicFloorVideo> createState() => _PelvicFloorVideoState();
}

class _PelvicFloorVideoState extends State<PelvicFloorVideo> {
  VideoPlayerController? _squeeze;
  VideoPlayerController? _relax;
  bool _ready = false;
  bool _failed = false;
  bool _started = false;

  /// Which clip is on top: true = squeeze clip, false = relax clip.
  bool _showSqueeze = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started && !AppMotion.isReduced(context)) {
      _started = true;
      unawaited(_init());
    }
  }

  Future<void> _init() async {
    final VideoPlayerController a = VideoPlayerController.asset(
      PfDemoAssets.squeeze,
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
    final VideoPlayerController b = VideoPlayerController.asset(
      PfDemoAssets.relax,
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
    _squeeze = a;
    _relax = b;
    try {
      await Future.wait(<Future<void>>[a.initialize(), b.initialize()]);
      await a.setVolume(0);
      await b.setVolume(0);
      if (!mounted) {
        return;
      }
      setState(() => _ready = true);
      await _apply(restart: true);
    } on Object catch (error) {
      debugPrint('Pelvic floor video unavailable: $error');
      if (mounted) {
        setState(() => _failed = true);
      }
    }
  }

  @override
  void didUpdateWidget(covariant PelvicFloorVideo old) {
    super.didUpdateWidget(old);
    if (!_ready) {
      return;
    }
    final bool restart = old.phase != widget.phase || old.cycle != widget.cycle;
    if (restart || old.paused != widget.paused) {
      unawaited(_apply(restart: restart));
    }
  }

  double _speedFor(Duration motion) {
    final double target = math.max(motion.inMilliseconds, 1).toDouble();
    return (PfDemoAssets.clipLength.inMilliseconds / target).clamp(0.5, 4.0);
  }

  Future<void> _apply({required bool restart}) async {
    final VideoPlayerController? a = _squeeze;
    final VideoPlayerController? b = _relax;
    if (a == null || b == null) {
      return;
    }
    switch (widget.phase) {
      case PfPhase.squeeze:
        if (!mounted) return;
        setState(() => _showSqueeze = true);
        await b.pause();
        if (restart) {
          await a.seekTo(Duration.zero);
          await a.setPlaybackSpeed(_speedFor(widget.motion));
        }
        widget.paused ? await a.pause() : await a.play();
      case PfPhase.hold:
        // Freeze on the squeezed frame: let the squeeze clip finish (it
        // stops on its last frame) or jump there if we arrived directly.
        if (!mounted) return;
        setState(() => _showSqueeze = true);
        await b.pause();
        if (restart && !a.value.isPlaying) {
          await a.seekTo(a.value.duration);
        }
        if (widget.paused) {
          await a.pause();
        }
      case PfPhase.relax:
        if (!mounted) return;
        setState(() => _showSqueeze = false);
        await a.pause();
        if (restart) {
          await b.seekTo(Duration.zero);
          await b.setPlaybackSpeed(_speedFor(widget.motion));
        }
        widget.paused ? await b.pause() : await b.play();
      case PfPhase.rest:
        // Relaxed: the end of the relax clip, or the start of the squeeze
        // clip when the previous phase was cut short.
        if (_showSqueeze) {
          await a.pause();
          await a.seekTo(Duration.zero);
        } else if (!b.value.isPlaying) {
          await b.seekTo(b.value.duration);
        }
    }
  }

  @override
  void dispose() {
    _squeeze?.dispose();
    _relax?.dispose();
    super.dispose();
  }

  Widget _still() {
    final bool squeezed =
        widget.phase == PfPhase.squeeze || widget.phase == PfPhase.hold;
    return AnimatedSwitcher(
      duration: AppMotion.isReduced(context)
          ? Duration.zero
          : const Duration(milliseconds: 500),
      child: Image.asset(
        squeezed ? PfDemoAssets.squeezedStill : PfDemoAssets.relaxedStill,
        key: ValueKey<bool>(squeezed),
        fit: widget.fit,
        width: double.infinity,
        height: double.infinity,
        gaplessPlayback: true,
        excludeFromSemantics: true,
      ),
    );
  }

  Widget _video(VideoPlayerController c) {
    return FittedBox(
      fit: widget.fit,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: c.value.size.width,
        height: c.value.size.height,
        child: VideoPlayer(c),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final VideoPlayerController? a = _squeeze;
    final VideoPlayerController? b = _relax;
    if (!_ready || _failed || a == null || b == null) {
      return _still();
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        // The still sits underneath so there is never a blank frame.
        _still(),
        Offstage(offstage: _showSqueeze, child: _video(b)),
        Offstage(offstage: !_showSqueeze, child: _video(a)),
      ],
    );
  }
}

/// Self-running demo card for the tutorial: squeeze → hold → relax → rest,
/// over and over, with the three steps shown underneath and the current one
/// lit up.
class PelvicFloorDemoLoop extends StatefulWidget {
  const PelvicFloorDemoLoop({
    super.key,
    this.squeeze = const Duration(milliseconds: 1500),
    this.hold = const Duration(seconds: 3),
    this.relax = const Duration(milliseconds: 2500),
    this.rest = const Duration(milliseconds: 1500),
    this.height = 230,
  });

  /// Largest height for the video area; it keeps the clip's own shape so
  /// the whole pelvis stays in view (no zoom-in crop).

  final Duration squeeze;
  final Duration hold;
  final Duration relax;
  final Duration rest;
  final double height;

  @override
  State<PelvicFloorDemoLoop> createState() => _PelvicFloorDemoLoopState();
}

class _PelvicFloorDemoLoopState extends State<PelvicFloorDemoLoop> {
  PfPhase _phase = PfPhase.rest;
  int _cycle = 0;
  Timer? _timer;
  bool _running = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_running && !AppMotion.isReduced(context)) {
      _running = true;
      _go(PfPhase.squeeze);
    }
  }

  Duration _lengthOf(PfPhase p) => switch (p) {
    PfPhase.squeeze => widget.squeeze,
    PfPhase.hold => widget.hold,
    PfPhase.relax => widget.relax,
    PfPhase.rest => widget.rest,
  };

  PfPhase _after(PfPhase p) => switch (p) {
    PfPhase.squeeze => PfPhase.hold,
    PfPhase.hold => PfPhase.relax,
    PfPhase.relax => PfPhase.rest,
    PfPhase.rest => PfPhase.squeeze,
  };

  void _go(PfPhase p) {
    if (!mounted) {
      return;
    }
    setState(() {
      _phase = p;
      if (p == PfPhase.squeeze) {
        _cycle++;
      }
    });
    _timer?.cancel();
    _timer = Timer(_lengthOf(p), () => _go(_after(p)));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool still = !_running;
    final List<({PfPhase phase, String label, String hint, IconData icon})>
    steps = <({PfPhase phase, String label, String hint, IconData icon})>[
      (
        phase: PfPhase.squeeze,
        label: l10n.t1PhaseSqueeze,
        hint: l10n.pfDemoSqueezeHint,
        icon: Icons.arrow_upward_rounded,
      ),
      (
        phase: PfPhase.hold,
        label: l10n.s3PhaseHold,
        hint: l10n.pfDemoHoldHint,
        icon: Icons.pause_rounded,
      ),
      (
        phase: PfPhase.relax,
        label: l10n.t1PhaseRelax,
        hint: l10n.pfDemoRelaxHint,
        icon: Icons.arrow_downward_rounded,
      ),
    ];

    return Semantics(
      image: true,
      label: l10n.pfDemoSemantic,
      excludeSemantics: true,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadii.xlAll,
          boxShadow: AppElevation.level2,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            ColoredBox(
              color: PfDemoAssets.backdrop,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: widget.height),
                child: AspectRatio(
                  aspectRatio: PfDemoAssets.aspect,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      PelvicFloorVideo(
                        phase: _phase,
                        cycle: _cycle,
                        motion: _lengthOf(_phase),
                        fit: BoxFit.contain,
                      ),
                      Positioned(
                        left: AppSpacing.sm,
                        top: AppSpacing.sm,
                        child: _PhasePill(
                          text: still
                              ? l10n.pfDemoTitle
                              : _labelOf(l10n, _phase),
                          active: !still && _phase != PfPhase.rest,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Row(
                children: [
                  for (int i = 0; i < steps.length; i++) ...[
                    if (i > 0) const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: _StepChip(
                        number: i + 1,
                        label: steps[i].label,
                        hint: steps[i].hint,
                        icon: steps[i].icon,
                        active: !still && _phase == steps[i].phase,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _labelOf(AppLocalizations l10n, PfPhase p) => switch (p) {
    PfPhase.squeeze => l10n.t1PhaseSqueeze,
    PfPhase.hold => l10n.s3PhaseHold,
    PfPhase.relax => l10n.t1PhaseRelax,
    PfPhase.rest => l10n.s3PhaseRest,
  };
}

class _PhasePill extends StatelessWidget {
  const _PhasePill({required this.text, required this.active});

  final String text;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppMotion.quick,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: active
            ? AppColors.ink
            : AppColors.surface.withValues(alpha: 0.9),
        borderRadius: AppRadii.pillAll,
        boxShadow: AppElevation.level1,
      ),
      child: AnimatedSwitcher(
        duration: AppMotion.quick,
        child: Text(
          text.toUpperCase(),
          key: ValueKey<String>(text),
          style: AppTypography.caption.copyWith(
            color: active ? AppColors.textOnPrimary : AppColors.ink,
            fontWeight: FontWeight.w900,
            fontSize: 12,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }
}

class _StepChip extends StatelessWidget {
  const _StepChip({
    required this.number,
    required this.label,
    required this.hint,
    required this.icon,
    required this.active,
  });

  final int number;
  final String label;
  final String hint;
  final IconData icon;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: active ? AppColors.mint : AppColors.surfaceMuted,
        borderRadius: AppRadii.lgAll,
        border: Border.all(
          color: active ? AppColors.primary : AppColors.surfaceMuted,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: active ? AppColors.primary : AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 16,
              color: active ? AppColors.textOnPrimary : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$number. $label',
            maxLines: 1,
            overflow: TextOverflow.fade,
            softWrap: false,
            style: AppTypography.caption.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            hint,
            maxLines: 2,
            textAlign: TextAlign.center,
            style: AppTypography.caption.copyWith(fontSize: 11, height: 1.2),
          ),
        ],
      ),
    );
  }
}

/// Session player centre piece: the 3D pelvic floor in a circle with the
/// phase progress ring around it.
class PelvicFloorRing extends StatelessWidget {
  const PelvicFloorRing({
    super.key,
    required this.phase,
    required this.progress,
    required this.color,
    required this.size,
    this.motion = PfDemoAssets.clipLength,
    this.cycle = 0,
    this.paused = false,
    this.semanticLabel,
  });

  final PfPhase phase;

  /// Progress through the current phase, 0–1.
  final double progress;
  final Color color;
  final double size;
  final Duration motion;
  final int cycle;
  final bool paused;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    const double stroke = 10;
    return Semantics(
      image: true,
      label: semanticLabel,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(
              painter: _RingPainter(
                progress: progress.clamp(0.0, 1.0),
                color: color,
                stroke: stroke,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(stroke + 6),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: color.withValues(alpha: 0.25),
                      blurRadius: 24,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: PelvicFloorVideo(
                    phase: phase,
                    motion: motion,
                    cycle: cycle,
                    paused: paused,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.color,
    required this.stroke,
  });

  final double progress;
  final Color color;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset c = size.center(Offset.zero);
    final double r = size.shortestSide / 2 - stroke / 2;
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = AppColors.sessionRingTrack
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color;
}
