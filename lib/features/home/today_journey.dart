import 'package:material_ui/material_ui.dart';

import '../../app/l10n/app_localizations.dart';
import '../../app/theme/tokens.dart';
import '../../core/domain/enums.dart';
import '../../core/motion/app_motion.dart';
import '../../core/plan/plan_models.dart';
import '../../core/widgets/info_sheet.dart';
import 'home_copy.dart';

/// Where a Today item sits in the day's flow.
enum JourneyStatus { done, next, upcoming, locked, blocked }

/// Width of the timeline rail (nodes and connectors).
const double _railWidth = 44;
const double _nodeSize = 34;

/// Vertical timeline of today's items: nodes joined by a line that fills as
/// items are completed. The next item pulses; a just-finished item draws its
/// check, the line flows down, and the next card drops into place.
class TodayJourney extends StatelessWidget {
  const TodayJourney({
    super.key,
    required this.l10n,
    required this.items,
    required this.statuses,
    required this.onTapItem,
    this.celebrateId,
    this.infoFor,
  });

  final AppLocalizations l10n;
  final List<TodayItem> items;
  final List<JourneyStatus> statuses;
  final ValueChanged<TodayItem> onTapItem;

  /// Explanation for an item's "i" button; null hides the button.
  final InfoContent Function(TodayItem item)? infoFor;

  /// Item that was just completed; its step animates once.
  final String? celebrateId;

  @override
  Widget build(BuildContext context) {
    final int celebrateIndex = items.indexWhere(
      (TodayItem i) => i.id == celebrateId,
    );
    return Column(
      children: [
        for (int i = 0; i < items.length; i++)
          Reveal(
            from: i.isEven ? RevealFrom.left : RevealFrom.right,
            delay: AppMotion.stagger(
              i,
              base: const Duration(milliseconds: 260),
            ),
            child: _JourneyStep(
              l10n: l10n,
              item: items[i],
              status: statuses[i],
              index: i,
              isFirst: i == 0,
              isLast: i == items.length - 1,
              previousDone: i > 0 && statuses[i - 1] == JourneyStatus.done,
              celebrate: i == celebrateIndex,
              arrivingAfterCelebration:
                  celebrateIndex >= 0 && i == celebrateIndex + 1,
              celebrationKey: celebrateId,
              info: infoFor?.call(items[i]),
              onTap: () => onTapItem(items[i]),
            ),
          ),
      ],
    );
  }
}

class _JourneyStep extends StatelessWidget {
  const _JourneyStep({
    required this.l10n,
    required this.item,
    required this.status,
    required this.index,
    required this.isFirst,
    required this.isLast,
    required this.previousDone,
    required this.celebrate,
    required this.arrivingAfterCelebration,
    required this.celebrationKey,
    required this.onTap,
    this.info,
  });

  final AppLocalizations l10n;
  final TodayItem item;
  final JourneyStatus status;
  final InfoContent? info;
  final int index;
  final bool isFirst;
  final bool isLast;
  final bool previousDone;
  final bool celebrate;
  final bool arrivingAfterCelebration;
  final String? celebrationKey;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Line timing: on first open the line draws down step by step; after a
    // completion it flows from the finished node into the next one.
    final Duration baseDelay = AppMotion.stagger(
      index * 2,
      base: const Duration(milliseconds: 420),
    );
    final Duration topDelay = arrivingAfterCelebration
        ? const Duration(milliseconds: 950)
        : baseDelay;
    final Duration bottomDelay = celebrate
        ? const Duration(milliseconds: 600)
        : baseDelay + AppMotion.staggerStep;

