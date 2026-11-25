import 'dart:math' as math;
import 'dart:ui' show FlutterView;

import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/l10n/app_localizations.dart';
import '../../app/router.dart';
import '../../app/theme/system_ui.dart';
import '../../app/theme/tokens.dart';
import '../../core/cloud/cloud_providers.dart';
import '../../core/content/content_models.dart';
import '../../core/content/exercise_media.dart';
import '../../core/data/providers.dart';
import '../../core/domain/enums.dart';
import '../../core/domain/user_profile.dart';
import '../../core/widgets/exercise_video.dart';
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
  const S3PlayerScreen({super.key, this.itemId});

  final String? itemId;

  @override
  ConsumerState<S3PlayerScreen> createState() => _S3PlayerScreenState();
}

class _S3PlayerScreenState extends ConsumerState<S3PlayerScreen>
    with WidgetsBindingObserver {
  String? _lastAnnounced;
  bool _navigating = false;
  void Function(bool)? _setSyncPaused;

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final coordinator = ref.read(syncCoordinatorProvider);
      _setSyncPaused = coordinator.setActivityPaused;
      coordinator.setActivityPaused(true);
      _ensureSession();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _setSyncPaused?.call(false);
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

  /// The window, captured in build for screen-reader announcements.
  FlutterView? _view;

  void _goDone() {
    if (_navigating || !mounted) {
      return;
    }
    _navigating = true;
    // Navigate after the current frame: this runs from a provider listener,
    // which can fire mid-build; changing routes then tears down widgets
    // that are still being built.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.go(
        '${AppRoutes.done}?itemId=${Uri.encodeComponent(widget.itemId ?? 'strength_1')}',
      );
    });
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
    final List<ExerciseContent>? exercises = ref
        .watch(exercisesProvider)
        .asData
        ?.value;
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
    _view = View.of(context);
    final UserProfile profile = ref.watch(userProfileProvider);
    final SessionPlayState? play = ref.watch(sessionControllerProvider);

    ref.listen<SessionPlayState?>(sessionControllerProvider, (
      SessionPlayState? prev,
      SessionPlayState? next,
    ) {
      if (next == null || _navigating) {
        return;
      }
      if (next.summary != null ||
          (next.engineState.completed && !next.engineState.exited)) {
        _goDone();
        return;
      }
      // No context lookups here (this is not a build): use the values
      // captured in the last build.
      final FlutterView? view = _view;
      if (!mounted || view == null) {
        return;
      }
      final String word = SessionPhaseCopy.label(
        l10n,
        next.engineState.phaseWord,
      );
      if (word.isNotEmpty && word != _lastAnnounced) {
        _lastAnnounced = word;
        SemanticsService.sendAnnouncement(view, word, TextDirection.ltr);
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

    // Drop ring/video tickers in a normal rebuild before the route swap.
    // Disposing them during go_router teardown can trip InheritedElement
    // `_dependents.isEmpty` in debug.
    if (_navigating ||
        play.summary != null ||
        (play.engineState.completed && !play.engineState.exited)) {
      return const AnnotatedRegion<SystemUiOverlayStyle>(
        value: AppSystemUi.darkScreen,
        child: Scaffold(
          backgroundColor: AppColors.sessionBackground,
          body: SizedBox.expand(),
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
    final String nextTitle = nextKey == null
        ? l10n.s3NoNextBlock
        : _blockTitle(l10n, nextKey);
    final SessionKind kind = play.definition.kind;
    final bool isBody = kind == SessionKind.body;
    final SessionController controller = ref.read(
      sessionControllerProvider.notifier,
    );
    void togglePause() => paused ? controller.resume() : controller.pause();
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
                    builder: (BuildContext context, BoxConstraints box) {
                      final String exerciseId = ExerciseMedia.idForBlock(
                        es.blockTitleKey,
                      );
                      final String? video = ExerciseMedia.video(exerciseId);
                      final String? poster = ExerciseMedia.poster(exerciseId);
                      // Reverse Kegels move the other way: keep the drawn
                      // ring instead of the squeeze video.
                      final bool reverse = es.blockTitleKey == 'reverseKegel';
                      Widget ringOf(double size) => Semantics(
                        liveRegion: true,
                        label: phaseLabel,
                        child: reverse
                            ? SessionMuscleRing(
                                engineState: es,
                                phaseLabel: phaseLabel,
                                size: size,
                              )
                            : _DemoRing(es: es, size: size, label: phaseLabel),
                      );
                      final String? rep = es.rep != null && es.totalReps != null
                          ? l10n.s3RepOf(es.rep!, es.totalReps!)
                          : null;
                      final String seconds = formatPhaseSecondsRemaining(
                        es.secondsRemaining,
                      );
                      final Widget cue = Text(
                        _cue(l10n, es.elapsedSeconds),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: AppTypography.body.copyWith(
                          color: AppColors.sessionTextSecondary,
                        ),
                      );

                      // With a demo video: the framed video on top, then
                      // the muscle ring and the phase side by side.
                      if (video != null && poster != null) {
                        final double videoW = math.min(
                          box.maxWidth - AppSpacing.xl * 2,
                          460,
                        );
                        final double videoH = videoW * 9 / 16 + 12;
                        final double ringSize =
                            (box.maxHeight - videoH - AppSpacing.md * 4 - 48)
                                .clamp(110.0, 170.0);
                        return SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.xl,
                            AppSpacing.md,
                            AppSpacing.xl,
                            AppSpacing.sm,
                          ),
                          child: Column(
                            children: [
                              _VideoFrame(
                                width: videoW,
                                child: ExerciseVideo(
                                  asset: video,
                                  poster: poster,
                                  radius: AppRadii.lg,
                                  semanticLabel: blockTitle,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Row(
                                children: [
                                  ringOf(ringSize),
                                  const SizedBox(width: AppSpacing.lg),
                                  Expanded(
                                    child: _PhaseStatus(
                                      phase: phaseLabel,
                                      seconds: seconds,
                                      rep: rep,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.md),
                              cue,
                            ],
                          ),
                        );
                      }

                      // Kegel blocks without a video: the big muscle ring.
                      final double ringSize = math.min(
                        260,
                        math.max(150, box.maxHeight * 0.48),
                      );
                      return SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: box.maxHeight),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xl,
                              vertical: AppSpacing.md,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ringOf(ringSize),
                                const SizedBox(height: AppSpacing.lg),
                                _PhaseStatus(
                                  phase: phaseLabel,
                                  seconds: seconds,
                                  rep: rep,
                                  centered: true,
                                ),
                                const SizedBox(height: AppSpacing.md),
                                cue,
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                  ),
                  child: _NowNextCard(
                    now: l10n.s3NowBlock(blockTitle),
                    next: l10n.s3NextBlock(nextTitle),
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
                    forwardLabel: isBody
                        ? l10n.s3ForwardExercise
                        : l10n.s3ForwardPhase,
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
    final EngineMachineState m = paused
        ? (es.pausedFrom ?? EngineMachineState.rest)
        : es.machine;
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

/// Rounded frame with a border around the demo video.
class _VideoFrame extends StatelessWidget {
  const _VideoFrame({required this.width, required this.child});

  final double width;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.xlAll,
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: AppElevation.level2,
      ),
      child: child,
    );
  }
}

/// Phase word, big countdown and the round counter.
class _PhaseStatus extends StatelessWidget {
  const _PhaseStatus({
    required this.phase,
    required this.seconds,
    required this.rep,
    this.centered = false,
  });

  final String phase;
  final String seconds;
  final String? rep;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: centered
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            phase,
            maxLines: 1,
            style: AppTypography.display.copyWith(
              color: AppColors.sessionText,
              fontSize: 34,
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
        ),
        Text(
          seconds,
          style: AppTypography.display.copyWith(
            color: AppColors.primary,
            fontSize: 30,
            fontWeight: FontWeight.w800,
            height: 1.1,
          ),
        ),
        if (rep != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: AppColors.sessionSurface,
              borderRadius: AppRadii.pillAll,
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              rep!,
              style: AppTypography.caption.copyWith(
                color: AppColors.sessionText,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// "Now: … / Next: …" card under the exercise area.
class _NowNextCard extends StatelessWidget {
  const _NowNextCard({required this.now, required this.next});

  final String now;
  final String next;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.sessionSurface,
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.mint,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.play_arrow_rounded,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  now,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body.copyWith(
                    color: AppColors.sessionText,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  next,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.sessionTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
