import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/l10n/app_localizations.dart';
import '../../app/router.dart';
import '../../app/theme/system_ui.dart';
import '../../app/theme/tokens.dart';
import '../../core/domain/enums.dart';
import '../../core/motion/app_motion.dart';
import '../../core/widgets/illustration.dart';
import '../../core/widgets/primary_button.dart';
import '../home/home_copy.dart';
import '../home/level_unlock_actions.dart';
import '../home/level_unlock_card.dart';
import '../home/today_celebration.dart';
import 'session_controller.dart';

/// S4 Session complete — celebration, stats, feel check, optional unlock.
///
/// The check draws inside a burst, stat tiles slide in from both sides and
/// count up, and the feel check uses three large tiles. Returning to Today
/// hands the finished item to [todayCelebrationProvider] so the journey
/// animates the step.
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
  bool _showUnlock = false;
  int? _nextLevel;
  SessionNext? _destination;

  @override
  void initState() {
    super.initState();
    unawaited(HapticFeedback.mediumImpact());
  }

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
      _showUnlock = result.levelUnlockReady && result.nextLevel != null;
      _nextLevel = result.nextLevel;
    });
    if (_suggestStepDown || _showUnlock) {
      return;
    }
    await _leave();
  }

  Future<void> _leave() async {
    final SessionNext dest = _destination ?? SessionNext.goToday;
    final String? finishedId =
        ref.read(sessionControllerProvider)?.itemId ?? widget.itemId;
    if (finishedId != null && dest != SessionNext.goPainHelp) {
      ref.read(todayCelebrationProvider.notifier).mark(finishedId);
    }
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

  void _select(SessionFeel feel) {
    if (_saved) {
      return;
    }
    unawaited(HapticFeedback.selectionClick());
    setState(() => _feel = feel);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final SessionPlayState? play = ref.watch(sessionControllerProvider);
    final SessionCompleteSummary? summary = play?.summary;

    if (summary == null) {
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: AppSystemUi.darkScreen,
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

    final bool minutes = summary.durationSeconds >= 90;
    final int timeValue =
        minutes ? (summary.durationSeconds / 60).ceil() : summary.durationSeconds;
    final int? nextLevel = _nextLevel;
    final String subtitle = _subtitle(l10n, play!);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppSystemUi.darkScreen,
      child: Scaffold(
        backgroundColor: AppColors.sessionBackground,
        body: Stack(
          children: [
            // Soft accent glow behind the hero.
            Positioned(
              top: -120,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 420,
                  height: 420,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: <Color>[
                        AppColors.accent.withValues(alpha: 0.22),
                        AppColors.accent.withValues(alpha: 0),
                      ],
                    ),
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
                        AppSpacing.xl,
                        AppSpacing.lg,
                        AppSpacing.xl,
                        AppSpacing.md,
                      ),
                      children: [
                        const _Hero(),
                        const SizedBox(height: AppSpacing.md),
                        Reveal(
                          from: RevealFrom.drop,
                          delay: const Duration(milliseconds: 250),
                          child: Column(
                            children: [
                              Text(
                                l10n.s4Title,
                                textAlign: TextAlign.center,
                                style: AppTypography.display.copyWith(
                                  color: AppColors.sessionText,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xxs),
                              Text(
                                subtitle,
                                textAlign: TextAlign.center,
                                style: AppTypography.body.copyWith(
                                  color: AppColors.sessionTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Row(
                          children: [
                            Expanded(
                              child: Reveal(
                                from: RevealFrom.left,
                                delay: const Duration(milliseconds: 380),
                                child: _StatTile(
                                  icon: Icons.timer_outlined,
                                  label: l10n.s4TimeLabel,
                                  value: CountUpText(
                                    value: timeValue,
                                    delay: const Duration(milliseconds: 500),
                                    format: minutes
                                        ? l10n.s4TimeMinutes
                                        : l10n.s4TimeSeconds,
                                    style: _statStyle,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Reveal(
                                from: RevealFrom.right,
                                delay: const Duration(milliseconds: 440),
                                child: _StatTile(
                                  iconWidget: FloatBob(
                                    lift: 2,
                                    period: const Duration(milliseconds: 1400),
                                    child: Illustration(
                                      assetPath: 'assets/images/flame.svg',
                                      semanticLabel: l10n.s4StreakLabel,
                                      width: 18,
                                      height: 18,
                                      color: AppColors.streakFg,
                                    ),
                                  ),
                                  iconBackground: AppColors.streakBg,
                                  label: l10n.s4StreakLabel,
                                  value: CountUpText(
                                    value: summary.streak,
                                    delay: const Duration(milliseconds: 560),
                                    format: l10n.s4StreakDays,
                                    style: _statStyle,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Reveal(
                          from: RevealFrom.rise,
                          delay: const Duration(milliseconds: 520),
                          child: _NextTile(
                            label: l10n.s4NextLabel,
                            value: summary.nextItem == null
                                ? l10n.s4NextNone
                                : HomeCopy.itemTitle(l10n, summary.nextItem!),
                            hasNext: summary.nextItem != null,
                          ),
                        ),
                        if (_showUnlock && nextLevel != null) ...[
                          const SizedBox(height: AppSpacing.lg),
                          Reveal(
                            from: RevealFrom.drop,
                            child: LevelUnlockCard(
                              l10n: l10n,
                              nextLevel: nextLevel,
                              dark: true,
                              onStart: () async {
                                final bool advanced =
                                    await LevelUnlockActions.startNext(
                                  context: context,
                                  ref: ref,
                                  nextLevel: nextLevel,
                                );
                                if (!context.mounted) {
                                  return;
                                }
                                if (advanced) {
                                  setState(() => _showUnlock = false);
                                  LevelUnlockActions.showStartedConfirm(
                                    context,
                                    l10n,
                                    nextLevel,
                                  );
                                }
                              },
                              onStay: () async {
                                await LevelUnlockActions.snooze(ref);
                                if (!context.mounted) {
                                  return;
                                }
                                setState(() => _showUnlock = false);
                              },
                            ),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.xl),
                        Reveal(
                          from: RevealFrom.left,
                          delay: const Duration(milliseconds: 620),
                          child: Text(
                            l10n.s4FeelPrompt,
                            style: AppTypography.title.copyWith(
                              color: AppColors.sessionText,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (final (int i, _FeelOption option)
                                in _options(l10n).indexed) ...[
                              if (i > 0) const SizedBox(width: AppSpacing.xs),
                              Expanded(
                                child: Reveal(
                                  from: RevealFrom.rise,
                                  delay: AppMotion.stagger(
                                    i,
                                    base: const Duration(milliseconds: 680),
                                  ),
                                  child: _FeelTile(
                                    option: option,
                                    selected: _feel == option.feel,
                                    dimmed: _feel != null && _feel != option.feel,
                                    onTap: () => _select(option.feel),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        AnimatedSize(
                          duration: AppMotion.quick,
                          child: _suggestStepDown
                              ? Padding(
                                  padding:
                                      const EdgeInsets.only(top: AppSpacing.md),
                                  child: _Note(text: l10n.s4StepDownSuggestion),
                                )
                              : const SizedBox(width: double.infinity),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      AppSpacing.xs,
                      AppSpacing.xl,
                      AppSpacing.md,
                    ),
                    child: PrimaryButton(
                      label: l10n.commonContinue,
                      color: AppColors.accent,
                      foregroundColor: AppColors.ink,
                      trailingArrow: _feel != null,
                      shimmer: _feel != null,
                      onPressed: (_feel == null || _saving)
                          ? null
                          : () {
                              if (_saved) {
                                unawaited(_leave());
                              } else {
                                unawaited(_onContinue());
                              }
                            },
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

  static final TextStyle _statStyle = AppTypography.title.copyWith(
    color: AppColors.sessionText,
    fontWeight: FontWeight.w800,
  );

  String _subtitle(AppLocalizations l10n, SessionPlayState play) {
    final int? number = play.definition.sessionNumber;
    if (play.definition.kind == SessionKind.strengthening && number != null) {
      return l10n.s4SubtitleSession(number, play.dayInLevel);
    }
    return l10n.s4SubtitleGeneric;
  }

  List<_FeelOption> _options(AppLocalizations l10n) => <_FeelOption>[
        _FeelOption(
          feel: SessionFeel.fine,
          label: l10n.s4FeelFine,
          icon: Icons.sentiment_satisfied_alt_rounded,
          color: AppColors.accent,
        ),
        _FeelOption(
          feel: SessionFeel.mildDiscomfort,
          label: l10n.s4FeelMild,
          icon: Icons.sentiment_neutral_rounded,
          color: AppColors.goalEjaculationBg,
        ),
        _FeelOption(
          feel: SessionFeel.pain,
          label: l10n.s4FeelPain,
          icon: Icons.healing_outlined,
          color: AppColors.goalGeneralBg,
        ),
      ];
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const CompletionBurst(
            size: 170,
            color: AppColors.accent,
            delay: Duration(milliseconds: 380),
          ),
          FloatBob(
            lift: 4,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.4),
                    blurRadius: 36,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const AnimatedCheckBadge(
                size: 92,
                color: AppColors.accent,
                checkColor: AppColors.ink,
                delay: Duration(milliseconds: 120),
                strokeWidth: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    this.icon,
    this.iconWidget,
    this.iconBackground,
  });

  final String label;
  final Widget value;
  final IconData? icon;
  final Widget? iconWidget;
  final Color? iconBackground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.sessionSurface,
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: AppColors.sessionRingTrack),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconBackground ?? AppColors.accent.withValues(alpha: 0.16),
              borderRadius: AppRadii.mdAll,
            ),
            alignment: Alignment.center,
            child: iconWidget ??
                Icon(icon, size: 18, color: AppColors.accent),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.sessionTextSecondary,
            ),
          ),
          const SizedBox(height: 2),
          value,
        ],
      ),
    );
  }
}

class _NextTile extends StatelessWidget {
  const _NextTile({
    required this.label,
    required this.value,
    required this.hasNext,
  });

  final String label;
  final String value;
  final bool hasNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.sessionSurface,
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: AppColors.sessionRingTrack),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.16),
              borderRadius: AppRadii.mdAll,
            ),
            child: Icon(
              hasNext ? Icons.route_rounded : Icons.bedtime_outlined,
              size: 18,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.sessionTextSecondary,
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
          ),
          if (hasNext)
            const NudgeArrow(color: AppColors.sessionTextSecondary),
        ],
      ),
    );
  }
}

class _FeelOption {
  const _FeelOption({
    required this.feel,
    required this.label,
    required this.icon,
    required this.color,
  });

  final SessionFeel feel;
  final String label;
  final IconData icon;

  /// Fill used when the tile is selected.
  final Color color;
}

class _FeelTile extends StatelessWidget {
  const _FeelTile({
    required this.option,
    required this.selected,
    required this.dimmed,
    required this.onTap,
  });

  final _FeelOption option;
  final bool selected;
  final bool dimmed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color fg = selected ? AppColors.ink : AppColors.sessionText;
    return Semantics(
      selected: selected,
      child: PressScale(
        onTap: onTap,
        semanticLabel: option.label,
        child: AnimatedScale(
          scale: selected ? 1.04 : 1,
          duration: const Duration(milliseconds: 240),
          curve: AppMotion.dropCurve,
          child: AnimatedOpacity(
            duration: AppMotion.quick,
            opacity: dimmed ? 0.55 : 1,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              constraints: const BoxConstraints(minHeight: 108),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: selected ? option.color : AppColors.sessionSurface,
                borderRadius: AppRadii.lgAll,
                border: Border.all(
                  color: selected ? option.color : AppColors.sessionRingTrack,
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(option.icon, size: 30, color: fg),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    option.label,
                    textAlign: TextAlign.center,
                    style: AppTypography.caption.copyWith(
                      color: fg,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.12),
        borderRadius: AppRadii.mdAll,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.accent, size: 20),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              text,
              style: AppTypography.body.copyWith(color: AppColors.sessionText),
            ),
          ),
        ],
      ),
    );
  }
}