    Widget card = _StepCard(
      l10n: l10n,
      item: item,
      status: status,
      celebrate: celebrate,
      info: info,
      onTap: onTap,
    );
    if (arrivingAfterCelebration && status == JourneyStatus.next) {
      card = Reveal(
        key: ValueKey<String>('drop-${item.id}-$celebrationKey'),
        from: RevealFrom.drop,
        delay: const Duration(milliseconds: 1050),
        child: card,
      );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: _railWidth,
            child: Column(
              children: [
                Expanded(
                  child: isFirst
                      ? const SizedBox.shrink()
                      : _Connector(
                          key: ValueKey<String>(
                            'top-${item.id}-${arrivingAfterCelebration ? celebrationKey : ''}',
                          ),
                          filled: previousDone,
                          delay: topDelay,
                        ),
                ),
                _Node(
                  key: ValueKey<String>(
                    'node-${item.id}-${celebrate ? celebrationKey : ''}',
                  ),
                  item: item,
                  status: status,
                  celebrate: celebrate,
                ),
                Expanded(
                  child: isLast
                      ? const SizedBox.shrink()
                      : _Connector(
                          key: ValueKey<String>(
                            'bottom-${item.id}-${celebrate ? celebrationKey : ''}',
                          ),
                          filled: status == JourneyStatus.done,
                          delay: bottomDelay,
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs - 2),
              child: card,
            ),
          ),
        ],
      ),
    );
  }
}

/// Rail segment; the fill grows downward when [filled].
class _Connector extends StatelessWidget {
  const _Connector({super.key, required this.filled, required this.delay});

  final bool filled;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    // Painted, not sized: the row uses IntrinsicHeight, and a zero-height
    // FractionallySizedBox would report an infinite intrinsic height.
    return AnimatedFraction(
      value: filled ? 1 : 0,
      delay: delay,
      duration: const Duration(milliseconds: 420),
      builder: (BuildContext context, double v) => CustomPaint(
        painter: _ConnectorPainter(progress: v),
        child: const SizedBox(width: _railWidth),
      ),
    );
  }
}

class _ConnectorPainter extends CustomPainter {
  _ConnectorPainter({required this.progress});

  final double progress;

  static const double _width = 3;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.height <= 0) {
      return;
    }
    final double x = size.width / 2;
    final RRect track = RRect.fromRectAndRadius(
      Rect.fromLTWH(x - _width / 2, 0, _width, size.height),
      const Radius.circular(_width / 2),
    );
    canvas.drawRRect(track, Paint()..color = AppColors.border);
    if (progress <= 0) {
      return;
    }
    final Rect fillRect = Rect.fromLTWH(
      x - _width / 2,
      0,
      _width,
      size.height * progress,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(fillRect, const Radius.circular(_width / 2)),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[AppColors.primary, AppColors.accent],
        ).createShader(fillRect),
    );
  }

  @override
  bool shouldRepaint(covariant _ConnectorPainter old) =>
      old.progress != progress;
}

class _Node extends StatelessWidget {
  const _Node({
    super.key,
    required this.item,
    required this.status,
    required this.celebrate,
  });

  final TodayItem item;
  final JourneyStatus status;
  final bool celebrate;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case JourneyStatus.done:
        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            if (celebrate)
              const Positioned(
                left: (_nodeSize - 88) / 2,
                top: (_nodeSize - 88) / 2,
                width: 88,
                height: 88,
                child: CompletionBurst(
                  size: 88,
                  color: AppColors.accent,
                  delay: Duration(milliseconds: 380),
                ),
              ),
            AnimatedCheckBadge(
              size: _nodeSize,
              color: AppColors.primary,
              checkColor: AppColors.textOnPrimary,
              play: celebrate,
              delay: const Duration(milliseconds: 150),
            ),
          ],
        );
      case JourneyStatus.next:
        return const PulseHalo(
          color: AppColors.accent,
          size: _nodeSize,
          child: _NodeCircle(
            fill: AppColors.ink,
            border: null,
            child: Icon(
              Icons.play_arrow_rounded,
              size: 20,
              color: AppColors.textOnPrimary,
            ),
          ),
        );
      case JourneyStatus.locked:
        return const _NodeCircle(
          fill: AppColors.surfaceMuted,
          border: AppColors.border,
          child: Icon(
            Icons.lock_rounded,
            size: 16,
            color: AppColors.textSecondary,
          ),
        );
      case JourneyStatus.upcoming:
      case JourneyStatus.blocked:
        return _NodeCircle(
          fill: AppColors.surface,
          border: status == JourneyStatus.blocked
              ? AppColors.border
              : AppColors.borderStrong,
          child: item.kind == SessionKind.strengthening
              ? Text(
                  '${item.sessionNumber ?? 1}',
                  style: AppTypography.caption.copyWith(
                    color: status == JourneyStatus.blocked
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                )
              : Icon(
                  _kindIcon(item.kind),
                  size: 16,
                  color: status == JourneyStatus.blocked
                      ? AppColors.textSecondary
                      : AppColors.textPrimary,
                ),
        );
    }
  }
}

