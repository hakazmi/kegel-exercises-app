import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/l10n/app_localizations.dart';
import '../../app/router.dart';
import '../../app/theme/tokens.dart';
import '../../core/data/providers.dart';
import '../../core/domain/user_profile.dart';
import '../../core/services/analytics_service.dart';
import '../../core/widgets/widgets.dart';
import 'anatomy_diagram.dart';

/// T1 muscle-finding tutorial: 3 cards, practice, then felt-lift check.
class T1TutorialScreen extends ConsumerStatefulWidget {
  const T1TutorialScreen({
    super.key,
    this.replay = false,
    this.nextPath,
  });

  /// When true, finishing does not write [UserProfile.tutorialDone].
  final bool replay;

  /// Optional path after finish (defaults to S1 before).
  final String? nextPath;

  @override
  ConsumerState<T1TutorialScreen> createState() => _T1TutorialScreenState();
}

enum _T1Step { cards, practice, feltLift, notSure }

class _T1TutorialScreenState extends ConsumerState<T1TutorialScreen> {
  static const int _cardCount = 3;
  static const int _practiceReps = 3;
  static const Duration _phaseDuration = Duration(seconds: 3);

  int _cardIndex = 0;
  _T1Step _step = _T1Step.cards;
  int _rep = 1;
  bool _isSqueeze = true;
  int _practiceKey = 0;

  Future<void> _finish({required bool feltLift}) async {
    final AnalyticsService analytics = ref.read(analyticsServiceProvider);
    await analytics.logEvent(
      'tutorial_done',
      parameters: <String, Object?>{
        'felt_lift': feltLift ? 'yes' : 'not_sure',
      },
    );

    if (!widget.replay) {
      final UserProfile profile = ref.read(userProfileProvider);
      await ref.read(userProfileProvider.notifier).save(
            profile.copyWith(tutorialDone: true),
          );
    }

    if (!mounted) {
      return;
    }

    if (widget.replay && context.canPop()) {
      context.pop();
      return;
    }

    final String next = widget.nextPath ??
        '${AppRoutes.before}?itemId=strength_1';
    context.go(next);
  }

  void _onPracticePhaseDone() {
    if (!mounted) {
      return;
    }
    if (_isSqueeze) {
      setState(() => _isSqueeze = false);
      return;
    }
    if (_rep >= _practiceReps) {
      setState(() => _step = _T1Step.feltLift);
      return;
    }
    setState(() {
      _rep += 1;
      _isSqueeze = true;
    });
  }

  void _pulseIfEnabled() {
    if (ref.read(userProfileProvider).vibrationOn) {
      HapticFeedback.mediumImpact();
    }
  }

  void _startPractice({bool reset = false}) {
    setState(() {
      _step = _T1Step.practice;
      if (reset) {
        _rep = 1;
        _isSqueeze = true;
        _practiceKey += 1;
      }
    });
    _pulseIfEnabled();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: _step == _T1Step.practice
          ? AppColors.sessionBackground
          : AppColors.background,
      body: SafeArea(
        child: switch (_step) {
          _T1Step.cards => _CardsStep(
              cardIndex: _cardIndex,
              l10n: l10n,
              onBack: () {
                if (_cardIndex == 0) {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go(AppRoutes.today);
                  }
                } else {
                  setState(() => _cardIndex -= 1);
                }
              },
              onSkip: () => _finish(feltLift: false),
              onNext: () {
                if (_cardIndex < _cardCount - 1) {
                  setState(() => _cardIndex += 1);
                } else {
                  _startPractice(reset: true);
                }
              },
            ),
          _T1Step.practice => _PracticeStep(
              key: ValueKey<int>(_practiceKey),
              l10n: l10n,
              rep: _rep,
              totalReps: _practiceReps,
              isSqueeze: _isSqueeze,
              duration: _phaseDuration,
              onPhaseDone: () {
                final bool enteringSqueeze = _isSqueeze == false;
                _onPracticePhaseDone();
                if (mounted &&
                    _step == _T1Step.practice &&
                    enteringSqueeze) {
                  _pulseIfEnabled();
                }
              },
              onBack: () => setState(() {
                _step = _T1Step.cards;
                _cardIndex = _cardCount - 1;
              }),
            ),
          _T1Step.feltLift => _FeltLiftStep(
              l10n: l10n,
              onYes: () => _finish(feltLift: true),
              onNotSure: () => setState(() => _step = _T1Step.notSure),
              onBack: () => _startPractice(reset: true),
            ),
          _T1Step.notSure => _NotSureStep(
              l10n: l10n,
              onTryAgain: () => _startPractice(reset: true),
              onContinue: () => _finish(feltLift: false),
              onBack: () => setState(() => _step = _T1Step.feltLift),
            ),
        },
      ),
    );
  }
}

class _CardsStep extends StatelessWidget {
  const _CardsStep({
    required this.cardIndex,
    required this.l10n,
    required this.onBack,
    required this.onSkip,
    required this.onNext,
  });

