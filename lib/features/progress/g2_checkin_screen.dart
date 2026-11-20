import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/l10n/app_localizations.dart';
import '../../app/theme/tokens.dart';
import '../../core/data/providers.dart';
import '../../core/domain/enums.dart';
import '../../core/domain/session_record.dart';
import '../../core/domain/user_profile.dart';
import '../../core/motion/app_motion.dart';
import '../../core/plan/check_in_rules.dart';
import '../../core/plan/check_in_scoring.dart';
import '../../core/services/reminder_service.dart';
import '../../core/widgets/widgets.dart';
import 'check_in_copy.dart';

/// G2 Check-in — one goal question on a 1–5 scale; scores stay on device.
class G2CheckInScreen extends ConsumerStatefulWidget {
  const G2CheckInScreen({super.key});

  @override
  ConsumerState<G2CheckInScreen> createState() => _G2CheckInScreenState();
}

class _G2CheckInScreenState extends ConsumerState<G2CheckInScreen> {
  /// Selected option index (0 = top of list), not the stored score.
  int? _selectedOptionIndex;
  bool _saving = false;
  bool _showResult = false;
  List<CheckInRecord> _afterSave = const <CheckInRecord>[];

  Future<void> _save() async {
    final int? optionIndex = _selectedOptionIndex;
    if (optionIndex == null || _saving) {
      return;
    }
    setState(() => _saving = true);
    final UserProfile profile = ref.read(userProfileProvider);
    final Goal goal = profile.goal ?? Goal.generalPelvicHealth;
    final DateTime now = ref.read(appClockProvider).now();
    final int score =
        CheckInScoring.normalisedFromOptionIndex(goal, optionIndex);
    // Scores stay in Drift only — never call AnalyticsService here.
    await ref.read(checkInRepositoryProvider).insert(
          CheckInRecord(
            date: now,
            goal: goal,
            score: score,
          ),
        );
    ref.invalidate(checkInsProvider);
    await ref.read(reminderServiceProvider).reschedule();
    final List<CheckInRecord> all =
        await ref.read(checkInRepositoryProvider).getAll();
    if (!mounted) {
      return;
    }
    setState(() {
      _saving = false;
      _showResult = true;
      _afterSave = all;
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final UserProfile profile = ref.watch(userProfileProvider);
    final bool isPremium = ref.watch(isPremiumProvider);
    final DateTime today = ref.watch(appClockProvider).now();
    final Goal goal = profile.goal ?? Goal.generalPelvicHealth;
    final AsyncValue<List<CheckInRecord>> checkInsAsync =
        ref.watch(checkInsProvider);
    final List<CheckInRecord> existing =
        checkInsAsync.asData?.value ?? const <CheckInRecord>[];
    final bool isBaseline = existing.isEmpty && !_showResult;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: l10n.commonClose,
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: AppMotion.slide,
          switchInCurve: AppMotion.slideCurve,
          transitionBuilder: (Widget child, Animation<double> animation) =>
              FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.15, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: _showResult
              ? _ResultBody(
                  key: const ValueKey<String>('result'),
                  l10n: l10n,
                  checkIns: _afterSave,
                  isPremium: isPremium,
                  today: today,
                  onDone: () => context.pop(),
                )
              : _QuestionBody(
                  key: const ValueKey<String>('question'),
                  l10n: l10n,
                  goal: goal,
                  isBaseline: isBaseline,
                  selectedOptionIndex: _selectedOptionIndex,
                  saving: _saving,
                  onSelect: (int index) {
                    unawaited(HapticFeedback.selectionClick());
                    setState(() => _selectedOptionIndex = index);
                  },
                  onSave: _save,
                  onSkip: () => context.pop(),
                ),
        ),
      ),
    );
  }
}

class _QuestionBody extends StatelessWidget {
  const _QuestionBody({
    super.key,
    required this.l10n,
    required this.goal,
    required this.isBaseline,
    required this.selectedOptionIndex,
    required this.saving,
    required this.onSelect,
    required this.onSave,
    required this.onSkip,
  });