class _NodeCircle extends StatelessWidget {
  const _NodeCircle({
    required this.fill,
    required this.border,
    required this.child,
  });

  final Color fill;
  final Color? border;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _nodeSize,
      height: _nodeSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: fill,
        shape: BoxShape.circle,
        border: border == null ? null : Border.all(color: border!, width: 1.5),
      ),
      child: child,
    );
  }
}

IconData _kindIcon(SessionKind kind) {
  return switch (kind) {
    SessionKind.strengthening => Icons.adjust_rounded,
    SessionKind.body => Icons.accessibility_new_rounded,
    SessionKind.breathing => Icons.air_rounded,
    SessionKind.relaxation => Icons.spa_outlined,
  };
}

/// Colours for the icon tile of each kind.
({Color bg, Color fg}) _kindColors(SessionKind kind) {
  return switch (kind) {
    SessionKind.strengthening => (bg: AppColors.mint, fg: AppColors.primary),
    SessionKind.body => (
      bg: AppColors.goalBladderBg,
      fg: AppColors.goalBladderFg,
    ),
    SessionKind.breathing => (
      bg: AppColors.goalSurgeryBg,
      fg: AppColors.goalSurgeryFg,
    ),
    SessionKind.relaxation => (
      bg: AppColors.goalSurgeryBg,
      fg: AppColors.goalSurgeryFg,
    ),
  };
}

