import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/l10n/app_localizations.dart';
import '../../app/theme/tokens.dart';
import '../../core/data/providers.dart';
import '../../core/domain/enums.dart';
import '../../core/domain/session_record.dart';
import '../../core/domain/user_profile.dart';
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
        child: _showResult
            ? _ResultBody(
                l10n: l10n,
                checkIns: _afterSave,
                isPremium: isPremium,
                today: today,
                onDone: () => context.pop(),
              )
            : _QuestionBody(
                l10n: l10n,
                goal: goal,
                isBaseline: isBaseline,
                selectedOptionIndex: _selectedOptionIndex,
                saving: _saving,
                onSelect: (int index) =>
                    setState(() => _selectedOptionIndex = index),
                onSave: _save,
                onSkip: () => context.pop(),
              ),
      ),
    );
  }
}

class _QuestionBody extends StatelessWidget {
  const _QuestionBody({
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
        AppSpacing.xl,
        0,
        AppSpacing.xl,
        AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isBaseline ? l10n.g2EyebrowBaseline : l10n.g2EyebrowFollowUp,
            style: AppTypography.caption.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            CheckInCopy.question(l10n, goal),
            style: AppTypography.display,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            isBaseline ? l10n.g2SubtitleBaseline : l10n.g2SubtitleFollowUp,
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: ListView.separated(
              itemCount: options.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (BuildContext context, int index) {
                return SelectableCard(
                  title: options[index],
                  selected: selectedOptionIndex == index,
                  onTap: () => onSelect(index),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              const Icon(
                Icons.lock_outline,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.xxs),
              Expanded(
                child: Text(
                  l10n.g2PrivacyNote,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          PrimaryButton(
            label: l10n.g2Save,
            enabled: selectedOptionIndex != null && !saving,
            onPressed:
                selectedOptionIndex != null && !saving ? onSave : null,
          ),
          const SizedBox(height: AppSpacing.xs),
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

class _ResultBody extends StatelessWidget {
  const _ResultBody({
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
    final CheckInRecord baseline = CheckInRules.sorted(checkIns).first;
    final CheckInRecord latest = CheckInRules.sorted(checkIns).last;
    final bool showDoctor = CheckInRules.shouldSuggestDoctor(
      checkIns: checkIns,
      today: today,
    );

    final List<String> lines = <String>[];
    if (!isPremium && checkIns.length > 1) {
      lines.add(
        CheckInCopy.comparisonLine(
          l10n,
          week: CheckInRules.weekIndex(
            baselineDate: baseline.date,
            at: latest.date,
          ),
          score: latest.score,
          goal: latest.goal,
        ),
      );
    } else {
      for (final CheckInRecord row in visible) {
        lines.add(
          CheckInCopy.comparisonLine(
            l10n,
            week: CheckInRules.weekIndex(
              baselineDate: baseline.date,
              at: row.date,
            ),
            score: row.score,
            goal: row.goal,
          ),
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        0,
        AppSpacing.xl,
        AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.g2ResultTitle, style: AppTypography.display),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.g2ResultSubtitle,
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < lines.length; i++) ...[
                  if (i > 0) const SizedBox(height: AppSpacing.sm),
                  Text(
                    lines[i],
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (showDoctor) ...[
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              backgroundColor: AppColors.surfaceMuted,
              child: Text(
                l10n.g2DoctorNote,
                style: AppTypography.body,
              ),
            ),
          ],
          if (!isPremium && checkIns.length > 1) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.g2HistoryPremiumHint,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const Spacer(),
          PrimaryButton(label: l10n.g2Done, onPressed: onDone),
        ],
      ),
    );
  }
}
