import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../../app/l10n/app_localizations.dart';
import '../../../app/theme/tokens.dart';
import '../engine/engine_models.dart';
import '../engine/session_timeline.dart';
import '../session_time_format.dart';
import 'player_controls.dart';

/// Player layout for Relax-and-breathe sessions.
///
/// Header with cycles / elapsed time / current cycle; a glowing ring with a
/// sweep for the current phase and an orb that grows on the in-breath and
/// shrinks on the out-breath; Inhale/Exhale step circles; controls with a
/// forward button. Stretch and reverse-Kegel parts reuse the ring as a calm
/// countdown. Diaphragmatic breathing has no breath-holds (patient guidance:
/// never hold the breath), so only Inhale and Exhale steps are shown.
class BreathePlayerView extends StatelessWidget {
  const BreathePlayerView({
    super.key,
    required this.l10n,
    required this.state,
    required this.phaseLabel,
    required this.blockTitle,
    required this.nextTitle,
    required this.cue,
    required this.voiceOn,
    required this.onToggleVoice,
    required this.onExit,
    required this.onTogglePause,
    required this.onForward,
  });

  final AppLocalizations l10n;
  final EngineState state;
  final String phaseLabel;
  final String blockTitle;
  final String nextTitle;
  final String cue;
  final bool voiceOn;
  final VoidCallback onToggleVoice;
  final VoidCallback onExit;
  final VoidCallback onTogglePause;
  final VoidCallback onForward;

  bool get _isBreathing =>
      state.phaseWord == SessionPhaseKey.breatheIn ||
      state.phaseWord == SessionPhaseKey.breatheOut ||
      (state.machine == EngineMachineState.paused &&
          state.rep != null &&
          state.blockTitleKey == 'breathing');

  @override
  Widget build(BuildContext context) {
    final bool paused = state.machine == EngineMachineState.paused;
    final bool inhale = state.phaseWord == SessionPhaseKey.breatheIn;
    final bool exhale = state.phaseWord == SessionPhaseKey.breatheOut;

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.xs,
              AppSpacing.md,
              0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    blockTitle,
                    maxLines: 2,
                    style: AppTypography.title.copyWith(
                      color: AppColors.sessionText,
                      fontSize: 22,
                    ),
                  ),
                ),
                PlayerToggle(
                  on: voiceOn,
                  onIcon: Icons.volume_up_rounded,
                  offIcon: Icons.volume_off_rounded,
                  label: l10n.s3Voice,
                  onTap: onToggleVoice,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _Stat(
                  value: '${state.totalReps ?? '–'}',
                  label: l10n.brCycles,
                ),
                Expanded(
                  child: Text(
                    formatSessionElapsed(state.elapsedSeconds),
                    textAlign: TextAlign.center,
                    style: AppTypography.display.copyWith(
                      color: AppColors.accent,
                      fontSize: 44,
                      fontWeight: FontWeight.w800,
                      fontFeatures: const <FontFeature>[
                        FontFeature.tabularFigures(),
                      ],
                    ),
                  ),
                ),
                _Stat(
                  value: '${state.rep ?? '–'}',
                  label: l10n.brCycle,
                  alignEnd: true,
                ),
              ],
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints c) {
                final double size =
                    math.min(280, math.min(c.maxWidth - 64, c.maxHeight - 24));
                return Center(
                  child: _BreathRing(
                    size: math.max(160, size),
                    progress: state.phaseProgress,
                    inhale: inhale,
                    exhale: exhale,
                    paused: paused,
                    word: phaseLabel,
                    secondsLeft:
                        formatPhaseSecondsRemaining(state.secondsRemaining),
                  ),
                );
              },
            ),
          ),
          if (_isBreathing) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _StepCircle(
                  seconds: SessionTimeline.inhale.inSeconds,
                  label: l10n.brInhale,
                  active: inhale,
                ),
                const SizedBox(width: AppSpacing.xl),
                _StepCircle(
                  seconds: SessionTimeline.exhale.inSeconds,
                  label: l10n.brExhale,
                  active: exhale,
                ),
              ],
            ),
          ] else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Text(
                cue,
                textAlign: TextAlign.center,
                style: AppTypography.body.copyWith(
                  color: AppColors.sessionTextSecondary,
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Text(
              l10n.s3NextBlock(nextTitle),
              textAlign: TextAlign.center,
              style: AppTypography.caption.copyWith(
                color: AppColors.sessionTextSecondary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: PlayerControls(
              paused: paused,
              onTogglePause: onTogglePause,
              onForward: onForward,
              onExit: onExit,
              pauseLabel: l10n.s3Pause,
              resumeLabel: l10n.s3Resume,
              forwardLabel: l10n.s3ForwardPhase,
              exitLabel: l10n.s3Exit,
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, this.alignEnd = false});

  final String value;
  final String label;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      child: Column(
        crossAxisAlignment:
            alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: AppTypography.title.copyWith(
              color: AppColors.accent,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: AppTypography.caption.copyWith(color: AppColors.sessionText),
          ),
        ],
      ),
    );
  }
}