String _sectionLabel(AppLocalizations l10n, SessionKind kind) {
  return switch (kind) {
    SessionKind.strengthening => l10n.h1SectionPelvicFloor,
    SessionKind.body => l10n.h1SectionBody,
    SessionKind.breathing || SessionKind.relaxation => l10n.h1SectionBreathe,
  };
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.l10n,
    required this.item,
    required this.status,
    required this.celebrate,
    required this.onTap,
    this.info,
  });

  final AppLocalizations l10n;
  final TodayItem item;
  final JourneyStatus status;
  final bool celebrate;
  final VoidCallback onTap;
  final InfoContent? info;

  @override
  Widget build(BuildContext context) {
    final bool isNext = status == JourneyStatus.next;
    final bool isDone = status == JourneyStatus.done;
    final bool isLocked = status == JourneyStatus.locked;
    final bool dim = status == JourneyStatus.blocked;
    final String title = HomeCopy.itemTitle(l10n, item);
    final String meta = isLocked
        ? l10n.h1BodyCardLocked
        : HomeCopy.itemMeta(l10n, item);
    final ({Color bg, Color fg}) colors = _kindColors(item.kind);

    final Widget body = Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isDone ? AppColors.surface : colors.bg,
            borderRadius: AppRadii.mdAll,
          ),
          alignment: Alignment.center,
          child: Icon(
            _kindIcon(item.kind),
            size: 22,
            color: dim ? AppColors.textSecondary : colors.fg,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      (isNext ? l10n.h1UpNext : _sectionLabel(l10n, item.kind))
                          .toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(
                        fontSize: 11,
                        letterSpacing: 0.6,
                        fontWeight: FontWeight.w800,
                        color: isNext
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  if (item.optional) ...[
                    const SizedBox(width: AppSpacing.xs),
                    _Tag(label: l10n.h1SessionOptional),
                  ],
                  if (info != null)
                    SizedBox(
                      width: 28,
                      height: 22,
                      child: OverflowBox(
                        maxWidth: AppSpacing.minTouchTarget,
                        maxHeight: AppSpacing.minTouchTarget,
                        child: InfoButton(content: info!, size: 20),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: AppTypography.body.copyWith(
                  fontWeight: FontWeight.w800,
                  color: dim ? AppColors.textSecondary : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(
                    isLocked
                        ? Icons.workspace_premium_outlined
                        : (isDone
                              ? Icons.check_circle_rounded
                              : Icons.schedule_rounded),
                    size: 14,
                    color: isDone ? AppColors.primary : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Flexible(child: Text(meta, style: AppTypography.caption)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        if (isNext)
          _StartPill(label: l10n.h1ItemStart)
        else if (isLocked)
          const Icon(Icons.lock_outline_rounded, color: AppColors.textSecondary)
        else if (!isDone && !dim)
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textSecondary,
          ),
      ],
    );

    final Color background = isDone
        ? AppColors.surfaceMuted
        : AppColors.surface;
    Widget card = AnimatedContainer(
      duration: AppMotion.quick,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadii.lgAll,
        border: Border.all(
          color: isNext ? AppColors.accent : AppColors.border,
          width: isNext ? 1.5 : 1,
        ),
        boxShadow: isNext ? AppElevation.level2 : AppElevation.none,
      ),
      child: body,
    );

    if (celebrate) {
      card = _CelebrateFlash(child: card);
    }

    return PressScale(
      onTap: onTap,
      semanticLabel: '$title. $meta',
      child: card,
    );
  }
}

/// Mint wash that fades out over the finished card.
class _CelebrateFlash extends StatelessWidget {
  const _CelebrateFlash({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (AppMotion.isReduced(context)) {
      return child;
    }
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 1, end: 0),
      duration: const Duration(milliseconds: 1400),
      curve: Curves.easeOutCubic,
      child: child,
      builder: (BuildContext context, double t, Widget? child) {
        return Stack(
          children: [
            child!,
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.18 * t),
                    borderRadius: AppRadii.lgAll,
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

class _StartPill extends StatelessWidget {
  const _StartPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: const BoxDecoration(
        color: AppColors.ink,
        borderRadius: AppRadii.pillAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.textOnPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 2),
          const NudgeArrow(
            icon: Icons.chevron_right_rounded,
            color: AppColors.textOnPrimary,
            size: 18,
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: const BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadii.pillAll,
      ),
      child: Text(label, style: AppTypography.caption.copyWith(fontSize: 11)),
    );
  }
}

/// Small ring showing how much of today is done, with "n of m" inside.
class TodayProgressRing extends StatelessWidget {
  const TodayProgressRing({
    super.key,
    required this.done,
    required this.total,
    this.size = 46,
  });

  final int done;
  final int total;
  final double size;

  @override
  Widget build(BuildContext context) {
    final double fraction = total == 0 ? 0 : done / total;
    return SizedBox(
      width: size,
      height: size,
      child: AnimatedFraction(
        value: fraction,
        delay: const Duration(milliseconds: 300),
        builder: (BuildContext context, double v) => CustomPaint(
          painter: RingPainter(
            progress: v,
            track: AppColors.surfaceMuted,
            fill: AppColors.primary,
            stroke: 5,
          ),
          child: Center(
            child: Text(
              '$done/$total',
              style: AppTypography.caption.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Circular progress ring (round caps) used for small stat rings.
class RingPainter extends CustomPainter {
  RingPainter({
    required this.progress,
    required this.track,
    required this.fill,
    this.stroke = 6,
  });

  final double progress;
  final Color track;
  final Color fill;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Rect arc = rect.deflate(stroke / 2);
    canvas.drawArc(
      arc,
      0,
      6.283185307179586,
      false,
      Paint()
        ..color = track
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );
    if (progress <= 0) {
      return;
    }
    canvas.drawArc(
      arc,
      -1.5707963267948966,
      6.283185307179586 * progress.clamp(0.0, 1.0),
      false,
      Paint()
        ..color = fill
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant RingPainter old) =>
      old.progress != progress || old.fill != fill || old.track != track;
}
