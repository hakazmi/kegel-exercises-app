import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';

import '../../../app/theme/tokens.dart';
import '../engine/engine_models.dart';

/// 280×280 session ring with muscle sling diagram (exact geometry from Prompt 5).
class SessionMuscleRing extends StatefulWidget {
  const SessionMuscleRing({
    super.key,
    required this.engineState,
    this.phaseLabel,
    this.size = 280,
  });

  final EngineState engineState;

  /// Localized phase word for semantics; ring colors use [SessionPhaseKey].
  final String? phaseLabel;
  final double size;

  @override
  State<SessionMuscleRing> createState() => _SessionMuscleRingState();
}

class _SessionMuscleRingState extends State<SessionMuscleRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _lift;
  late Animation<double> _liftAnim;

  bool get _wantUp {
    final EngineMachineState m = widget.engineState.machine ==
            EngineMachineState.paused
        ? (widget.engineState.pausedFrom ?? EngineMachineState.rest)
        : widget.engineState.machine;
    return m == EngineMachineState.squeeze;
  }

  @override
  void initState() {
    super.initState();
    _lift = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: _wantUp ? 1 : 0,
    );
    _liftAnim = CurvedAnimation(parent: _lift, curve: Curves.easeInOut);
  }

  @override
  void didUpdateWidget(covariant SessionMuscleRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_wantUp) {
      _lift.forward();
    } else {
      _lift.reverse();
    }
  }

  @override
  void dispose() {
    _lift.dispose();
    super.dispose();
  }

  Color get _phaseColor {
    final String word = widget.engineState.phaseWord;
    if (word == SessionPhaseKey.rest ||
        widget.engineState.machine == EngineMachineState.rest ||
        (widget.engineState.machine == EngineMachineState.paused &&
            widget.engineState.pausedFrom == EngineMachineState.rest)) {
      return AppColors.phaseRest;
    }
    if (word == SessionPhaseKey.relax ||
        word == SessionPhaseKey.breatheOut ||
        widget.engineState.machine == EngineMachineState.relax ||
        (widget.engineState.machine == EngineMachineState.paused &&
            widget.engineState.pausedFrom == EngineMachineState.relax)) {
      return AppColors.phaseRelax;
    }
    if (widget.engineState.machine == EngineMachineState.done) {
      return AppColors.phaseSqueezeHold;
    }
    return AppColors.phaseSqueezeHold;
  }

  _ArrowKind get _arrow {
    if (widget.engineState.machine == EngineMachineState.done &&
        widget.engineState.completed) {
      return _ArrowKind.check;
    }
    final EngineMachineState m = widget.engineState.machine ==
            EngineMachineState.paused
        ? (widget.engineState.pausedFrom ?? EngineMachineState.rest)
        : widget.engineState.machine;
    switch (m) {
      case EngineMachineState.squeeze:
        return _ArrowKind.up;
      case EngineMachineState.relax:
        return _ArrowKind.down;
      case EngineMachineState.rest:
      case EngineMachineState.countdown:
      case EngineMachineState.idle:
      case EngineMachineState.paused:
      case EngineMachineState.done:
        return _ArrowKind.none;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.phaseLabel ?? widget.engineState.phaseWord,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _liftAnim,
          builder: (BuildContext context, Widget? child) {
            return CustomPaint(
              size: Size.square(widget.size),
              painter: _SessionMusclePainter(
                progress: widget.engineState.phaseProgress.clamp(0.0, 1.0),
                phaseColor: _phaseColor,
                lift: _liftAnim.value,
                arrow: _arrow,
              ),
            );
          },
        ),
      ),
    );
  }
}

enum _ArrowKind { none, up, down, check }

class _SessionMusclePainter extends CustomPainter {
  _SessionMusclePainter({
    required this.progress,
    required this.phaseColor,
    required this.lift,
    required this.arrow,
  });

  final double progress;
  final Color phaseColor;
  final double lift;
  final _ArrowKind arrow;

  static const double _vb = 280;
  static const Offset _center = Offset(140, 140);
  static const double _radius = 126;
  static const double _ringStroke = 12;
  static const Color _silhouette = Color(0xFF3A4541);

  @override
  void paint(Canvas canvas, Size size) {
    final double scale = size.width / _vb;
    canvas.save();
    canvas.scale(scale);

    final Paint track = Paint()
      ..color = AppColors.sessionRingTrack
      ..style = PaintingStyle.stroke
      ..strokeWidth = _ringStroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(_center, _radius, track);

    if (progress > 0) {
      final Paint arc = Paint()
        ..color = phaseColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = _ringStroke
        ..strokeCap = StrokeCap.round;
      final Rect rect = Rect.fromCircle(center: _center, radius: _radius);
      canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * progress, false, arc);
    }

    final Paint bodyPaint = Paint()
      ..color = _silhouette
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final Path left = Path()
      ..moveTo(78, 92)
      ..cubicTo(74, 130, 86, 160, 112, 172);
    final Path right = Path()
      ..moveTo(202, 92)
      ..cubicTo(206, 130, 194, 160, 168, 172);
    canvas.drawPath(left, bodyPaint);
    canvas.drawPath(right, bodyPaint);

    // Muscle sling: lerp Down → Up control points.
    final double y = ui.lerpDouble(184, 136, lift)!;
    final Paint muscle = Paint()
      ..color = phaseColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    final Path sling = Path()
      ..moveTo(70, 156)
      ..cubicTo(100, y, 180, y, 210, 156);
    canvas.drawPath(sling, muscle);

    final Paint arrowPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    switch (arrow) {
      case _ArrowKind.up:
        canvas.drawPath(
          Path()
            ..moveTo(140, 124)
            ..lineTo(140, 96)
            ..moveTo(130, 106)
            ..lineTo(140, 96)
            ..lineTo(150, 106),
          arrowPaint,
        );
      case _ArrowKind.down:
        canvas.drawPath(
          Path()
            ..moveTo(140, 96)
            ..lineTo(140, 124)
            ..moveTo(130, 114)
            ..lineTo(140, 124)
            ..lineTo(150, 114),
          arrowPaint,
        );
      case _ArrowKind.check:
        canvas.drawPath(
          Path()
            ..moveTo(118, 104)
            ..lineTo(134, 120)
            ..lineTo(164, 90),
          arrowPaint,
        );
      case _ArrowKind.none:
        break;
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SessionMusclePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.phaseColor != phaseColor ||
        oldDelegate.lift != lift ||
        oldDelegate.arrow != arrow;
  }
}