  final int cardIndex;
  final AppLocalizations l10n;
  final VoidCallback onBack;
  final VoidCallback onSkip;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TutorialHeader(
          title: l10n.t1Title,
          onBack: onBack,
          trailing: TextLinkButton(label: l10n.commonSkip, onPressed: onSkip),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.sm,
              AppSpacing.xl,
              AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (cardIndex == 0) ...<Widget>[
                  const AnatomyDiagram(),
                  const SizedBox(height: AppSpacing.md),
                ],
                _Dots(count: 3, index: cardIndex),
                const SizedBox(height: AppSpacing.lg),
                Text(_cardTitle(l10n, cardIndex), style: AppTypography.display),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _cardBody(l10n, cardIndex),
                  style: AppTypography.body
                      .copyWith(color: AppColors.textSecondary),
                ),
                if (cardIndex == 1) ...<Widget>[
                  const SizedBox(height: AppSpacing.md),
                  AppCard(
                    backgroundColor: AppColors.surfaceMuted,
                    child: Text(
                      l10n.t1Card2UrineNote,
                      style: AppTypography.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                if (cardIndex == 2) ...<Widget>[
                  const SizedBox(height: AppSpacing.lg),
                  _AvoidRow(
                    positive: true,
                    text: l10n.t1AvoidCheckRelaxed,
                  ),
                  _AvoidRow(
                    positive: true,
                    text: l10n.t1AvoidCheckBreathing,
                  ),
                  _AvoidRow(
                    positive: false,
                    text: l10n.t1AvoidCrossButtocks,
                  ),
                  _AvoidRow(
                    positive: false,
                    text: l10n.t1AvoidCrossBreath,
                  ),
                ],
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.md,
            AppSpacing.xl,
            AppSpacing.md,
          ),
          child: PrimaryButton(label: l10n.commonNext, onPressed: onNext),
        ),
      ],
    );
  }

  static String _cardTitle(AppLocalizations l10n, int index) {
    switch (index) {
      case 0:
        return l10n.t1Card1Title;
      case 1:
        return l10n.t1Card2Title;
      default:
        return l10n.t1Card3Title;
    }
  }

  static String _cardBody(AppLocalizations l10n, int index) {
    switch (index) {
      case 0:
        return l10n.t1Card1Body;
      case 1:
        return l10n.t1Card2Body;
      default:
        return l10n.t1Card3Body;
    }
  }
}

class _AvoidRow extends StatelessWidget {
  const _AvoidRow({required this.positive, required this.text});

  final bool positive;
  final String text;

  @override
  Widget build(BuildContext context) {
    final Color color =
        positive ? AppColors.primary : AppColors.goalGeneralFg;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            positive ? Icons.check_circle : Icons.cancel,
            color: color,
            size: 22,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _PracticeStep extends StatelessWidget {
  const _PracticeStep({
    super.key,
    required this.l10n,
    required this.rep,
    required this.totalReps,
    required this.isSqueeze,
    required this.duration,
    required this.onPhaseDone,
    required this.onBack,
  });

  final AppLocalizations l10n;
  final int rep;
  final int totalReps;
  final bool isSqueeze;
  final Duration duration;
  final VoidCallback onPhaseDone;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final SessionPhase phase =
        isSqueeze ? SessionPhase.squeeze : SessionPhase.relax;
    return Column(
      children: [
        _TutorialHeader(
          title: l10n.t1PracticeTitle,
          onBack: onBack,
          dark: true,
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.t1PracticeSubtitle,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.sessionTextSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                SessionRing(
                  key: ValueKey<String>('$rep-$isSqueeze'),
                  phase: phase,
                  duration: duration,
                  size: 220,
                  onCompleted: onPhaseDone,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isSqueeze ? l10n.t1PhaseSqueeze : l10n.t1PhaseRelax,
                        style: AppTypography.title.copyWith(
                          color: AppColors.sessionText,
                          fontSize: 28,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        l10n.t1RepOf(rep, totalReps),
                        style: AppTypography.caption.copyWith(
                          color: AppColors.sessionTextSecondary,
                        ),
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
  }
}

class _FeltLiftStep extends StatelessWidget {
  const _FeltLiftStep({
    required this.l10n,
    required this.onYes,
    required this.onNotSure,
    required this.onBack,
  });

  final AppLocalizations l10n;
  final VoidCallback onYes;
  final VoidCallback onNotSure;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TutorialHeader(title: l10n.t1Title, onBack: onBack),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                Text(l10n.t1FeltLiftTitle, style: AppTypography.display),
                const Spacer(),
                PrimaryButton(label: l10n.t1FeltLiftYes, onPressed: onYes),
                const SizedBox(height: AppSpacing.sm),
                SecondaryButton(
                  label: l10n.t1FeltLiftNotSure,
                  onPressed: onNotSure,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _NotSureStep extends StatelessWidget {
  const _NotSureStep({
    required this.l10n,
    required this.onTryAgain,
    required this.onContinue,
    required this.onBack,
  });

  final AppLocalizations l10n;
  final VoidCallback onTryAgain;
  final VoidCallback onContinue;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TutorialHeader(title: l10n.t1Title, onBack: onBack),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                Text(l10n.t1FeltLiftNotSure, style: AppTypography.display),
                const SizedBox(height: AppSpacing.md),
                Text(
                  l10n.t1NotSureTip,
                  style: AppTypography.body
                      .copyWith(color: AppColors.textSecondary),
                ),
                const Spacer(),
                PrimaryButton(
                  label: l10n.commonTryAgain,
                  onPressed: onTryAgain,
                ),
                const SizedBox(height: AppSpacing.sm),
                SecondaryButton(
                  label: l10n.commonContinueAnyway,
                  onPressed: onContinue,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TutorialHeader extends StatelessWidget {
  const _TutorialHeader({
    required this.title,
    required this.onBack,
    this.trailing,
    this.dark = false,
  });

  final String title;
  final VoidCallback onBack;
  final Widget? trailing;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final Color fg = dark ? AppColors.sessionText : AppColors.textPrimary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: Icon(Icons.arrow_back, color: fg),
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.title.copyWith(color: fg, fontSize: 18),
            ),
          ),
          if (trailing != null)
            trailing!
          else
            const SizedBox(width: AppSpacing.minTouchTarget),
        ],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < count; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: i == index ? 18 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i == index ? AppColors.ink : AppColors.border,
              borderRadius: AppRadii.pillAll,
            ),
          ),
        ],
      ],
    );
  }
}
