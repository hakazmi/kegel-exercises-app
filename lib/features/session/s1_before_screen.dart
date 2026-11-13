import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/l10n/app_localizations.dart';
import '../../app/router.dart';
import '../../app/theme/system_ui.dart';
import '../../app/theme/tokens.dart';
import '../../core/content/content_models.dart';
import '../../core/data/providers.dart';
import '../../core/domain/enums.dart';
import '../../core/domain/user_profile.dart';
import '../../core/plan/plan_models.dart';
import '../../core/plan/session_definition.dart';
import '../../core/widgets/widgets.dart';

/// S1 Before you start — session overview for a plan item.
class S1BeforeScreen extends ConsumerWidget {
  const S1BeforeScreen({
    super.key,
    this.itemId,
  });

  /// Today-plan item id (e.g. strength_1, breathing, reverse_kegel).
  final String? itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final UserProfile profile = ref.watch(userProfileProvider);
    final AsyncValue<TodayPlan> planAsync = ref.watch(todayPlanProvider);
    final AsyncValue<List<LevelContent>> levelsAsync = ref.watch(levelsProvider);
    final AsyncValue<List<ExerciseContent>> exercisesAsync =
        ref.watch(exercisesProvider);

    if (planAsync.isLoading ||
        levelsAsync.isLoading ||
        exercisesAsync.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (planAsync.hasError ||
        levelsAsync.hasError ||
        exercisesAsync.hasError) {
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
    final SessionDefinition session = SessionDefinitionBuilder.fromLevelAndItem(
      level: level,
      item: item,
      sessionsToday: profile.sessionsPerDay.clamp(1, 3),
    );
    final Map<String, String> descriptions = <String, String>{
      for (final ExerciseContent e in exercises) e.id: e.description,
    };

    return _S1Body(
      l10n: l10n,
      profile: profile,
      plan: plan,
      session: session,
      item: item,
      strengtheningTotal: strengtheningTotal,
      descriptions: descriptions,
      onToggleVibration: (bool value) {
        ref.read(userProfileProvider.notifier).save(
              profile.copyWith(vibrationOn: value),
            );
      },
      onToggleVoice: (bool value) {
        ref.read(userProfileProvider.notifier).save(
              profile.copyWith(voiceOn: value),
            );
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
      label: 'Session 1',
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
    required this.descriptions,
    required this.onToggleVibration,
    required this.onToggleVoice,
  });

  final AppLocalizations l10n;
  final UserProfile profile;
  final TodayPlan plan;
  final SessionDefinition session;
  final TodayItem item;
  final int strengtheningTotal;
  final Map<String, String> descriptions;
  final ValueChanged<bool> onToggleVibration;
  final ValueChanged<bool> onToggleVoice;

  @override
  Widget build(BuildContext context) {
    final int number = item.sessionNumber ?? 1;
    final String title = item.kind == SessionKind.strengthening
        ? l10n.s1SessionOf(number, strengtheningTotal)
        : item.label;
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
            _DarkHeader(
              l10n: l10n,
              track: plan.track,
              level: plan.level,
              day: plan.dayInLevel,
              title: title,
              meta: meta,
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
                  AppSpacing.xl,
                  AppSpacing.lg,
                  AppSpacing.xl,
                  AppSpacing.md,
                ),
                children: [
                  for (int i = 0; i < session.blocks.length; i++) ...[
                    if (i > 0) const Divider(height: 1, color: AppColors.border),
                    _BlockRow(
                      l10n: l10n,
                      block: session.blocks[i],
                      description: _descriptionFor(session.blocks[i]),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  AppCard(
                    backgroundColor: AppColors.surfaceMuted,
                    borderColor: Colors.transparent,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.airline_seat_flat, size: 22),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            _positionCopy(l10n, session.position),
                            style: AppTypography.body
                                .copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _ToggleRow(
                    title: l10n.s1VibrationCues,
                    value: profile.vibrationOn,
                    onChanged: onToggleVibration,
                  ),
                  _ToggleRow(
                    title: l10n.s1VoiceCues,
                    subtitle: l10n.s1VoicePrivacy,
                    value: profile.voiceOn,
                    onChanged: onToggleVoice,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Center(
                    child: TextLinkButton(
                      label: l10n.s1ShowMeHow,
                      underline: true,
                      onPressed: () {
                        context.push('${AppRoutes.tutorial}?replay=1');
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.md,
                AppSpacing.xl,
                AppSpacing.md,
              ),
              child: PrimaryButton(
                label: l10n.s1Start,
                onPressed: () {
                  context.go(
                    '${AppRoutes.countdown}?itemId=${Uri.encodeComponent(session.id)}',
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _descriptionFor(SessionBlockDef block) {
    if (block.titleKey == 'reverseKegel') {
      return l10n.s1ReverseKegelDescription;
    }
    final String? exerciseId = switch (block.titleKey) {
      'slowHolds' => 'slow_hold',
      'quickSqueezes' => 'quick_squeeze',
      'breathing' => 'diaphragmatic_breathing',
      _ => null,
    };
    if (exerciseId == null) {
      return null;
    }
    return descriptions[exerciseId];
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

class _DarkHeader extends StatelessWidget {
  const _DarkHeader({
    required this.l10n,
    required this.track,
    required this.level,
    required this.day,
    required this.title,
    required this.meta,
    required this.onBack,
  });

  final AppLocalizations l10n;
  final TrackId track;
  final int level;
  final int day;
  final String title;
  final String meta;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final String eyebrow = track == TrackId.relaxationFirst
        ? l10n.s1RelaxationDay(day)
        : l10n.s1LevelDay(level, day);

    return ColoredBox(
      color: AppColors.sessionBackground,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.sm,
            AppSpacing.xs,
            AppSpacing.xl,
            AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back, color: AppColors.sessionText),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: AppSpacing.sm),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            eyebrow.toUpperCase(),
                            style: AppTypography.caption.copyWith(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
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
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            meta,
                            style: AppTypography.body.copyWith(
                              color: AppColors.sessionTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Illustration(
                    assetPath: 'assets/images/lying.svg',
                    semanticLabel: l10n.s1LyingSemantic,
                    width: 96,
                    height: 72,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BlockRow extends StatelessWidget {
  const _BlockRow({
    required this.l10n,
    required this.block,
    this.description,
  });

  final AppLocalizations l10n;
  final SessionBlockDef block;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: AppRadii.mdAll,
            ),
            alignment: Alignment.center,
            child: Illustration(
              assetPath: block.thumbnailAsset ?? 'assets/images/stopwatch.svg',
              semanticLabel: _title(),
              width: 28,
              height: 28,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _title(),
                  style: AppTypography.body.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  description ?? _detail(),
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _title() {
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
      default:
        return block.titleKey;
    }
  }

  String _detail() {
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
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.body.copyWith(fontWeight: FontWeight.w700),
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
