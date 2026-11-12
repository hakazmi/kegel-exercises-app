import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../app/theme/tokens.dart';

/// Animated ring that fills over [duration] using a phase colour.
class SessionRing extends StatefulWidget {
  const SessionRing({
    super.key,
    required this.phase,
    required this.duration,
    this.size = 240,
    this.strokeWidth = 10,
    this.progress,
    this.child,
    this.onCompleted,
  });

  final SessionPhase phase;

  /// Full duration of the current phase. Ignored when [progress] is set.
  final Duration duration;

  /// Optional explicit 0–1 progress (for paused / driven clocks).
  final double? progress;

  final double size;
  final double strokeWidth;
  final Widget? child;
  final VoidCallback? onCompleted;

  @override
  State<SessionRing> createState() => _SessionRingState();
}

class _SessionRingState extends State<SessionRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          widget.onCompleted?.call();
        }
      });
    if (widget.progress == null) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant SessionRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.progress == null &&
        (oldWidget.duration != widget.duration ||
            oldWidget.phase != widget.phase)) {
      _controller
        ..duration = widget.duration
        ..forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color color = phaseColor(widget.phase);
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? child) {
          final double value = widget.progress ?? _controller.value;
          return CustomPaint(
            painter: _SessionRingPainter(
              progress: value.clamp(0.0, 1.0),
              color: color,
              trackColor: AppColors.sessionRingTrack,
              strokeWidth: widget.strokeWidth,
            ),
            child: Center(child: child),
          );
        },
        child: widget.child,
      ),
    );
  }
}

class _SessionRingPainter extends CustomPainter {
  _SessionRingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    final Rect rect = Rect.fromCircle(center: center, radius: radius);

    final Paint track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, math.pi * 2, false, track);

    final Paint fill = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * progress, false, fill);
  }

  @override
  bool shouldRepaint(covariant _SessionRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
