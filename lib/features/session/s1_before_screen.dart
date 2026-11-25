import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/l10n/app_localizations.dart';
import '../../app/router.dart';
import '../../app/theme/system_ui.dart';
import '../../app/theme/tokens.dart';
import '../../core/content/content_models.dart';
import '../../core/content/exercise_media.dart';
import '../../core/content/info_copy.dart';
import '../../core/data/providers.dart';
import '../../core/domain/enums.dart';
import '../../core/domain/user_profile.dart';
import '../../core/motion/app_motion.dart';
import '../../core/plan/plan_models.dart';
import '../../core/plan/session_definition.dart';
import '../../core/widgets/widgets.dart';
import '../home/home_copy.dart';
import '../tutorial/side_pelvic_demo.dart';

/// S1 Before you start — what this session contains, how to position, cues.
///
/// Dark hero with the session title, a numbered "what's inside" timeline
/// (icon per exercise type, real names from content), reminders, cue
/// toggles and the Start CTA. Panels slide in from alternating sides.
class S1BeforeScreen extends ConsumerWidget {
  const S1BeforeScreen({super.key, this.itemId});

  /// Today-plan item id (e.g. strength_1, body_1, breathe_1).
  final String? itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final UserProfile profile = ref.watch(userProfileProvider);
    final AsyncValue<TodayPlan> planAsync = ref.watch(todayPlanProvider);
    final AsyncValue<List<LevelContent>> levelsAsync = ref.watch(
      levelsProvider,
    );
    final AsyncValue<List<ExerciseContent>> exercisesAsync = ref.watch(
      exercisesProvider,
    );

    if (planAsync.isLoading ||
        levelsAsync.isLoading ||
        exercisesAsync.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.sessionBackground,
        body: Center(child: CircularProgressIndicator(color: AppColors.accent)),
      );
    }
    if (planAsync.hasError || levelsAsync.hasError || exercisesAsync.hasError) {
      return Scaffold(
        body: Center(
          child: Text(
            '${planAsync.error ?? levelsAsync.error ?? exercisesAsync.error}',
          ),
        ),
      );
    }

    final TodayPlan plan = planAsync.requireValue;
    final List<LevelContent> levels = levelsAsync.requireValue;
    final List<ExerciseContent> exercises = exercisesAsync.requireValue;
    final LevelContent level = levels.firstWhere(
      (LevelContent l) => l.id == profile.level,
      orElse: () => levels.first,
    );
    final TodayItem item = _resolveItem(plan, itemId);
    final int strengtheningTotal = plan.items
        .where((TodayItem i) => i.kind == SessionKind.strengthening)
        .length
        .clamp(1, 3);
    final List<TrackContent> tracks =
        ref.watch(tracksProvider).asData?.value ?? const <TrackContent>[];
    TrackContent? trackContent;
    for (final TrackContent t in tracks) {
      if (t.id == profile.track.contentId) {
        trackContent = t;
        break;
      }
    }
    final Map<String, ExerciseContent> byId = <String, ExerciseContent>{
      for (final ExerciseContent e in exercises) e.id: e,
    };
    final SessionDefinition session = SessionDefinitionBuilder.fromLevelAndItem(
      level: level,
      item: item,
      sessionsToday: profile.sessionsPerDay.clamp(1, 3),
      track: trackContent,
      exercisesById: byId,
    );

    return _S1Body(
      l10n: l10n,
      profile: profile,
      plan: plan,
      session: session,
      item: item,
      strengtheningTotal: strengtheningTotal,
      exercisesById: byId,
      onToggleVibration: (bool value) {
        ref
            .read(userProfileProvider.notifier)
            .save(profile.copyWith(vibrationOn: value));
      },
      onToggleVoice: (bool value) {
        ref
            .read(userProfileProvider.notifier)
            .save(profile.copyWith(voiceOn: value));
      },
    );
  }

  TodayItem _resolveItem(TodayPlan plan, String? id) {
    if (id != null) {
      for (final TodayItem item in plan.items) {
        if (item.id == id) {
          return item;
        }
      }
    }
    for (final TodayItem item in plan.items) {
      if (!item.done) {
        return item;
      }
    }
    if (plan.items.isNotEmpty) {
      return plan.items.first;
    }
    return const TodayItem(
      id: 'strength_1',
      kind: SessionKind.strengthening,
      label: '',
      durationSeconds: 55,
      done: false,
      sessionNumber: 1,
    );
  }
}

