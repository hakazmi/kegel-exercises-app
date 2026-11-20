import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../app/l10n/app_localizations.dart';
import '../../app/theme/tokens.dart';
import '../../core/data/repositories/hold_test_repository.dart';
import '../../core/motion/app_motion.dart';
import '../../core/widgets/widgets.dart';

/// Progress card for the pelvic floor hold test: latest, best and count,
/// and a line chart of saved results (most recent [maxPoints]) that draws
/// itself in.
class HoldTestCard extends StatelessWidget {
  const HoldTestCard({
    super.key,
    required this.l10n,
    required this.results,
    required this.onStart,
  });

  final AppLocalizations l10n;
  final List<HoldTestResult> results;
  final VoidCallback onStart;

  static const int maxPoints = 12;

  String _s(double v) => l10n.htValue(v.toStringAsFixed(1));

  @override
  Widget build(BuildContext context) {
    final List<HoldTestResult> shown = results.length > maxPoints
        ? results.sublist(results.length - maxPoints)
        : results;
    final double? best = results.isEmpty
        ? null
        : results.map((HoldTestResult r) => r.seconds).reduce(math.max);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.xlAll,
        border: Border.all(color: AppColors.border),
        boxShadow: AppElevation.level1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.goalBladderBg,
                  borderRadius: AppRadii.mdAll,
                ),
                child: const Icon(
                  Icons.timer_rounded,
                  color: AppColors.goalBladderFg,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.htProgressTitle, style: AppTypography.title),
                    TextLinkButton(
                      label: l10n.htProgressStart,
                      onPressed: onStart,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (results.isEmpty)
            Text(l10n.htProgressEmpty, style: AppTypography.body)
          else ...[
            Row(
              children: [
                _Figure(
                  label: l10n.htProgressLatest,
                  value: _s(results.last.seconds),
                  bg: AppColors.mint,
                ),
                const SizedBox(width: AppSpacing.xs),
                _Figure(
                  label: l10n.htProgressBest,
                  value: _s(best!),
                  bg: AppColors.streakBg,
                ),
                const SizedBox(width: AppSpacing.xs),
                _Figure(
                  label: l10n.htProgressTests,
                  value: '${results.length}',
                  bg: AppColors.goalBladderBg,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 150,
              child: AnimatedFraction(
                value: 1,
                delay: const Duration(milliseconds: 300),
                duration: const Duration(milliseconds: 1200),
                builder: (BuildContext context, double t) => CustomPaint(
                  painter: _ChartPainter(
                    values: <double>[
                      for (final HoldTestResult r in shown) r.seconds,
                    ],
                    reveal: t,
                    labelStyle: AppTypography.caption.copyWith(fontSize: 11),
                    unit: l10n.htValue,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure({required this.label, required this.value, required this.bg});

  final String label;
  final String value;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: AppRadii.lgAll,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.caption.copyWith(
                color: AppColors.ink,
                fontSize: 12,
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: AppTypography.title.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Line + soft area chart; the newest point is highlighted with its value.
class _ChartPainter extends CustomPainter {
  _ChartPainter({
    required this.values,
    required this.reveal,
    required this.labelStyle,
    required this.unit,
  });

  final List<double> values;

  /// 0–1: how much of the line is drawn (left to right).
  final double reveal;
  final TextStyle labelStyle;
  final String Function(String seconds) unit;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) {
      return;
    }
    const double left = 34;
    const double top = 22;
    const double bottom = 8;
    final double w = size.width - left - 8;
    final double h = size.height - top - bottom;
    final double maxV = math.max(5, (values.reduce(math.max) / 5).ceil() * 5)
        .toDouble();

    // Grid lines with second labels.
    final Paint grid = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;
    for (int i = 0; i <= 2; i++) {
      final double y = top + h * i / 2;
      canvas.drawLine(Offset(left, y), Offset(left + w, y), grid);
      final double v = maxV * (1 - i / 2);
      final TextPainter tp = TextPainter(
        text: TextSpan(text: unit(v.toStringAsFixed(0)), style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, y - tp.height / 2));
    }

    final List<Offset> pts = <Offset>[
      for (int i = 0; i < values.length; i++)
        Offset(
          left + (values.length == 1 ? w / 2 : w * i / (values.length - 1)),
          top + h * (1 - values[i] / maxV),
        ),
    ];

    // Clip to the revealed width so the line draws in.
    canvas.save();
    canvas.clipRect(
      Rect.fromLTWH(0, 0, left + w * reveal + 8, size.height),
    );

    final Path line = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i < pts.length; i++) {
      final Offset a = pts[i - 1];
      final Offset b = pts[i];
      final double mx = (a.dx + b.dx) / 2;
      line.cubicTo(mx, a.dy, mx, b.dy, b.dx, b.dy);
    }
    if (pts.length > 1) {
      final Path area = Path.from(line)
        ..lineTo(pts.last.dx, top + h)
        ..lineTo(pts.first.dx, top + h)
        ..close();
      canvas.drawPath(
        area,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              AppColors.accent.withValues(alpha: 0.28),
              AppColors.accent.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromLTWH(left, top, w, h)),
      );
      canvas.drawPath(
        line,
        Paint()
          ..color = AppColors.primary
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round,
      );
    }
    for (int i = 0; i < pts.length; i++) {
      final bool last = i == pts.length - 1;
      canvas.drawCircle(
        pts[i],
        last ? 7 : 4,
        Paint()..color = AppColors.surface,
      );
      canvas.drawCircle(
        pts[i],
        last ? 5 : 3,
        Paint()..color = last ? AppColors.streakFg : AppColors.primary,
      );
    }
    canvas.restore();

    // Value above the newest point once the line reaches it.
    if (reveal > 0.95) {
      final Offset p = pts.last;
      final TextPainter tp = TextPainter(
        text: TextSpan(
          text: unit(values.last.toStringAsFixed(1)),
          style: labelStyle.copyWith(
            color: AppColors.ink,
            fontWeight: FontWeight.w900,
            fontSize: 12,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final double x = (p.dx - tp.width / 2).clamp(left, size.width - tp.width);
      tp.paint(canvas, Offset(x, math.max(0, p.dy - tp.height - 8)));
    }
  }

  @override
  bool shouldRepaint(_ChartPainter old) =>
      old.reveal != reveal || old.values != values;
}
