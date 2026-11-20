import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/l10n/app_localizations.dart';
import '../../app/theme/system_ui.dart';
import '../../app/theme/tokens.dart';
import '../../core/data/providers.dart';
import '../../core/data/repositories/hold_test_repository.dart';
import '../../core/motion/app_motion.dart';
import '../../core/widgets/widgets.dart';
import '../onboarding/widgets/onboarding_stage.dart';

enum _Step { ready, holding, accident, reasons, explain, finish, saved }

enum _Reason { strength, endurance, none }

/// Pelvic floor hold test: press and hold the button while squeezing, let
/// go when you relax. Then a short check (did you let go by accident?),
/// a reason, a short explanation, and save or try again. Results stay on
/// the phone and show in Progress.
class HoldTestScreen extends ConsumerStatefulWidget {
  const HoldTestScreen({super.key});

  /// Shorter presses are treated as a tap, not a test.
  static const double minSeconds = 1;

  /// The dial fills once over this many seconds.
  static const double dialSeconds = 20;

  @override
  ConsumerState<HoldTestScreen> createState() => _HoldTestScreenState();
}

class _HoldTestScreenState extends ConsumerState<HoldTestScreen> {
  _Step _step = _Step.ready;
  _Reason? _reason;
  final Stopwatch _watch = Stopwatch();
  Timer? _ticker;
  double _seconds = 0;
  bool _tooShort = false;
  int _lastWholeSecond = 0;

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _press() {
    if (_step != _Step.ready) {
      return;
    }
    unawaited(HapticFeedback.mediumImpact());
    _watch
      ..reset()
      ..start();
    _lastWholeSecond = 0;
    setState(() {
      _step = _Step.holding;
      _seconds = 0;
      _tooShort = false;
    });
    _ticker = Timer.periodic(const Duration(milliseconds: 100), (_) {
      final double s = _watch.elapsedMilliseconds / 1000;
      final int whole = s.floor();
      if (whole > _lastWholeSecond) {
        _lastWholeSecond = whole;
        unawaited(HapticFeedback.selectionClick());
      }
      setState(() => _seconds = s);
    });
  }

  void _release() {
    if (_step != _Step.holding) {
      return;
    }
    _ticker?.cancel();
    _watch.stop();
    final double s = _watch.elapsedMilliseconds / 1000;
    unawaited(HapticFeedback.lightImpact());
    setState(() {
      _seconds = s;
      if (s < HoldTestScreen.minSeconds) {
        _tooShort = true;
        _step = _Step.ready;
      } else {
        _step = _Step.accident;
      }
    });
  }

  void _restart() => setState(() {
    _step = _Step.ready;
    _seconds = 0;
    _reason = null;
    _tooShort = false;
  });

  Future<void> _save() async {
    final double rounded = (_seconds * 10).round() / 10;
    await ref.read(holdTestsProvider.notifier).add(rounded);
    if (mounted) {
      setState(() => _step = _Step.saved);
    }
  }

