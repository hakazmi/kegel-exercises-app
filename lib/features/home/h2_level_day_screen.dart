import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/l10n/app_localizations.dart';
import '../../app/router.dart';
import '../../app/theme/system_ui.dart';
import '../../app/theme/tokens.dart';
import '../../core/content/content_models.dart';
import '../../core/content/info_copy.dart';
import '../../core/data/providers.dart';
import '../../core/domain/enums.dart';
import '../../core/domain/session_record.dart';
import '../../core/domain/user_profile.dart';
import '../../core/motion/app_motion.dart';
import '../../core/plan/plan_models.dart';
import '../../core/plan/plan_rules.dart';
import '../../core/plan/session_definition.dart';
import '../../core/widgets/widgets.dart';
import 'home_copy.dart';

/// One day of a level: what it contains, as a connected plan.
///
/// The current day of the current level shows today's real items (done
/// ticks, Start). Earlier days are view-only and shown as completed.
class H2LevelDayScreen extends ConsumerWidget {
  const H2LevelDayScreen({super.key, required this.level, required this.day});

  final int level;
  final int day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final UserProfile profile = ref.watch(userProfileProvider);
    final bool isPremium = ref.watch(isPremiumProvider);
    final List<LevelContent> levels =
        ref.watch(levelsProvider).asData?.value ?? const <LevelContent>[];
    final List<ExerciseContent> exercises =
        ref.watch(exercisesProvider).asData?.value ?? const <ExerciseContent>[];
    final List<TrackContent> tracks =
        ref.watch(tracksProvider).asData?.value ?? const <TrackContent>[];
    final List<SessionRecord> sessions =
        ref.watch(sessionsProvider).asData?.value ?? const <SessionRecord>[];
    final TodayPlan? today = ref.watch(todayPlanProvider).asData?.value;

    if (levels.isEmpty) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final LevelContent levelContent = levels.firstWhere(
      (LevelContent l) => l.id == level,
      orElse: () => levels.first,
    );
    TrackContent? track;
    for (final TrackContent t in tracks) {
      if (t.id == profile.track.contentId) {
        track = t;
      }
    }
    final Map<String, ExerciseContent> byId = <String, ExerciseContent>{
      for (final ExerciseContent e in exercises) e.id: e,
    };

    final int dayInLevel =
        PlanRules.dayInLevel(profile: profile, sessions: sessions);
    final bool isToday = level == profile.level && day == dayInLevel;
    final List<TodayItem> items = isToday && today != null
        ? today.items
        : _itemsForDay(
            levelContent: levelContent,
            profile: profile,
            track: track,
            byId: byId,
            isPremium: isPremium,
          );

    final List<_DayPart> parts = <_DayPart>[
      for (final TodayItem item in items)
        _DayPart(
          item: item,
          done: isToday ? item.done : true,
          definition: SessionDefinitionBuilder.fromLevelAndItem(
            level: levelContent,
            item: item,
            sessionsToday: profile.sessionsPerDay.clamp(1, 3),
            track: track,
            exercisesById: byId,
          ),
        ),
    ];
    final int totalSeconds =
        parts.fold<int>(0, (int s, _DayPart p) => s + p.definition.durationSeconds);
    TodayItem? nextItem;
    if (isToday) {
      for (final TodayItem item in items) {
        if (!item.done && !item.locked) {
          nextItem = item;
          break;
        }
      }
    }