class _S1Body extends StatelessWidget {
  const _S1Body({
    required this.l10n,
    required this.profile,
    required this.plan,
    required this.session,
    required this.item,
    required this.strengtheningTotal,
    required this.exercisesById,
    required this.onToggleVibration,
    required this.onToggleVoice,
  });

  final AppLocalizations l10n;
  final UserProfile profile;
  final TodayPlan plan;
  final SessionDefinition session;
  final TodayItem item;
  final int strengtheningTotal;
  final Map<String, ExerciseContent> exercisesById;
  final ValueChanged<bool> onToggleVibration;
  final ValueChanged<bool> onToggleVoice;

  @override
  Widget build(BuildContext context) {
    final int number = item.sessionNumber ?? 1;
    final String title = item.kind == SessionKind.strengthening
        ? l10n.s1SessionOf(number, strengtheningTotal)
        : _kindTitle();
    final String meta = session.durationSeconds >= 90
        ? l10n.s1MetaMinutes(
            (session.durationSeconds / 60).ceil(),
            session.partCount,
          )
        : l10n.s1Meta(session.durationSeconds, session.partCount);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppSystemUi.darkHeaderLightBody,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            _HeroHeader(
              l10n: l10n,
              track: plan.track,
              level: plan.level,
              day: plan.dayInLevel,
              title: title,
              meta: meta,
              pose: _poseFor(item.kind),
              position: _positionCopy(l10n, session.position),
              onBack: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(AppRoutes.today);
                }
              },
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                children: [
                  // Animated preview of each Kegel exercise in the session.
                  if (_contentBlocks().isNotEmpty) ...[
                    Reveal(
                      from: RevealFrom.left,
                      delay: const Duration(milliseconds: 80),
                      child: Text(
                        l10n.s1ContentTitle,
                        style: AppTypography.title,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Reveal(
                      from: RevealFrom.rise,
                      delay: const Duration(milliseconds: 120),
                      child: _ExerciseContent(
                        l10n: l10n,
                        blocks: _contentBlocks(),
                        titleOf: _blockTitle,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  Reveal(
                    from: RevealFrom.left,
                    delay: const Duration(milliseconds: 120),
                    child: Text(l10n.s1InsideTitle, style: AppTypography.title),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  for (int i = 0; i < session.blocks.length; i++)
                    Reveal(
                      from: RevealFrom.right,
                      delay: AppMotion.stagger(
                        i,
                        base: const Duration(milliseconds: 180),
                      ),
                      child: _BlockStep(
                        index: i,
                        isLast: i == session.blocks.length - 1,
                        block: session.blocks[i],
                        title: _blockTitle(session.blocks[i]),
                        subtitle: _blockSubtitle(session.blocks[i]),
                        info: _blockInfo(session.blocks[i]),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.md),
                  Reveal(
                    from: RevealFrom.left,
                    delay: AppMotion.stagger(
                      session.blocks.length,
                      base: const Duration(milliseconds: 220),
                    ),
                    child: _RemindersCard(l10n: l10n),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Reveal(
                    from: RevealFrom.right,
                    delay: AppMotion.stagger(
                      session.blocks.length + 1,
                      base: const Duration(milliseconds: 220),
                    ),
                    child: _CuesCard(
                      l10n: l10n,
                      vibrationOn: profile.vibrationOn,
                      voiceOn: profile.voiceOn,
                      onToggleVibration: onToggleVibration,
                      onToggleVoice: onToggleVoice,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Center(
                    child: PressScale(
                      onTap: () =>
                          context.push('${AppRoutes.tutorial}?replay=1'),
                      semanticLabel: l10n.s1ShowMeHow,
                      child: Container(
                        constraints: const BoxConstraints(
                          minHeight: AppSpacing.minTouchTarget,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: AppRadii.pillAll,
                          border: Border.all(color: AppColors.borderStrong),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.play_circle_outline_rounded,
                              size: 20,
                              color: AppColors.textPrimary,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              l10n.s1ShowMeHow,
                              style: AppTypography.body.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            DecoratedBox(
              decoration: const BoxDecoration(
                color: AppColors.background,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    AppSpacing.sm,
                  ),
                  child: PrimaryButton(
                    label: l10n.s1Start,
                    icon: Icons.play_arrow_rounded,
                    shimmer: true,
                    onPressed: () {
                      context.go(
                        '${AppRoutes.countdown}?itemId=${Uri.encodeComponent(session.id)}',
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _kindTitle() => HomeCopy.itemTitle(l10n, item);

  /// Same day figure as the Today level card; calm breathing for
  /// relaxation-first, breathing and relaxation sessions.
  DayPose _poseFor(SessionKind kind) {
    if (plan.track == TrackId.relaxationFirst) {
      return DayPose.restBreathing;
    }
    return switch (kind) {
      SessionKind.strengthening ||
      SessionKind.body => DayPose.forDay(plan.dayInLevel),
      SessionKind.breathing ||
      SessionKind.relaxation => DayPose.restBreathing,
    };
  }

  /// "i" explanation for a block: the exercise's own info when it maps to
  /// one in content, nothing for rest blocks.
  InfoContent? _blockInfo(SessionBlockDef block) {
    final String? exerciseId = switch (block.titleKey) {
      'slowHolds' => 'slow_hold',
      'quickSqueezes' => 'quick_squeeze',
      'breathing' => 'diaphragmatic_breathing',
      'reverseKegel' => 'reverse_kegel',
      'rest' => null,
      _ => block.exerciseId ?? block.titleKey,
    };
    final ExerciseContent? ex = exerciseId == null
        ? null
        : exercisesById[exerciseId];
    return ex == null ? null : InfoCopy.exercise(l10n, ex);
  }

  /// One block per Kegel exercise type (slow holds, quick squeezes), in
  /// session order, for the animated preview cards.
  List<SessionBlockDef> _contentBlocks() {
    final Map<String, SessionBlockDef> byType = <String, SessionBlockDef>{};
    for (final SessionBlockDef b in session.blocks) {
      final bool kegel = b.type == 'hold' || b.type == 'quick';
      if (kegel &&
          b.squeezeSec != null &&
          b.relaxSec != null &&
          !byType.containsKey(b.type)) {
        byType[b.type] = b;
      }
    }
    return byType.values.toList();
  }

  String _blockTitle(SessionBlockDef block) {
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
    // Stretch, strong hold and body moves: the exercise name from content.
    final ExerciseContent? ex = block.exerciseId == null
        ? null
        : exercisesById[block.exerciseId];
    return ex?.name ?? exercisesById[block.titleKey]?.name ?? block.titleKey;
  }

  String _blockSubtitle(SessionBlockDef block) {
    if (block.titleKey == 'reverseKegel') {
      return l10n.s1ReverseKegelDescription;
    }
    final String? exerciseId = switch (block.titleKey) {
      'slowHolds' => 'slow_hold',
      'quickSqueezes' => 'quick_squeeze',
      'breathing' => 'diaphragmatic_breathing',
      _ => block.exerciseId,
    };
    final String? description = exerciseId == null
        ? null
        : exercisesById[exerciseId]?.description;
    if (description != null && block.titleKey != 'rest') {
      return description;
    }
    if (block.reps != null &&
        block.squeezeSec != null &&
        block.relaxSec != null) {
      return l10n.s1BlockRepsDetail(
        block.reps!,
        block.squeezeSec!,
        block.relaxSec!,
      );
    }
    return l10n.s1BlockRestDetail(block.sec ?? block.durationSeconds);
  }

  String _positionCopy(AppLocalizations l10n, String position) {
    switch (positionCopyKey(position)) {
      case 'sitting':
        return l10n.s1PositionSitting;
      case 'sittingAndStanding':
        return l10n.s1PositionSittingAndStanding;
      case 'standing':
        return l10n.s1PositionStanding;
      case 'any':
        return l10n.s1PositionAny;
      case 'lyingOrSitting':
      default:
        return l10n.s1PositionLyingOrSitting;
    }
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({
    required this.l10n,
    required this.track,
    required this.level,
    required this.day,
    required this.title,
    required this.meta,
    required this.pose,
    required this.position,
    required this.onBack,
  });

  final AppLocalizations l10n;
  final TrackId track;
  final int level;
  final int day;
  final String title;
  final String meta;
  final DayPose pose;
  final String position;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final String eyebrow = track == TrackId.relaxationFirst
        ? l10n.s1RelaxationDay(day)
        : l10n.s1LevelDay(level, day);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(AppRadii.xl),
      ),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              AppColors.sessionBackground,
              AppColors.sessionSurface,
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -60,
              top: -40,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: <Color>[
                      AppColors.accent.withValues(alpha: 0.3),
                      AppColors.accent.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xs,
                  AppSpacing.xxs,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        tooltip: l10n.commonBack,
                        onPressed: onBack,
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: AppColors.sessionText,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: AppSpacing.sm),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Reveal(
                              from: RevealFrom.left,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    eyebrow.toUpperCase(),
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.accent,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    title,
                                    style: AppTypography.display.copyWith(
                                      color: AppColors.sessionText,
                                      fontSize: 26,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.xxs),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.schedule_rounded,
                                        size: 16,
                                        color: AppColors.sessionTextSecondary,
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          meta,
                                          style: AppTypography.body.copyWith(
                                            color:
                                                AppColors.sessionTextSecondary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Reveal(
                            from: RevealFrom.drop,
                            delay: const Duration(milliseconds: 120),
                            child: FloatBob(
                              lift: 4,
                              period: const Duration(milliseconds: 3000),
                              child: PoseFigure(
                                pose: pose,
                                width: pose.isWide ? 150 : 104,
                                height: pose.isWide ? 90 : 130,
                                glowColor: AppColors.accent,
                                semanticLabel: pose.label(l10n),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Padding(
                      padding: const EdgeInsets.only(left: AppSpacing.sm),
                      child: Reveal(
                        from: RevealFrom.rise,
                        delay: const Duration(milliseconds: 160),
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.sessionText.withValues(
                              alpha: 0.06,
                            ),
                            borderRadius: AppRadii.lgAll,
                            border: Border.all(
                              color: AppColors.sessionText.withValues(
                                alpha: 0.08,
                              ),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.airline_seat_flat_rounded,
                                size: 20,
                                color: AppColors.accent,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Expanded(
                                child: Text(
                                  position,
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.sessionText,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Visual style for one block type.
({IconData icon, Color bg, Color fg}) _blockStyle(SessionBlockDef block) {
  return switch (block.type) {
    'hold'
        when block.titleKey == 'strong_hold' ||
            block.exerciseId == 'strong_hold' =>
      (
        icon: Icons.fitness_center_rounded,
        bg: AppColors.goalEjaculationBg,
        fg: AppColors.goalEjaculationFg,
      ),
    'hold' => (
      icon: Icons.hourglass_bottom_rounded,
      bg: AppColors.mint,
      fg: AppColors.primary,
    ),
    'quick' => (
      icon: Icons.bolt_rounded,
      bg: AppColors.goalBladderBg,
      fg: AppColors.goalBladderFg,
    ),
    'rest' => (
      icon: Icons.pause_rounded,
      bg: AppColors.surfaceMuted,
      fg: AppColors.textSecondary,
    ),
    'breathing' => (
      icon: Icons.air_rounded,
      bg: AppColors.goalSurgeryBg,
      fg: AppColors.goalSurgeryFg,
    ),
    'reverse_kegel' => (
      icon: Icons.south_rounded,
      bg: AppColors.goalSurgeryBg,
      fg: AppColors.goalSurgeryFg,
    ),
    'stretch' => (
      icon: Icons.self_improvement_rounded,
      bg: AppColors.goalGeneralBg,
      fg: AppColors.goalGeneralFg,
    ),
    _ => (
      icon: Icons.accessibility_new_rounded,
      bg: AppColors.goalBladderBg,
      fg: AppColors.goalBladderFg,
    ),
  };
}

/// One numbered step in the session, joined to the next by a line.
class _BlockStep extends StatelessWidget {
  const _BlockStep({
    required this.index,
    required this.isLast,
    required this.block,
    required this.title,
    required this.subtitle,
    this.info,
  });

  final int index;
  final bool isLast;
  final SessionBlockDef block;
  final String title;
  final String subtitle;
  final InfoContent? info;

  @override
  Widget build(BuildContext context) {
    final ({IconData icon, Color bg, Color fg}) style = _blockStyle(block);
    final bool hasReps = block.reps != null && block.reps! > 1;
    // Exercises with a demo video open their instruction screen.
    final String exerciseId = ExerciseMedia.idForBlock(
      block.exerciseId ?? block.titleKey,
    );
    final String? poster = block.isRest
        ? null
        : ExerciseMedia.poster(exerciseId);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.md),
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.ink,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${index + 1}',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textOnPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      color: AppColors.border,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: PressScale(
                onTap: poster == null
                    ? null
                    : () => context.push(
                        '${AppRoutes.exercise}?id=${Uri.encodeComponent(exerciseId)}',
                      ),
                semanticLabel: title,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: block.isRest
                        ? AppColors.surfaceMuted
                        : AppColors.surface,
                    borderRadius: AppRadii.lgAll,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      if (poster != null)
                        _VideoThumb(poster: poster)
                      else
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: style.bg,
                            borderRadius: AppRadii.mdAll,
                          ),
                          child: Icon(style.icon, color: style.fg, size: 22),
                        ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: AppTypography.body.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(subtitle, style: AppTypography.caption),
                          ],
                        ),
                      ),
                      if (info != null) InfoButton(content: info!, size: 24),
                      if (hasReps) ...[
                        const SizedBox(width: AppSpacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: style.bg,
                            borderRadius: AppRadii.pillAll,
                          ),
                          child: Text(
                            '×${block.reps}',
                            style: AppTypography.caption.copyWith(
                              color: style.fg,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RemindersCard extends StatelessWidget {
  const _RemindersCard({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final List<String> tips = <String>[
      l10n.s3CueBreathing,
      l10n.s3CueRelaxed,
      l10n.s3CueGentle,
    ];
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.mint,
        borderRadius: AppRadii.lgAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.tips_and_updates_outlined,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                l10n.s1RemindersTitle,
                style: AppTypography.body.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          for (final String tip in tips)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xxs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(child: Text(tip, style: AppTypography.body)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CuesCard extends StatelessWidget {
  const _CuesCard({
    required this.l10n,
    required this.vibrationOn,
    required this.voiceOn,
    required this.onToggleVibration,
    required this.onToggleVoice,
  });

  final AppLocalizations l10n;
  final bool vibrationOn;
  final bool voiceOn;
  final ValueChanged<bool> onToggleVibration;
  final ValueChanged<bool> onToggleVoice;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _ToggleRow(
            icon: Icons.vibration_rounded,
            title: l10n.s1VibrationCues,
            value: vibrationOn,
            onChanged: onToggleVibration,
          ),
          const Divider(height: 1, color: AppColors.border, indent: 64),
          _ToggleRow(
            icon: Icons.record_voice_over_outlined,
            title: l10n.s1VoiceCues,
            subtitle: l10n.s1VoicePrivacy,
            value: voiceOn,
            onChanged: onToggleVoice,
          ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: AppMotion.quick,
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: value ? AppColors.mint : AppColors.surfaceMuted,
              borderRadius: AppRadii.mdAll,
            ),
            child: Icon(
              icon,
              size: 20,
              color: value ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle != null)
                  Text(subtitle!, style: AppTypography.caption),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.primary,
            activeThumbColor: AppColors.textOnPrimary,
          ),
        ],
      ),
    );
  }
}

/// "What you'll do": a card per Kegel exercise with the live side-view
/// animation running at that exercise's own timing, its name and rounds.
class _ExerciseContent extends StatelessWidget {
  const _ExerciseContent({
    required this.l10n,
    required this.blocks,
    required this.titleOf,
  });

  final AppLocalizations l10n;
  final List<SessionBlockDef> blocks;
  final String Function(SessionBlockDef block) titleOf;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints box) {
        final double card = blocks.length == 1
            ? math.min(box.maxWidth, 260)
            : (box.maxWidth - AppSpacing.sm) / 2;
        return Row(
          mainAxisAlignment: blocks.length == 1
              ? MainAxisAlignment.center
              : MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final SessionBlockDef b in blocks.take(2))
              SizedBox(
                width: card,
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadii.xlAll,
                    boxShadow: AppElevation.level1,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SidePelvicDemoLoop(
                        size: card,
                        squeeze: Duration(
                          milliseconds: (b.squeezeSec!.clamp(1, 10) * 1000)
                              .toInt(),
                        ),
                        relax: Duration(
                          milliseconds: (b.relaxSec!.clamp(1, 10) * 1000)
                              .toInt(),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.sm,
                          AppSpacing.sm,
                          AppSpacing.sm,
                          AppSpacing.sm,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              titleOf(b),
                              style: AppTypography.body.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              l10n.s1ContentTiming(b.squeezeSec!, b.relaxSec!),
                              style: AppTypography.caption,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.repeat_rounded,
                                  size: 15,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  l10n.s1ContentRounds(b.reps ?? 1),
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Small video thumbnail with a play badge (the exercise has a demo).
class _VideoThumb extends StatelessWidget {
  const _VideoThumb({required this.poster});

  final String poster;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadii.mdAll,
      child: SizedBox(
        width: 64,
        height: 48,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(poster, fit: BoxFit.cover, excludeFromSemantics: true),
            const ColoredBox(color: Color(0x2617151F)),
            Center(
              child: Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  size: 16,
                  color: AppColors.ink,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