/// Glowing ring: phase sweep + an orb that breathes with the phase.
class _BreathRing extends StatelessWidget {
  const _BreathRing({
    required this.size,
    required this.progress,
    required this.inhale,
    required this.exhale,
    required this.paused,
    required this.word,
    required this.secondsLeft,
  });

  final double size;
  final double progress;
  final bool inhale;
  final bool exhale;
  final bool paused;
  final String word;
  final String secondsLeft;

  @override
  Widget build(BuildContext context) {
    final double eased = Curves.easeInOut.transform(progress.clamp(0.0, 1.0));
    final double orb = inhale
        ? 0.55 + 0.4 * eased
        : (exhale ? 0.95 - 0.4 * eased : 0.75);
    return Semantics(
      liveRegion: true,
      label: word,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow.
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: paused ? 0.15 : 0.35),
                    blurRadius: 48,
                    spreadRadius: 4,
                  ),
                ],
              ),
            ),
            CustomPaint(
              size: Size.square(size),
              painter: _RingPainter(progress: progress, paused: paused),
            ),
            // Breathing orb.
            Container(
              width: size * 0.72 * orb,
              height: size * 0.72 * orb,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: <Color>[
                    AppColors.accent.withValues(alpha: 0.35),
                    AppColors.accent.withValues(alpha: 0.05),
                  ],
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  word,
                  textAlign: TextAlign.center,
                  style: AppTypography.display.copyWith(
                    color: AppColors.accent,
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  secondsLeft,
                  style: AppTypography.body.copyWith(
                    color: AppColors.sessionText,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress, required this.paused});

  final double progress;
  final bool paused;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset c = size.center(Offset.zero);
    final double r = size.width / 2 - 3;
    canvas.drawCircle(c, r - 6, Paint()..color = AppColors.sessionSurface);
    // Phase sweep as a soft pie, like a clock hand filling the dial.
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r - 12),
      -math.pi / 2,
      2 * math.pi * progress.clamp(0.0, 1.0),
      true,
      Paint()..color = AppColors.accent.withValues(alpha: 0.22),
    );
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = paused ? AppColors.sessionRingTrack : AppColors.accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress || old.paused != paused;
}

class _StepCircle extends StatelessWidget {
  const _StepCircle({
    required this.seconds,
    required this.label,
    required this.active,
  });

  final int seconds;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? AppColors.accent : Colors.transparent,
            border: Border.all(color: AppColors.accent, width: 1.5),
            boxShadow: active
                ? <BoxShadow>[
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.4),
                      blurRadius: 16,
                    ),
                  ]
                : const <BoxShadow>[],
          ),
          alignment: Alignment.center,
          child: Text(
            '$seconds',
            style: AppTypography.title.copyWith(
              color: active ? AppColors.ink : AppColors.sessionText,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          label,
          style: AppTypography.caption.copyWith(color: AppColors.sessionText),
        ),
      ],
    );
  }
}