    final LevelPalette palette = LevelPalette.of(level);
    final DayPose pose = DayPose.forDay(day);
    final int exerciseCount = parts.fold<int>(
      0,
      (int s, _DayPart p) =>
          s + p.definition.blocks.where((SessionBlockDef b) => !b.isRest).length,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppSystemUi.lightScreen,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            // Soft wash of the level's colour behind the top of the page.
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 340,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[palette.tint, AppColors.background],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.xs,
                        AppSpacing.lg,
                        AppSpacing.md,
                      ),
                      children: [
                        Row(
                          children: [
                            PressScale(
                              onTap: () => context.pop(),
                              semanticLabel: l10n.commonBack,
                              child: Container(
                                width: AppSpacing.minTouchTarget,
                                height: AppSpacing.minTouchTarget,
                                decoration: const BoxDecoration(
                                  color: AppColors.surface,
                                  shape: BoxShape.circle,
                                  boxShadow: AppElevation.level1,
                                ),
                                child: const Icon(
                                  Icons.arrow_back_rounded,
                                  color: AppColors.ink,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                l10n.h1LevelName(
                                  level,
                                  HomeCopy.levelName(l10n, level),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.body.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Room for the figure's head to rise above the card.
                        const SizedBox(height: _DayHero.rise),
                        Reveal(
                          from: RevealFrom.drop,
                          child: _DayHero(
                            l10n: l10n,
                            palette: palette,
                            pose: pose,
                            day: day,
                            completed: !isToday,
                            motivation: _motivation(
                              l10n,
                              day,
                              HomeCopy.daysInLevel(levelContent),
                              open: levelContent.dayEnd == null,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Reveal(
                          from: RevealFrom.rise,
                          delay: const Duration(milliseconds: 80),
                          child: Row(
                            children: [
                              Expanded(
                                child: _StatTile(
                                  color: AppColors.lavender,
                                  icon: Icons.schedule_rounded,
                                  label: l10n.h2StatTime,
                                  value: Text(
                                    HomeCopy.formatDuration(l10n, totalSeconds),
                                    maxLines: 1,
                                    style: _StatTile.valueStyle,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Expanded(
                                child: _StatTile(
                                  color: AppColors.pistachio,
                                  icon: Icons.fitness_center_rounded,
                                  label: l10n.h2StatExercises,
                                  value: CountUpText(
                                    value: exerciseCount,
                                    format: (int v) => '$v',
                                    style: _StatTile.valueStyle,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Expanded(
                                child: _StatTile(
                                  color: AppColors.peach,
                                  icon: Icons.layers_rounded,
                                  label: l10n.h2StatParts,
                                  value: CountUpText(
                                    value: parts.length,
                                    format: (int v) => '$v',
                                    style: _StatTile.valueStyle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (totalSeconds > 0) ...[
                          const SizedBox(height: AppSpacing.md),
                          Reveal(
                            from: RevealFrom.rise,
                            delay: const Duration(milliseconds: 140),
                            child: _TimeSplit(
                              l10n: l10n,
                              parts: parts,
                              totalSeconds: totalSeconds,
                            ),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          isToday ? l10n.h1JourneyTitle : l10n.h2DayPlanTitle,
                          style: AppTypography.title.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        for (int i = 0; i < parts.length; i++)
                          Reveal(
                            from: i.isEven ? RevealFrom.left : RevealFrom.right,
                            delay: AppMotion.stagger(
                              i,
                              base: const Duration(milliseconds: 200),
                            ),
                            child: _PartRow(
                              l10n: l10n,
                              part: parts[i],
                              byId: byId,
                              isFirst: i == 0,
                              isLast: i == parts.length - 1,
                              initiallyOpen: i == 0,
                              highlight: parts[i].item.id == nextItem?.id,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.xs,
                      AppSpacing.lg,
                      AppSpacing.md,
                    ),
                    child: Column(
                      children: [
                        SecondaryButton(
                          label: l10n.s1ShowMeHow,
                          icon: Icons.play_circle_outline_rounded,
                          onPressed: () =>
                              context.push('${AppRoutes.tutorial}?replay=1'),
                        ),
                        if (nextItem != null) ...[
                          const SizedBox(height: AppSpacing.sm),
                          PrimaryButton(
                            label: l10n.h1StartSession,
                            icon: Icons.play_arrow_rounded,
                            shimmer: true,
                            trailingArrow: true,
                            onPressed: () => context.push(
                              '${AppRoutes.before}?itemId=${Uri.encodeComponent(nextItem!.id)}',
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Plan items a training day of this level contains (non-rest day).
  List<TodayItem> _itemsForDay({
    required LevelContent levelContent,
    required UserProfile profile,
    required TrackContent? track,
    required Map<String, ExerciseContent> byId,
    required bool isPremium,
  }) {
    final bool relaxationOnly = profile.track == TrackId.relaxationFirst;
    final List<TodayItem> items = <TodayItem>[];
    if (!relaxationOnly) {
      final int planned = PlanRules.plannedStrengtheningSlots(profile.sessionsPerDay);
      for (int i = 1; i <= planned; i++) {
        items.add(
          TodayItem(
            id: 'strength_$i',
            kind: SessionKind.strengthening,
            label: 'Session $i',
            durationSeconds:
                SessionDefinitionBuilder.strengtheningDurationForLevel(levelContent),
            done: true,
            optional: planned == 3 && i == 3,
            sessionNumber: i,
          ),
        );
      }
      final List<String> body =
          levelContent.bodyExercisesForTrack(profile.track.contentId);
      if (body.isNotEmpty && levelContent.id >= 2) {
        items.add(
          TodayItem(
            id: 'body_1',
            kind: SessionKind.body,
            label: 'Body and function',
            durationSeconds:
                SessionDefinitionBuilder.estimateBodyDuration(body, byId),
            done: true,
            locked: !isPremium,
            exerciseIds: body,
          ),
        );
      }
    }
    final List<String> breathe =
        track?.breatheCard ?? const <String>['diaphragmatic_breathing'];
    items.add(
      TodayItem(
        id: 'breathe_1',
        kind: relaxationOnly ? SessionKind.relaxation : SessionKind.breathing,
        label: 'Relax and breathe',
        durationSeconds: SessionDefinitionBuilder.estimateBreatheDuration(
          breathe,
          byId,
          levelContent.dailyBreathingSec,
        ),
        done: true,
        exerciseIds: breathe,
      ),
    );
    return items;
  }
}

class _DayPart {
  const _DayPart({
    required this.item,
    required this.done,
    required this.definition,
  });

  final TodayItem item;
  final bool done;
  final SessionDefinition definition;
}

/// Colour and icon for each kind of part (used by the split bar, legend
/// and timeline so the same part always has the same colour).
({Color color, Color deep, IconData icon}) _partStyle(SessionKind kind) =>
    switch (kind) {
      SessionKind.strengthening => (
          color: AppColors.lavender,
          deep: LevelPalette.levels[0].deep,
          icon: Icons.adjust_rounded,
        ),
      SessionKind.body => (
          color: AppColors.peach,
          deep: LevelPalette.levels[1].deep,
          icon: Icons.accessibility_new_rounded,
        ),
      SessionKind.breathing || SessionKind.relaxation => (
          color: AppColors.pistachio,
          deep: LevelPalette.levels[4].deep,
          icon: Icons.air_rounded,
        ),
    };

String _partTitle(AppLocalizations l10n, TodayItem item) => switch (item.kind) {
      SessionKind.strengthening => l10n.h1SessionLabel(item.sessionNumber ?? 1),
      SessionKind.body => l10n.h1BodyCardTitle,
      SessionKind.breathing || SessionKind.relaxation => l10n.h1SectionBreathe,
    };

/// Day cover card in the level's colour: "Day N" large, the position, and
/// the day's 3D figure standing in the card with its head rising above the
/// card's top edge.
class _DayHero extends StatelessWidget {
  const _DayHero({
    required this.l10n,
    required this.palette,
    required this.pose,
    required this.day,
    required this.completed,
    required this.motivation,
  });

  final AppLocalizations l10n;
  final LevelPalette palette;
  final DayPose pose;
  final int day;
  final bool completed;

  /// Short encouragement shown under "Day N".
  final String motivation;

  static const double height = 176;

  /// How far the figure rises above the card.
  static const double rise = 56;

  @override
  Widget build(BuildContext context) {
    final bool wide = pose.isWide;
    return SizedBox(
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: AppRadii.xlAll,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    palette.base,
                    Color.lerp(palette.base, AppColors.surface, 0.5)!,
                  ],
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: palette.deep.withValues(alpha: 0.16),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: AppRadii.xlAll,
                child: Stack(
                  children: [
                    Positioned(
                      right: -40,
                      bottom: -60,
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.surface.withValues(alpha: 0.4),
                            width: 26,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // The figure stands on the card's floor; its head breaks out of
          // the top edge for depth.
          Positioned(
            right: wide ? 0 : AppSpacing.md,
            bottom: wide ? AppSpacing.xs : AppSpacing.sm,
            child: FloatBob(
              lift: 3,
              period: const Duration(milliseconds: 3400),
              child: PoseFigure(
                pose: pose,
                width: wide ? 190 : 130,
                height: wide ? 110 : height + rise - AppSpacing.sm,
                glowColor: AppColors.surface,
                semanticLabel: pose.label(l10n),
              ),
            ),
          ),
          Positioned(
            left: AppSpacing.md,
            top: AppSpacing.md,
            // Keep the words clear of the figure (wide poses lie along the
            // bottom, so they need less room on the right).
            right: wide ? 120 : 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: completed ? AppColors.surface : AppColors.ink,
                    borderRadius: AppRadii.pillAll,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        completed
                            ? Icons.check_circle_rounded
                            : Icons.play_circle_fill_rounded,
                        size: 14,
                        color: completed ? AppColors.success : palette.base,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        completed ? l10n.h2TagCompleted : l10n.h2TagCurrent,
                        style: AppTypography.caption.copyWith(
                          color: completed
                              ? AppColors.ink
                              : AppColors.textOnPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.h2DayLabel(day),
                    maxLines: 1,
                    style: AppTypography.display.copyWith(
                      fontSize: 44,
                      fontWeight: FontWeight.w900,
                      height: 1,
                      letterSpacing: -1,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                // A short line of encouragement for this day.
                Text(
                  motivation,
                  maxLines: wide ? 2 : 3,
                  style: AppTypography.body.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Small coloured stat tile: icon, big value, label (like the reference's
/// coloured summary tiles).
class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.color,
    required this.icon,
    required this.label,
    required this.value,
  });

  final Color color;
  final IconData icon;
  final String label;
  final Widget value;

  static final TextStyle valueStyle = AppTypography.title.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w900,
    height: 1.1,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppRadii.lgAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.7),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 17, color: AppColors.ink),
          ),
          const SizedBox(height: AppSpacing.xs),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: value,
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.caption.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// White card with a segmented bar showing how the day's time is split
/// between its parts, and a legend underneath.
class _TimeSplit extends StatelessWidget {
  const _TimeSplit({
    required this.l10n,
    required this.parts,
    required this.totalSeconds,
  });

  final AppLocalizations l10n;
  final List<_DayPart> parts;
  final int totalSeconds;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.xlAll,
        boxShadow: AppElevation.level1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.h2TimeSplitTitle,
            style: AppTypography.body.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.sm),
          AnimatedFraction(
            value: 1,
            delay: const Duration(milliseconds: 250),
            builder: (BuildContext context, double t) => ClipRRect(
              borderRadius: AppRadii.pillAll,
              child: SizedBox(
                height: 16,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: t.clamp(0.0, 1.0),
                    heightFactor: 1,
                    child: Row(
                      children: [
                        for (int i = 0; i < parts.length; i++) ...[
                          if (i > 0) const SizedBox(width: 3),
                          Expanded(
                            flex: parts[i]
                                .definition
                                .durationSeconds
                                .clamp(1, 1 << 20),
                            child: ColoredBox(
                              color: _partStyle(parts[i].item.kind).color,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.xs,
            children: [
              for (final _DayPart p in parts)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _partStyle(p.item.kind).color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        '${_partTitle(l10n, p.item)} · '
                        '${HomeCopy.formatDuration(l10n, p.definition.durationSeconds)}',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.ink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Timeline row: node + expandable card listing the part's exercises.
class _PartRow extends StatefulWidget {
  const _PartRow({
    required this.l10n,
    required this.part,
    required this.byId,
    required this.isFirst,
    required this.isLast,
    required this.initiallyOpen,
    required this.highlight,
  });

  final AppLocalizations l10n;
  final _DayPart part;
  final Map<String, ExerciseContent> byId;
  final bool isFirst;
  final bool isLast;
  final bool initiallyOpen;
  final bool highlight;

  @override
  State<_PartRow> createState() => _PartRowState();
}

class _PartRowState extends State<_PartRow> {
  late bool _open = widget.initiallyOpen;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = widget.l10n;
    final _DayPart part = widget.part;
    final TodayItem item = part.item;
    final bool locked = item.locked;
    final ({Color color, Color deep, IconData icon}) style =
        _partStyle(item.kind);
    const Color line = AppColors.border;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 36,
            child: Column(
              children: [
                SizedBox(
                  height: 20,
                  child: widget.isFirst
                      ? null
                      : Center(
                          child: Container(
                            width: 3,
                            color: part.done ? AppColors.primary : line,
                          ),
                        ),
                ),
                if (part.done)
                  const AnimatedCheckBadge(
                    size: 28,
                    color: AppColors.primary,
                    checkColor: AppColors.textOnPrimary,
                    strokeWidth: 3,
                  )
                else if (widget.highlight)
                  PulseHalo(
                    color: AppColors.accent,
                    size: 28,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: AppColors.ink,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        size: 18,
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                  )
                else
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: line, width: 2),
                    ),
                    child: locked
                        ? const Icon(
                            Icons.lock_rounded,
                            size: 14,
                            color: AppColors.textSecondary,
                          )
                        : null,
                  ),
                Expanded(
                  child: widget.isLast
                      ? const SizedBox.shrink()
                      : Center(
                          child: Container(
                            width: 3,
                            color: part.done ? AppColors.primary : line,
                          ),
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: AnimatedContainer(
                duration: AppMotion.quick,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadii.xlAll,
                  border: Border.all(
                    color: widget.highlight ? AppColors.ink : AppColors.surface,
                    width: widget.highlight ? 1.5 : 1,
                  ),
                  boxShadow: AppElevation.level1,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    InkWell(
                      borderRadius: AppRadii.xlAll,
                      onTap: () => setState(() => _open = !_open),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: style.color,
                                borderRadius: AppRadii.mdAll,
                              ),
                              child: Icon(
                                style.icon,
                                color: AppColors.ink,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _partTitle(l10n, item),
                                    style: AppTypography.body.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      _Chip(
                                        icon: Icons.schedule_rounded,
                                        label: HomeCopy.formatDuration(
                                          l10n,
                                          part.definition.durationSeconds,
                                        ),
                                        color: style.color
                                            .withValues(alpha: 0.45),
                                      ),
                                      if (item.optional)
                                        _Chip(
                                          label: l10n.h1SessionOptional,
                                          color: AppColors.surfaceMuted,
                                        ),
                                      if (locked)
                                        _Chip(
                                          icon: Icons.lock_rounded,
                                          label: l10n.h1BodyCardLocked,
                                          color: AppColors.surfaceMuted,
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            AnimatedRotation(
                              turns: _open ? 0.5 : 0,
                              duration: AppMotion.quick,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: const BoxDecoration(
                                  color: AppColors.surfaceMuted,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.expand_more_rounded,
                                  color: AppColors.ink,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOutCubic,
                      alignment: Alignment.topCenter,
                      child: _open
                          ? Padding(
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.sm,
                                0,
                                AppSpacing.sm,
                                AppSpacing.sm,
                              ),
                              child: Column(
                                children: [
                                  for (final SessionBlockDef block
                                      in part.definition.blocks)
                                    _BlockLine(
                                      l10n: l10n,
                                      block: block,
                                      byId: widget.byId,
                                      color: style.color,
                                      deep: style.deep,
                                    ),
                                ],
                              ),
                            )
                          : const SizedBox(width: double.infinity),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One exercise inside a part: icon, name, a picture of its rhythm
/// (squeeze and relax bars) and its reps or time.
class _BlockLine extends StatelessWidget {
  const _BlockLine({
    required this.l10n,
    required this.block,
    required this.byId,
    required this.color,
    required this.deep,
  });

  final AppLocalizations l10n;
  final SessionBlockDef block;
  final Map<String, ExerciseContent> byId;
  final Color color;
  final Color deep;

  String? get _exerciseId => switch (block.titleKey) {
        'slowHolds' => 'slow_hold',
        'quickSqueezes' => 'quick_squeeze',
        'breathing' => 'diaphragmatic_breathing',
        'reverseKegel' => 'reverse_kegel',
        'rest' => null,
        _ => block.exerciseId ?? block.titleKey,
      };

  String _name() {
    switch (block.titleKey) {
      case 'slowHolds':
        return l10n.s1BlockSlowHolds;
      case 'quickSqueezes':
        return l10n.s1BlockQuickSqueezes;
      case 'rest':
        return l10n.s1BlockRest;
      case 'breathing':
        return l10n.s1BlockBreathing;
      case 'reverseKegel':
        return l10n.s1BlockReverseKegel;
    }
    final String? id = _exerciseId;
    return (id == null ? null : byId[id]?.name) ?? block.titleKey;
  }

  IconData get _icon => switch (block.type) {
        'hold' => Icons.hourglass_bottom_rounded,
        'quick' => Icons.bolt_rounded,
        'rest' => Icons.pause_rounded,
        'breathing' => Icons.air_rounded,
        'reverse_kegel' => Icons.south_rounded,
        'stretch' => Icons.self_improvement_rounded,
        _ => Icons.accessibility_new_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final String? id = _exerciseId;
    final ExerciseContent? ex = id == null ? null : byId[id];
    final int? reps = block.reps;
    final int? squeeze = block.squeezeSec;
    final int? relax = block.relaxSec;
    final bool rhythm = reps != null &&
        reps > 0 &&
        squeeze != null &&
        relax != null &&
        squeeze > 0;
    final bool rest = block.isRest;

    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.xs),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.xs,
        AppSpacing.xxs,
        AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: rest ? AppColors.surfaceMuted : color.withValues(alpha: 0.22),
        borderRadius: AppRadii.lgAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_icon, size: 18, color: rest ? AppColors.textSecondary : deep),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  _name(),
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
              Text(
                rhythm
                    ? '×$reps'
                    : l10n.s1BlockRestDetail(block.sec ?? block.durationSeconds),
                style: AppTypography.caption.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (ex != null)
                InfoButton(content: InfoCopy.exercise(l10n, ex), size: 22)
              else
                const SizedBox(width: AppSpacing.xs),
            ],
          ),
          if (rhythm) ...[
            const SizedBox(height: AppSpacing.xs),
            _Rhythm(
              reps: reps,
              squeeze: squeeze,
              relax: relax,
              color: deep,
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                _Legend(
                  color: deep,
                  label: '${l10n.h2RhythmSqueeze} ${l10n.s1BlockRestDetail(squeeze)}',
                ),
                _Legend(
                  color: deep.withValues(alpha: 0.25),
                  label: '${l10n.h2RhythmRelax} ${l10n.s1BlockRestDetail(relax)}',
                ),
                Text(
                  l10n.h2RhythmReps(reps),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.ink,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ] else if (!rest && block.durationSeconds > 0) ...[
            const SizedBox(height: AppSpacing.xs),
            // Timed exercise: one bar sized to its share of a minute.
            ClipRRect(
              borderRadius: AppRadii.pillAll,
              child: SizedBox(
                height: 8,
                child: ColoredBox(
                  color: AppColors.surface,
                  child: AnimatedFraction(
                    value: (block.durationSeconds / 120).clamp(0.08, 1.0),
                    builder: (BuildContext context, double v) => Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: v,
                        heightFactor: 1,
                        child: ColoredBox(color: deep),
                      ),
                    ),
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

/// Squeeze/relax pattern: one tall bar per squeeze and a short pale bar per
/// relax, widths in proportion to their seconds (first rounds only).
class _Rhythm extends StatelessWidget {
  const _Rhythm({
    required this.reps,
    required this.squeeze,
    required this.relax,
    required this.color,
  });

  final int reps;
  final int squeeze;
  final int relax;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final int shown = reps.clamp(1, 6);
    return SizedBox(
      height: 26,
      child: AnimatedFraction(
        value: 1,
        delay: const Duration(milliseconds: 200),
        builder: (BuildContext context, double t) => Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (int i = 0; i < shown; i++) ...[
              Expanded(
                flex: squeeze,
                child: Container(
                  height: 26 * (0.3 + 0.7 * t),
                  margin: const EdgeInsets.only(right: 2),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              Expanded(
                flex: relax.clamp(1, 1 << 20),
                child: Container(
                  height: 9,
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ],
            if (reps > shown)
              Padding(
                padding: const EdgeInsets.only(left: 2),
                child: Text(
                  '+${reps - shown}',
                  style: AppTypography.caption.copyWith(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.ink,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color, this.icon});

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppRadii.pillAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: AppColors.ink),
            const SizedBox(width: 3),
          ],
          Flexible(
            child: Text(
              label,
              style: AppTypography.caption.copyWith(
                color: AppColors.ink,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


/// Encouragement for a plan day: a set of short lines that cycle, with a
/// special line on the last day of a level.
String _motivation(
  AppLocalizations l10n,
  int day,
  int span, {
  required bool open,
}) {
  if (!open && day >= span && span > 1) {
    return l10n.h2MotivationLast;
  }
  final List<String> lines = <String>[
    l10n.h2Motivation1,
    l10n.h2Motivation2,
    l10n.h2Motivation3,
    l10n.h2Motivation4,
    l10n.h2Motivation5,
    l10n.h2Motivation6,
    l10n.h2Motivation7,
    l10n.h2Motivation8,
    l10n.h2Motivation9,
    l10n.h2Motivation10,
    l10n.h2Motivation11,
    l10n.h2Motivation12,
    l10n.h2Motivation13,
    l10n.h2Motivation14,
  ];
  return lines[(day - 1) % lines.length];
}
