import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/l10n/app_localizations.dart';
import '../../app/router.dart';
import '../../app/theme/tokens.dart';
import '../../core/domain/enums.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/selectable_card.dart';
import 'session_controller.dart';

/// S4 Session complete — time, streak, next, feel check.
class S4DoneScreen extends ConsumerStatefulWidget {
  const S4DoneScreen({
    super.key,
    this.itemId,
  });

  final String? itemId;

  @override
  ConsumerState<S4DoneScreen> createState() => _S4DoneScreenState();
}

class _S4DoneScreenState extends ConsumerState<S4DoneScreen> {
  SessionFeel? _feel;
  bool _saving = false;
  bool _saved = false;
  bool _suggestStepDown = false;
  SessionNext? _destination;

  Future<void> _onContinue() async {
    if (_saving) {
      return;
    }
    if (_saved) {
      await _leave();
      return;
    }
    final SessionFeel? feel = _feel;
    if (feel == null) {
      return;
    }
    setState(() => _saving = true);
    final SessionSaveResult result =
        await ref.read(sessionControllerProvider.notifier).saveWithFeel(feel);
    if (!mounted) {
      return;
    }
    setState(() {
      _saving = false;
      _saved = true;
      _destination = result.goTo;
      _suggestStepDown =
          result.suggestStepDown && feel == SessionFeel.mildDiscomfort;
    });
    if (_suggestStepDown) {
      return;
    }
    await _leave();
  }

  Future<void> _leave() async {
    final SessionNext dest = _destination ?? SessionNext.goToday;
    await ref.read(sessionControllerProvider.notifier).clear();
    if (!mounted) {
      return;
    }
    switch (dest) {
      case SessionNext.goPainHelp:
        context.go('${AppRoutes.painHelp}?fromSession=1');
      case SessionNext.goPaywall:
        context.go(AppRoutes.paywall);
      case SessionNext.goToday:
        context.go(AppRoutes.today);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final SessionPlayState? play = ref.watch(sessionControllerProvider);
    final SessionCompleteSummary? summary = play?.summary;

    if (summary == null) {
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
        ),
        child: Scaffold(
          backgroundColor: AppColors.sessionBackground,
          body: Center(
            child: Text(
              l10n.s4Title,
              style: AppTypography.title.copyWith(color: AppColors.sessionText),
            ),
          ),
        ),
      );
    }

    final String timeLabel = summary.durationSeconds >= 90
        ? l10n.s4TimeMinutes((summary.durationSeconds / 60).ceil())
        : l10n.s4TimeSeconds(summary.durationSeconds);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemStatusBarContrastEnforced: false,
      ),
      child: Scaffold(
        backgroundColor: AppColors.sessionBackground,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.s4Title,
                  style: AppTypography.display.copyWith(
                    color: AppColors.sessionText,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _StatRow(label: l10n.s4TimeLabel, value: timeLabel),
                _StatRow(
                  label: l10n.s4StreakLabel,
                  value: l10n.s4StreakDays(summary.streak),
                ),
                _StatRow(
                  label: l10n.s4NextLabel,
                  value: summary.nextLabel ?? l10n.s4NextNone,
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  l10n.s4FeelPrompt,
                  style: AppTypography.title.copyWith(
                    color: AppColors.sessionText,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                SelectableCard(
                  title: l10n.s4FeelFine,
                  selected: _feel == SessionFeel.fine,
                  onTap: () {
                    if (!_saved) {
                      setState(() => _feel = SessionFeel.fine);
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.xs),
                SelectableCard(
                  title: l10n.s4FeelMild,
                  selected: _feel == SessionFeel.mildDiscomfort,
                  onTap: () {
                    if (!_saved) {
                      setState(() => _feel = SessionFeel.mildDiscomfort);
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.xs),
                SelectableCard(
                  title: l10n.s4FeelPain,
                  selected: _feel == SessionFeel.pain,
                  onTap: () {
                    if (!_saved) {
                      setState(() => _feel = SessionFeel.pain);
                    }
                  },
                ),
                if (_suggestStepDown) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    l10n.s4StepDownSuggestion,
                    style: AppTypography.body.copyWith(
                      color: AppColors.accent,
                    ),
                  ),
                ],
                const Spacer(),
                PrimaryButton(
                  label: l10n.commonContinue,
                  onPressed: (_feel == null || _saving) ? null : _onContinue,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTypography.body.copyWith(
                color: AppColors.sessionTextSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: AppTypography.body.copyWith(
              color: AppColors.sessionText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
