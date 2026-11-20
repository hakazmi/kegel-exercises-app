import 'dart:async';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/theme/tokens.dart';
import '../../../core/motion/app_motion.dart';

/// Bottom controls shared by every player: exit, big pause/resume, forward.
///
/// Forward skips to the next phase (Kegel, breathing) or the next exercise
/// (body sessions); the caller decides and passes the matching label.
class PlayerControls extends StatelessWidget {
  const PlayerControls({
    super.key,
    required this.paused,
    required this.onTogglePause,
    required this.onForward,
    required this.onExit,
    required this.pauseLabel,
    required this.resumeLabel,
    required this.forwardLabel,
    required this.exitLabel,
  });

  final bool paused;
  final VoidCallback onTogglePause;
  final VoidCallback onForward;
  final VoidCallback onExit;
  final String pauseLabel;
  final String resumeLabel;
  final String forwardLabel;
  final String exitLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RoundAction(
          icon: Icons.close_rounded,
          label: exitLabel,
          onTap: onExit,
        ),
        _PauseButton(
          paused: paused,
          label: paused ? resumeLabel : pauseLabel,
          onTap: onTogglePause,
        ),
        _RoundAction(
          icon: Icons.skip_next_rounded,
          label: forwardLabel,
          onTap: () {
            unawaited(HapticFeedback.selectionClick());
            onForward();
          },
          emphasised: true,
        ),
      ],
    );
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.emphasised = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool emphasised;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 88,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          PressScale(
            onTap: onTap,
            semanticLabel: label,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.sessionSurface,
                border: Border.all(
                  color: emphasised
                      ? AppColors.accent
                      : AppColors.sessionRingTrack,
                  width: 1.5,
                ),
              ),
              child: Icon(
                icon,
                size: 28,
                color: emphasised ? AppColors.accent : AppColors.sessionText,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: AppTypography.caption.copyWith(
              color: AppColors.sessionTextSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _PauseButton extends StatelessWidget {
  const _PauseButton({
    required this.paused,
    required this.label,
    required this.onTap,
  });

  final bool paused;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PressScale(
            onTap: onTap,
            semanticLabel: label,
            child: PulseHalo(
              color: AppColors.accent,
              size: 76,
              active: paused,
              child: Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accent,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.45),
                      blurRadius: 24,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: AnimatedSwitcher(
                  duration: AppMotion.quick,
                  transitionBuilder: (Widget child, Animation<double> a) =>
                      ScaleTransition(scale: a, child: child),
                  child: Icon(
                    paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                    key: ValueKey<bool>(paused),
                    size: 40,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.sessionText,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// Small round toggle for the top bar (voice, vibration).
class PlayerToggle extends StatelessWidget {
  const PlayerToggle({
    super.key,
    required this.on,
    required this.onIcon,
    required this.offIcon,
    required this.label,
    required this.onTap,
  });

  final bool on;
  final IconData onIcon;
  final IconData offIcon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: on,
      child: PressScale(
        onTap: onTap,
        semanticLabel: label,
        child: AnimatedContainer(
          duration: AppMotion.quick,
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: on
                ? AppColors.accent.withValues(alpha: 0.16)
                : AppColors.sessionSurface,
            borderRadius: AppRadii.mdAll,
          ),
          child: Icon(
            on ? onIcon : offIcon,
            size: 22,
            color: on ? AppColors.accent : AppColors.sessionTextSecondary,
          ),
        ),
      ),
    );
  }
}