  void _back() {
    switch (_step) {
      case _Step.reasons:
        setState(() => _step = _Step.accident);
      case _Step.explain:
        setState(() => _step = _Step.reasons);
      case _Step.finish:
        setState(() => _step = _Step.explain);
      case _Step.ready:
      case _Step.holding:
      case _Step.accident:
      case _Step.saved:
        if (context.canPop()) {
          context.pop();
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<HoldTestResult> results = ref.watch(holdTestsProvider);
    final double? best = results.isEmpty
        ? null
        : results.map((HoldTestResult r) => r.seconds).reduce(math.max);

    final Widget body = switch (_step) {
      _Step.ready || _Step.holding => _TimerStep(
        l10n: l10n,
        seconds: _seconds,
        holding: _step == _Step.holding,
        best: best,
        tooShort: _tooShort,
        onPress: _press,
        onRelease: _release,
      ),
      _Step.accident => _AccidentStep(
        l10n: l10n,
        seconds: _seconds,
        onNo: () => setState(() => _step = _Step.reasons),
        onTestAgain: _restart,
      ),
      _Step.reasons => _ReasonStep(
        l10n: l10n,
        onPick: (_Reason r) => setState(() {
          _reason = r;
          _step = _Step.explain;
        }),
      ),
      _Step.explain => _ExplainStep(
        l10n: l10n,
        reason: _reason ?? _Reason.none,
        onGotIt: () => setState(() => _step = _Step.finish),
      ),
      _Step.finish => _FinishStep(
        l10n: l10n,
        seconds: _seconds,
        best: best,
        onSave: _save,
        onTryAgain: _restart,
      ),
      _Step.saved => _SavedStep(
        l10n: l10n,
        seconds: _seconds,
        onDone: () {
          if (context.canPop()) {
            context.pop();
          }
        },
        onAgain: _restart,
      ),
    };

    return PopScope(
      canPop: _step == _Step.ready || _step == _Step.saved,
      onPopInvokedWithResult: (bool didPop, Object? _) {
        if (!didPop) {
          _back();
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: AppSystemUi.lightScreen,
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                _Header(
                  title: l10n.htTitle,
                  onBack: _step == _Step.holding ? null : _back,
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: AppMotion.isReduced(context)
                        ? Duration.zero
                        : const Duration(milliseconds: 320),
                    transitionBuilder: (Widget child, Animation<double> a) =>
                        FadeTransition(
                          opacity: a,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.06, 0),
                              end: Offset.zero,
                            ).animate(a),
                            child: child,
                          ),
                        ),
                    child: KeyedSubtree(
                      key: ValueKey<_Step>(
                        _step == _Step.holding ? _Step.ready : _step,
                      ),
                      child: body,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _fmt(double s) => s.toStringAsFixed(1);

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.onBack});

  final String title;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Row(
        children: [
          AnimatedOpacity(
            duration: AppMotion.quick,
            opacity: onBack == null ? 0.3 : 1,
            child: PressScale(
              onTap: onBack,
              semanticLabel: MaterialLocalizations.of(context)
                  .backButtonTooltip,
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
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.title.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: AppSpacing.minTouchTarget),
        ],
      ),
    );
  }
}

/// Dial + big seconds + press-and-hold button.
class _TimerStep extends StatelessWidget {
  const _TimerStep({
    required this.l10n,
    required this.seconds,
    required this.holding,
    required this.best,
    required this.tooShort,
    required this.onPress,
    required this.onRelease,
  });

  final AppLocalizations l10n;
  final double seconds;
  final bool holding;
  final double? best;
  final bool tooShort;
  final VoidCallback onPress;
  final VoidCallback onRelease;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints box) {
        final double dial = math.min(
          math.min(box.maxWidth - AppSpacing.xl * 2, 320),
          math.max(200, box.maxHeight - 280),
        );
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: box.maxHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _Dial(
                    size: dial,
                    seconds: seconds,
                    best: best,
                    holding: holding,
                    bestLabel: best == null ? null : l10n.htBest(_fmt(best!)),
                    unit: l10n.htSeconds,
                  ),
                  AnimatedSwitcher(
                    duration: AppMotion.quick,
                    child: Text(
                      tooShort
                          ? l10n.htTooShort
                          : (holding ? l10n.htHoldPrompt : l10n.htPressPrompt),
                      key: ValueKey<String>('$holding$tooShort'),
                      textAlign: TextAlign.center,
                      style: AppTypography.body.copyWith(
                        fontWeight: FontWeight.w700,
                        color: tooShort
                            ? AppColors.goalEjaculationFg
                            : AppColors.ink,
                      ),
                    ),
                  ),
                  _HoldButton(
                    label: holding ? l10n.htHold : l10n.htPress,
                    holding: holding,
                    onPress: onPress,
                    onRelease: onRelease,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Dial extends StatelessWidget {
  const _Dial({
    required this.size,
    required this.seconds,
    required this.best,
    required this.holding,
    required this.bestLabel,
    required this.unit,
  });

  final double size;
  final double seconds;
  final double? best;
  final bool holding;
  final String? bestLabel;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: size,
      height: size,
      padding: EdgeInsets.all(holding ? 0 : size * 0.04),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: holding ? AppColors.mint : Colors.transparent,
      ),
      child: CustomPaint(
        painter: _TicksPainter(
          fraction: seconds / HoldTestScreen.dialSeconds,
          best: best == null ? null : best! / HoldTestScreen.dialSeconds,
        ),
        child: Padding(
          padding: EdgeInsets.all(size * 0.13),
          child: DecoratedBox(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              boxShadow: AppElevation.level2,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${seconds.floor()}',
                    style: AppTypography.display.copyWith(
                      fontSize: size * 0.24,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                  Text(
                    unit,
                    style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (bestLabel != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: 2,
                      ),
                      decoration: const BoxDecoration(
                        color: AppColors.streakBg,
                        borderRadius: AppRadii.pillAll,
                      ),
                      child: Text(
                        bestLabel!,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.streakFg,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
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
    );
  }
}

/// 90 radial ticks; the first [fraction] of them light up clockwise, and a
/// gold tick marks the best result.
class _TicksPainter extends CustomPainter {
  _TicksPainter({required this.fraction, required this.best});

  final double fraction;
  final double? best;

  static const int _count = 90;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset c = size.center(Offset.zero);
    final double outer = size.shortestSide / 2;
    final double inner = outer * 0.84;
    // Past one full turn the dial starts again, a little brighter.
    final double f = fraction % 1;
    final int laps = fraction.floor();
    final int lit = (f * _count).round();
    final int? bestTick = best == null
        ? null
        : ((best! % 1) * _count).round() % _count;
    for (int i = 0; i < _count; i++) {
      final double a = -math.pi / 2 + 2 * math.pi * i / _count;
      final Offset dir = Offset(math.cos(a), math.sin(a));
      final bool on = i < lit || (laps > 0 && lit == 0 && fraction > 0);
      final bool isBest = bestTick != null && i == bestTick;
      final Color color = isBest
          ? AppColors.streakFg
          : on
          ? Color.lerp(
              AppColors.accent,
              AppColors.primary,
              laps > 0 ? 1 : i / _count,
            )!
          : AppColors.border;
      canvas.drawLine(
        c + dir * inner,
        c + dir * (isBest ? outer + 2 : outer),
        Paint()
          ..color = color
          ..strokeWidth = isBest ? 4 : 3
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_TicksPainter old) =>
      old.fraction != fraction || old.best != best;
}

/// Big round button: hold it down for the whole squeeze.
class _HoldButton extends StatelessWidget {
  const _HoldButton({
    required this.label,
    required this.holding,
    required this.onPress,
    required this.onRelease,
  });

  final String label;
  final bool holding;
  final VoidCallback onPress;
  final VoidCallback onRelease;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Listener(
        onPointerDown: (_) => onPress(),
        onPointerUp: (_) => onRelease(),
        onPointerCancel: (_) => onRelease(),
        child: PulseHalo(
          color: AppColors.accent,
          size: 116,
          active: !holding,
          child: AnimatedScale(
            scale: holding ? 1.1 : 1,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutBack,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 116,
              height: 116,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: holding
                      ? const <Color>[AppColors.primary, AppColors.ink]
                      : const <Color>[AppColors.accent, AppColors.primary],
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: holding ? 30 : 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                style: AppTypography.title.copyWith(
                  color: AppColors.textOnPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Shared layout for the question / message steps.
class _Panel extends StatelessWidget {
  const _Panel({required this.children, this.footer});

  final List<Widget> children;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ),
        if (footer != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.xs,
              AppSpacing.xl,
              AppSpacing.md,
            ),
            child: footer,
          ),
      ],
    );
  }
}

class _ResultBadge extends StatelessWidget {
  const _ResultBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: const BoxDecoration(
          color: AppColors.mint,
          borderRadius: AppRadii.pillAll,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.timer_rounded, size: 18, color: AppColors.primary),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                text,
                style: AppTypography.body.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.label,
    required this.onTap,
    this.icon,
    this.selected = false,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: onTap,
      semanticLabel: label,
      child: AnimatedContainer(
        duration: AppMotion.quick,
        constraints: const BoxConstraints(minHeight: 64),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.mint : AppColors.surface,
          borderRadius: AppRadii.lgAll,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 2 : 1,
          ),
          boxShadow: AppElevation.level1,
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
            ],
            Expanded(
              child: Text(
                label,
                textAlign: icon == null ? TextAlign.center : TextAlign.start,
                style: AppTypography.body.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccidentStep extends StatefulWidget {
  const _AccidentStep({
    required this.l10n,
    required this.seconds,
    required this.onNo,
    required this.onTestAgain,
  });

  final AppLocalizations l10n;
  final double seconds;
  final VoidCallback onNo;
  final VoidCallback onTestAgain;

  @override
  State<_AccidentStep> createState() => _AccidentStepState();
}

class _AccidentStepState extends State<_AccidentStep> {
  bool _yes = false;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = widget.l10n;
    return _Panel(
      footer: _yes
          ? Reveal(
              from: RevealFrom.rise,
              child: PrimaryButton(
                label: l10n.htTestAgain,
                icon: Icons.replay_rounded,
                onPressed: widget.onTestAgain,
              ),
            )
          : null,
      children: [
        _ResultBadge(text: l10n.htResult(_fmt(widget.seconds))),
        const SizedBox(height: AppSpacing.xl),
        Text(
          l10n.htAccidentQ,
          textAlign: TextAlign.center,
          style: AppTypography.title.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Row(
          children: [
            Expanded(
              child: _ChoiceCard(label: l10n.htNo, onTap: widget.onNo),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _ChoiceCard(
                label: l10n.htYes,
                selected: _yes,
                onTap: () => setState(() => _yes = true),
              ),
            ),
          ],
        ),
        if (_yes) ...[
          const SizedBox(height: AppSpacing.lg),
          Reveal(
            from: RevealFrom.fade,
            child: Text(
              l10n.htAccidentNote,
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ReasonStep extends StatelessWidget {
  const _ReasonStep({required this.l10n, required this.onPick});

  final AppLocalizations l10n;
  final ValueChanged<_Reason> onPick;

  @override
  Widget build(BuildContext context) {
    final List<(_Reason, String, IconData)> options =
        <(_Reason, String, IconData)>[
          (
            _Reason.strength,
            l10n.htReasonStrength,
            Icons.fitness_center_rounded,
          ),
          (_Reason.endurance, l10n.htReasonEndurance, Icons.timelapse_rounded),
          (_Reason.none, l10n.htReasonNone, Icons.emoji_events_outlined),
        ];
    return _Panel(
      children: [
        const SizedBox(height: AppSpacing.lg),
        Text(
          l10n.htReasonQ,
          textAlign: TextAlign.center,
          style: AppTypography.title.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        for (int i = 0; i < options.length; i++) ...[
          Reveal(
            from: RevealFrom.rise,
            delay: AppMotion.stagger(i),
            child: _ChoiceCard(
              label: options[i].$2,
              icon: options[i].$3,
              onTap: () => onPick(options[i].$1),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _ExplainStep extends StatelessWidget {
  const _ExplainStep({
    required this.l10n,
    required this.reason,
    required this.onGotIt,
  });

  final AppLocalizations l10n;
  final _Reason reason;
  final VoidCallback onGotIt;

  @override
  Widget build(BuildContext context) {
    final (
      String title,
      String body,
      String p1,
      String p2,
      String footer,
      String art,
      Color tint,
    ) = switch (reason) {
      _Reason.strength => (
        l10n.htStrengthTitle,
        l10n.htStrengthBody,
        l10n.htStrengthPoint1,
        l10n.htStrengthPoint2,
        l10n.htStrengthFooter,
        OnboardingArt.welcomeMan,
        AppColors.peach,
      ),
      _Reason.endurance => (
        l10n.htEnduranceTitle,
        l10n.htEnduranceBody,
        l10n.htEndurancePoint1,
        l10n.htEndurancePoint2,
        l10n.htEnduranceFooter,
        OnboardingArt.stopwatch,
        AppColors.sky,
      ),
      _Reason.none => (
        l10n.htNoneTitle,
        l10n.htNoneBody,
        l10n.htNonePoint1,
        l10n.htNonePoint2,
        l10n.htNoneFooter,
        OnboardingArt.goalShield,
        AppColors.pistachio,
      ),
    };
    return _Panel(
      footer: PrimaryButton(label: l10n.htGotIt, onPressed: onGotIt),
      children: [
        Container(
          height: 190,
          decoration: BoxDecoration(
            borderRadius: AppRadii.xlAll,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[tint, Color.lerp(tint, AppColors.surface, 0.6)!],
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned(
                right: -40,
                top: -40,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.surface.withValues(alpha: 0.45),
                      width: 22,
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                top: AppSpacing.sm,
                child: Center(
                  child: FloatBob(
                    lift: 4,
                    child: Image.asset(
                      art,
                      height: 170,
                      fit: BoxFit.contain,
                      excludeFromSemantics: true,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(title, style: AppTypography.display.copyWith(fontSize: 24)),
        const SizedBox(height: AppSpacing.sm),
        Text(body, style: AppTypography.body),
        const SizedBox(height: AppSpacing.md),
        for (final String p in <String>[p1, p2])
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(
                    Icons.check_circle_rounded,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: Text(p, style: AppTypography.body)),
              ],
            ),
          ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: const BoxDecoration(
            color: AppColors.mint,
            borderRadius: AppRadii.lgAll,
          ),
          child: Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  footer,
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FinishStep extends StatelessWidget {
  const _FinishStep({
    required this.l10n,
    required this.seconds,
    required this.best,
    required this.onSave,
    required this.onTryAgain,
  });

  final AppLocalizations l10n;
  final double seconds;
  final double? best;
  final VoidCallback onSave;
  final VoidCallback onTryAgain;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      footer: Column(
        children: [
          PrimaryButton(
            label: l10n.htSave,
            icon: Icons.bookmark_added_rounded,
            onPressed: onSave,
          ),
          const SizedBox(height: AppSpacing.sm),
          SecondaryButton(
            label: l10n.htTryAgain,
            icon: Icons.replay_rounded,
            onPressed: onTryAgain,
          ),
        ],
      ),
      children: [
        const SizedBox(height: AppSpacing.xl),
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              const CompletionBurst(size: 220, color: AppColors.accent),
              Container(
                width: 150,
                height: 150,
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  boxShadow: AppElevation.level2,
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _fmt(seconds),
                      style: AppTypography.display.copyWith(
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                    Text(l10n.htSeconds, style: AppTypography.caption),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (best != null) ...[
          const SizedBox(height: AppSpacing.md),
          Center(
            child: Text(
              l10n.htBest(_fmt(best!)),
              style: AppTypography.body.copyWith(
                color: AppColors.streakFg,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        Text(
          l10n.htSaveQ,
          textAlign: TextAlign.center,
          style: AppTypography.title.copyWith(fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

class _SavedStep extends StatelessWidget {
  const _SavedStep({
    required this.l10n,
    required this.seconds,
    required this.onDone,
    required this.onAgain,
  });

  final AppLocalizations l10n;
  final double seconds;
  final VoidCallback onDone;
  final VoidCallback onAgain;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      footer: Column(
        children: [
          PrimaryButton(label: l10n.htDone, onPressed: onDone),
          const SizedBox(height: AppSpacing.sm),
          SecondaryButton(
            label: l10n.htTestAgain,
            icon: Icons.replay_rounded,
            onPressed: onAgain,
          ),
        ],
      ),
      children: [
        const SizedBox(height: AppSpacing.xxl),
        const Center(
          child: AnimatedCheckBadge(
            size: 96,
            color: AppColors.primary,
            checkColor: AppColors.textOnPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _ResultBadge(text: l10n.htResult(_fmt(seconds))),
        const SizedBox(height: AppSpacing.md),
        Text(
          l10n.htSaved,
          textAlign: TextAlign.center,
          style: AppTypography.body.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
