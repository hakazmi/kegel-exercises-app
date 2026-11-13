import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/l10n/app_localizations.dart';
import '../../app/router.dart';
import '../../app/theme/tokens.dart';
import '../../core/data/providers.dart';
import '../../core/domain/user_profile.dart';
import '../../core/widgets/confirm_dialog.dart';
import 'engine/engine_models.dart';
import 'session_controller.dart';
import 'session_time_format.dart';
import 'widgets/session_muscle_ring.dart';

/// S3 Player — ring, cues, pause/voice/vibration/exit.
class S3PlayerScreen extends ConsumerStatefulWidget {
  const S3PlayerScreen({
    super.key,
    this.itemId,
  });

  final String? itemId;

  @override
  ConsumerState<S3PlayerScreen> createState() => _S3PlayerScreenState();
}

class _S3PlayerScreenState extends ConsumerState<S3PlayerScreen>
    with WidgetsBindingObserver {
  String? _lastAnnounced;
  bool _navigating = false;

  static const List<String> _cueKeys = <String>[
    'breathing',
    'relaxed',
    'letGo',
    'gentle',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureSession());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      final SessionPlayState? play = ref.read(sessionControllerProvider);
      if (play != null && play.engineState.isActive) {
        ref.read(sessionControllerProvider.notifier).pause();
      }
    }
  }

  Future<void> _ensureSession() async {
    final String itemId = widget.itemId ?? 'strength_1';
    final SessionPlayState? existing = ref.read(sessionControllerProvider);
    if (existing == null) {
      await ref.read(sessionControllerProvider.notifier).begin(itemId);
      ref.read(sessionControllerProvider.notifier).skipCountdown();
    } else if (existing.engineState.machine == EngineMachineState.countdown) {
      ref.read(sessionControllerProvider.notifier).skipCountdown();
    }
  }

  void _goDone() {
    if (_navigating || !mounted) {
      return;
    }
    _navigating = true;
    context.go(
      '${AppRoutes.done}?itemId=${Uri.encodeComponent(widget.itemId ?? 'strength_1')}',
    );
  }

  Future<void> _confirmExit() async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool ok = await ConfirmDialog.show(
      context,
      title: l10n.s3ExitTitle,
      message: l10n.s3ExitMessage,
      confirmLabel: l10n.s3ExitConfirm,
      cancelLabel: l10n.commonCancel,
      isDestructive: true,
    );
    if (!ok || !mounted) {
      return;
    }
    await ref.read(sessionControllerProvider.notifier).exitSession();
    if (!mounted) {
      return;
    }
    context.go(AppRoutes.today);
  }

  String _blockTitle(AppLocalizations l10n, String key) {
    switch (key) {
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
      case 'stretch':
        return l10n.s3BlockStretch;
      default:
        return key;
    }
  }

  String _cue(AppLocalizations l10n, int elapsedSeconds) {
    final String key = _cueKeys[elapsedSeconds % _cueKeys.length];
    switch (key) {
      case 'breathing':
        return l10n.s3CueBreathing;
      case 'relaxed':
        return l10n.s3CueRelaxed;
      case 'letGo':
        return l10n.s3CueLetGo;
      case 'gentle':
      default:
        return l10n.s3CueGentle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final UserProfile profile = ref.watch(userProfileProvider);
    final SessionPlayState? play = ref.watch(sessionControllerProvider);

    ref.listen<SessionPlayState?>(sessionControllerProvider,
        (SessionPlayState? prev, SessionPlayState? next) {
      if (next == null || _navigating) {
        return;
      }
      if (next.summary != null ||
          (next.engineState.completed && !next.engineState.exited)) {
        _goDone();
        return;
      }
      final String word = next.engineState.phaseWord;
      if (word.isNotEmpty && word != _lastAnnounced) {
        _lastAnnounced = word;
        SemanticsService.sendAnnouncement(
          View.of(context),
          word,
          TextDirection.ltr,
        );
      }
    });

    if (play == null) {
      return const Scaffold(
        backgroundColor: AppColors.sessionBackground,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final EngineState es = play.engineState;
    final bool paused = es.machine == EngineMachineState.paused;
    final String blockTitle = _blockTitle(l10n, es.blockTitleKey);
    final String header = es.rep != null && es.totalReps != null
        ? l10n.s3BlockRepHeader(blockTitle, es.rep!, es.totalReps!)
        : blockTitle;
    final String? nextKey = es.nextBlockTitleKey;
    final String nextTitle =
        nextKey == null ? l10n.s3NoNextBlock : _blockTitle(l10n, nextKey);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemStatusBarContrastEnforced: false,
      ),
      child: Scaffold(
        backgroundColor: AppColors.sessionBackground,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.sm,
                  AppSpacing.xl,
                  0,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        header,
                        style: AppTypography.body.copyWith(
                          color: AppColors.sessionText,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      formatSessionElapsed(es.elapsedSeconds),
                      style: AppTypography.body.copyWith(
                        color: AppColors.sessionTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Semantics(
                      liveRegion: true,
                      label: es.phaseWord,
                      child: SessionMuscleRing(engineState: es),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      es.phaseWord,
                      style: AppTypography.display.copyWith(
                        color: AppColors.sessionText,
                        fontSize: 36,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      formatPhaseSecondsRemaining(es.secondsRemaining),
                      style: AppTypography.title.copyWith(
                        color: AppColors.sessionTextSecondary,
                        fontSize: 28,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                      ),
                      child: Text(
                        _cue(l10n, es.elapsedSeconds),
                        textAlign: TextAlign.center,
                        style: AppTypography.body.copyWith(
                          color: AppColors.sessionTextSecondary,
                        ),
                      ),
                    ),
                    if (es.rep != null && es.totalReps != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        l10n.s3RepOf(es.rep!, es.totalReps!),
                        style: AppTypography.caption.copyWith(
                          color: AppColors.sessionTextSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: const BoxDecoration(
                    color: AppColors.sessionSurface,
                    borderRadius: AppRadii.lgAll,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.s3NowBlock(blockTitle),
                        style: AppTypography.body.copyWith(
                          color: AppColors.sessionText,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        l10n.s3NextBlock(nextTitle),
                        style: AppTypography.caption.copyWith(
                          color: AppColors.sessionTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  0,
                  AppSpacing.xl,
                  AppSpacing.md,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ControlButton(
                      icon: paused ? Icons.play_arrow : Icons.pause,
                      label: paused ? l10n.s3Resume : l10n.s3Pause,
                      onPressed: () {
                        if (paused) {
                          ref.read(sessionControllerProvider.notifier).resume();
                        } else {
                          ref.read(sessionControllerProvider.notifier).pause();
                        }
                      },
                    ),
                    _ControlButton(
                      icon: profile.voiceOn ? Icons.volume_up : Icons.volume_off,
                      label: l10n.s3Voice,
                      onPressed: () {
                        ref
                            .read(sessionControllerProvider.notifier)
                            .setVoice(!profile.voiceOn);
                      },
                    ),
                    _ControlButton(
                      icon: profile.vibrationOn
                          ? Icons.vibration
                          : Icons.phone_android,
                      label: l10n.s3Vibration,
                      onPressed: () {
                        ref
                            .read(sessionControllerProvider.notifier)
                            .setVibration(!profile.vibrationOn);
                      },
                    ),
                    _ControlButton(
                      icon: Icons.close,
                      label: l10n.s3Exit,
                      onPressed: _confirmExit,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppRadii.mdAll,
        child: SizedBox(
          width: 72,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.sessionText, size: 28),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: AppColors.sessionTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