  final AppLocalizations l10n;
  final Goal goal;
  final bool isBaseline;
  final int? selectedOptionIndex;
  final bool saving;
  final ValueChanged<int> onSelect;
  final VoidCallback onSave;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final List<String> options = CheckInCopy.options(l10n, goal);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Reveal(
            from: RevealFrom.drop,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.mint,
                  borderRadius: AppRadii.pillAll,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.insights_rounded,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppSpacing.xxs),
                    Text(
                      isBaseline
                          ? l10n.g2EyebrowBaseline
                          : l10n.g2EyebrowFollowUp,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Reveal(
            from: RevealFrom.left,
            delay: const Duration(milliseconds: 80),
            child: Text(
              CheckInCopy.question(l10n, goal),
              style: AppTypography.display,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Reveal(
            from: RevealFrom.left,
            delay: const Duration(milliseconds: 140),
            child: Text(
              isBaseline ? l10n.g2SubtitleBaseline : l10n.g2SubtitleFollowUp,
              style: AppTypography.body.copyWith(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: ListView.separated(
              itemCount: options.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(height: AppSpacing.xs),
              itemBuilder: (BuildContext context, int index) {
                return Reveal(
                  from: RevealFrom.right,
                  delay: AppMotion.stagger(
                    index,
                    base: const Duration(milliseconds: 180),
                  ),
                  child: _ScaleOption(
                    label: options[index],
                    score: CheckInScoring.normalisedFromOptionIndex(goal, index),
                    selected: selectedOptionIndex == index,
                    onTap: () => onSelect(index),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const Icon(
                Icons.lock_outline,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.xxs),
              Expanded(
                child: Text(l10n.g2PrivacyNote, style: AppTypography.caption),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          PrimaryButton(
            label: l10n.g2Save,
            icon: Icons.check_rounded,
            shimmer: selectedOptionIndex != null,
            enabled: selectedOptionIndex != null && !saving,
            onPressed:
                selectedOptionIndex != null && !saving ? onSave : null,
          ),
          const SizedBox(height: AppSpacing.xxs),
          Center(
            child: TextLinkButton(
              label: l10n.g2Skip,
              color: AppColors.textSecondary,
              onPressed: onSkip,
            ),
          ),
        ],
      ),
    );
  }
}

/// One answer on the 1–5 scale, with a five-segment meter for its score.
class _ScaleOption extends StatelessWidget {
  const _ScaleOption({
    required this.label,
    required this.score,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int score;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      child: PressScale(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 2,
          ),
          decoration: BoxDecoration(
            color: selected ? AppColors.mint : AppColors.surface,
            borderRadius: AppRadii.lgAll,
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 2 : 1,
            ),
            boxShadow: selected ? AppElevation.level1 : AppElevation.none,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTypography.body.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Row(
                      children: [
                        for (int i = 1; i <= CheckInScoring.maxScore; i++) ...[
                          if (i > 1) const SizedBox(width: 3),
                          AnimatedContainer(
                            duration: Duration(milliseconds: 160 + i * 40),
                            width: 18,
                            height: 5,
                            decoration: BoxDecoration(
                              color: i <= score
                                  ? (selected
                                      ? AppColors.primary
                                      : AppColors.textDisabled)
                                  : AppColors.surfaceMuted,
                              borderRadius: AppRadii.pillAll,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (Widget child, Animation<double> a) =>
                    ScaleTransition(scale: a, child: child),
                child: selected
                    ? const AnimatedCheckBadge(
                        key: ValueKey<String>('on'),
                        size: 26,
                        color: AppColors.primary,
                        checkColor: AppColors.textOnPrimary,
                        strokeWidth: 2.6,
                      )
                    : Container(
                        key: const ValueKey<String>('off'),
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.border,
                            width: 1.5,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultBody extends StatelessWidget {
  const _ResultBody({
    super.key,
    required this.l10n,
    required this.checkIns,
    required this.isPremium,
    required this.today,
    required this.onDone,
  });

  final AppLocalizations l10n;
  final List<CheckInRecord> checkIns;
  final bool isPremium;
  final DateTime today;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final List<CheckInRecord> visible = CheckInRules.visibleHistory(
      checkIns: checkIns,
      isPremium: isPremium,
    );
    final List<CheckInRecord> sorted = CheckInRules.sorted(checkIns);
    final CheckInRecord baseline = sorted.first;
    final CheckInRecord latest = sorted.last;
    final bool showDoctor = CheckInRules.shouldSuggestDoctor(
      checkIns: checkIns,
      today: today,
    );

    // Free users with history see only the newest answer (spec section 10).
    final List<CheckInRecord> rows = (!isPremium && checkIns.length > 1)
        ? <CheckInRecord>[latest]
        : visible;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CompletionBurst(size: 130, color: AppColors.accent),
                AnimatedCheckBadge(
                  size: 72,
                  color: AppColors.primary,
                  checkColor: AppColors.textOnPrimary,
                  strokeWidth: 6,
                ),
              ],
            ),
          ),
          Reveal(
            from: RevealFrom.drop,
            delay: const Duration(milliseconds: 200),
            child: Text(
              l10n.g2ResultTitle,
              textAlign: TextAlign.center,
              style: AppTypography.display,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Reveal(
            from: RevealFrom.drop,
            delay: const Duration(milliseconds: 260),
            child: Text(
              l10n.g2ResultSubtitle,
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Reveal(
            from: RevealFrom.left,
            delay: const Duration(milliseconds: 340),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadii.lgAll,
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (int i = 0; i < rows.length; i++) ...[
                    if (i > 0) const SizedBox(height: AppSpacing.sm),
                    _ScoreRow(
                      line: CheckInCopy.comparisonLine(
                        l10n,
                        week: CheckInRules.weekIndex(
                          baselineDate: baseline.date,
                          at: rows[i].date,
                        ),
                        score: rows[i].score,
                        goal: rows[i].goal,
                      ),
                      score: rows[i].score,
                      highlight: i == rows.length - 1,
                      delay: AppMotion.stagger(
                        i,
                        base: const Duration(milliseconds: 500),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (showDoctor) ...[
            const SizedBox(height: AppSpacing.md),
            Reveal(
              from: RevealFrom.right,
              delay: const Duration(milliseconds: 420),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: const BoxDecoration(
                  color: AppColors.goalSurgeryBg,
                  borderRadius: AppRadii.lgAll,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.medical_services_outlined,
                      color: AppColors.goalSurgeryFg,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(l10n.g2DoctorNote, style: AppTypography.body),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (!isPremium && checkIns.length > 1) ...[
            const SizedBox(height: AppSpacing.md),
            Text(l10n.g2HistoryPremiumHint, style: AppTypography.caption),
          ],
          const Spacer(),
          PrimaryButton(label: l10n.g2Done, onPressed: onDone),
        ],
      ),
    );
  }
}

/// "Week n: x of 5 · label" with a filling bar under it.
class _ScoreRow extends StatelessWidget {
  const _ScoreRow({
    required this.line,
    required this.score,
    required this.highlight,
    required this.delay,
  });

  final String line;
  final int score;
  final bool highlight;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          line,
          style: AppTypography.body.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacing.xxs),
        ClipRRect(
          borderRadius: AppRadii.pillAll,
          child: SizedBox(
            height: 8,
            child: ColoredBox(
              color: AppColors.surfaceMuted,
              child: AnimatedFraction(
                value: score / CheckInScoring.maxScore,
                delay: delay,
                builder: (BuildContext context, double v) => Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: v,
                    heightFactor: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: highlight
                              ? const <Color>[AppColors.primary, AppColors.accent]
                              : const <Color>[
                                  AppColors.textDisabled,
                                  AppColors.border,
                                ],
                        ),
                        borderRadius: AppRadii.pillAll,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
