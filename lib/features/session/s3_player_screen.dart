import 'dart:math' as math;

import 'package:flutter/semantics.dart';
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
import '../../core/widgets/pelvic_floor_demo.dart';
import 'engine/engine_models.dart';
import 'session_controller.dart';
import 'session_exit.dart';
import 'session_phase_copy.dart';
import 'session_time_format.dart';
import 'widgets/breathe_player_view.dart';
import 'widgets/player_controls.dart';
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
    if (_navigating) {
      return;
    }
    final bool ok = await confirmSessionExit(context);
    if (!ok || !mounted) {
      return;
    }
    _navigating = true;
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
    }
    // Stretch / movement / strong hold: real exercise name from content.
    // Never collapse child's pose / happy baby / back release to "Stretch".
    final List<ExerciseContent>? exercises =
        ref.watch(exercisesProvider).asData?.value;
    if (exercises != null) {
      for (final ExerciseContent ex in exercises) {
        if (ex.id == key) {
          return ex.name;
        }
      }
    }
    return key;
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
      final String word = SessionPhaseCopy.label(
        AppLocalizations.of(context),
        next.engineState.phaseWord,
      );
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
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, Object? result) {
          if (!didPop) {
            _confirmExit();
          }
        },
        child: const AnnotatedRegion<SystemUiOverlayStyle>(
          value: AppSystemUi.darkScreen,
          child: Scaffold(
            backgroundColor: AppColors.sessionBackground,
            body: Center(child: CircularProgressIndicator()),
          ),
        ),
      );
    }

    final EngineState es = play.engineState;
    final bool paused = es.machine == EngineMachineState.paused;
    final String phaseLabel = SessionPhaseCopy.label(l10n, es.phaseWord);
    final String blockTitle = _blockTitle(l10n, es.blockTitleKey);
    final String header = es.rep != null && es.totalReps != null
        ? l10n.s3BlockRepHeader(blockTitle, es.rep!, es.totalReps!)
        : blockTitle;
    final String? nextKey = es.nextBlockTitleKey;
    final String nextTitle =
        nextKey == null ? l10n.s3NoNextBlock : _blockTitle(l10n, nextKey);
    final SessionKind kind = play.definition.kind;
    final bool isBody = kind == SessionKind.body;
    final SessionController controller =
        ref.read(sessionControllerProvider.notifier);
    void togglePause() =>
        paused ? controller.resume() : controller.pause();
    // Forward: next exercise in body sessions, next phase everywhere else.
    void forward() => isBody ? controller.skipBlock() : controller.skipPhase();

    if (kind == SessionKind.breathing || kind == SessionKind.relaxation) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, Object? result) {
          if (!didPop) {
            _confirmExit();
          }
        },
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: AppSystemUi.darkScreen,
          child: Scaffold(
            backgroundColor: AppColors.sessionBackground,
            body: BreathePlayerView(
              l10n: l10n,
              state: es,
              phaseLabel: phaseLabel,
              blockTitle: blockTitle,
              nextTitle: nextTitle,
              cue: _cue(l10n, es.elapsedSeconds),
              voiceOn: profile.voiceOn,
              onToggleVoice: () => controller.setVoice(!profile.voiceOn),
              onExit: _confirmExit,
              onTogglePause: togglePause,
              onForward: forward,
            ),
          ),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) {
          _confirmExit();
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: AppSystemUi.darkScreen,
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
                    const SizedBox(width: AppSpacing.sm),
                    PlayerToggle(
                      on: profile.voiceOn,
                      onIcon: Icons.volume_up_rounded,
                      offIcon: Icons.volume_off_rounded,
                      label: l10n.s3Voice,
                      onTap: () => controller.setVoice(!profile.voiceOn),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    PlayerToggle(
                      on: profile.vibrationOn,
                      onIcon: Icons.vibration_rounded,
                      offIcon: Icons.mobile_off_rounded,
                      label: l10n.s3Vibration,
                      onTap: () =>
                          controller.setVibration(!profile.vibrationOn),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final double ringSize = math.min(
                      280,
                      math.max(160, constraints.maxHeight * 0.5),
                    );
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Semantics(
                              liveRegion: true,
                              label: phaseLabel,
                              // Reverse Kegels move the other way, so they
                              // keep the drawn ring instead of the squeeze
                              // video.
                              child: es.blockTitleKey == 'reverseKegel'
                                  ? SessionMuscleRing(
                                      engineState: es,
                                      phaseLabel: phaseLabel,
                                      size: ringSize,
                                    )
                                  : _DemoRing(
                                      es: es,
                                      size: ringSize,
                                      label: phaseLabel,
                                    ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Text(
                              phaseLabel,
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
                    );
                  },
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
                child: PlayerControls(
                  paused: paused,
                  onTogglePause: togglePause,
                  onForward: forward,
                  onExit: _confirmExit,
                  pauseLabel: l10n.s3Pause,
                  resumeLabel: l10n.s3Resume,
                  forwardLabel:
                      isBody ? l10n.s3ForwardExercise : l10n.s3ForwardPhase,
                  exitLabel: l10n.s3Exit,
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


/// The 3D pelvic floor video following the engine: it squeezes and lifts
/// on Squeeze, freezes while you Hold, and lowers on Relax, with the phase
/// progress ring around it.
class _DemoRing extends StatelessWidget {
  const _DemoRing({required this.es, required this.size, required this.label});

  final EngineState es;
  final double size;
  final String label;

  @override
  Widget build(BuildContext context) {
    final bool paused = es.machine == EngineMachineState.paused;
    final EngineMachineState m =
        paused ? (es.pausedFrom ?? EngineMachineState.rest) : es.machine;
    final PfPhase phase = switch (m) {
      EngineMachineState.squeeze =>
        es.phaseWord == SessionPhaseKey.hold ? PfPhase.hold : PfPhase.squeeze,
      EngineMachineState.relax => PfPhase.relax,
      _ => PfPhase.rest,
    };
    final Color color = switch (phase) {
      PfPhase.relax => AppColors.phaseRelax,
      PfPhase.rest => AppColors.phaseRest,
      _ => AppColors.phaseSqueezeHold,
    };
    // Squeeze briskly (well under the phase length), relax more slowly.
    final int left = math.max(es.secondsRemaining, 1) * 1000;
    final Duration motion = Duration(
      milliseconds: phase == PfPhase.relax
          ? (left * 0.7).round().clamp(800, 3000)
          : (left * 0.4).round().clamp(800, 1500),
    );
    return PelvicFloorRing(
      phase: phase,
      progress: m == EngineMachineState.done ? 1 : es.phaseProgress,
      color: color,
      size: size,
      motion: motion,
      cycle: es.blockIndex * 1000 + (es.rep ?? 0),
      paused: paused,
      semanticLabel: label,
    );
  }
}
