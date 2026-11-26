import 'dart:async';

import 'package:firebase_performance/firebase_performance.dart';
import 'package:material_ui/material_ui.dart';
import 'package:video_player/video_player.dart';

import '../../app/theme/tokens.dart';
import '../diagnostics/crash_reporting.dart';
import '../diagnostics/performance_traces.dart';
import '../motion/app_motion.dart';

/// Looping, muted demo video from an asset, shown in a rounded 16:9 card.
///
/// Shows the [poster] still instead when motion is reduced, in tests, or if
/// the video cannot play. Changing [asset] swaps to the new clip.
class ExerciseVideo extends StatefulWidget {
  const ExerciseVideo({
    super.key,
    required this.asset,
    required this.poster,
    this.aspectRatio = 16 / 9,
    this.radius = AppRadii.xl,
    this.looping = true,
    this.semanticLabel,
  });

  final String asset;
  final String poster;
  final double aspectRatio;
  final double radius;
  final bool looping;
  final String? semanticLabel;

  @override
  State<ExerciseVideo> createState() => _ExerciseVideoState();
}

class _ExerciseVideoState extends State<ExerciseVideo> {
  /// How often playback is checked for a frozen position.
  static const Duration _watchEvery = Duration(seconds: 2);

  VideoPlayerController? _c;
  bool _ready = false;
  bool _started = false;
  Timer? _watchdog;
  Duration _lastPosition = Duration.zero;
  int _stalledChecks = 0;
  int _restarts = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started && !AppMotion.isReduced(context)) {
      _started = true;
      unawaited(_load(widget.asset));
    }
  }

  @override
  void didUpdateWidget(covariant ExerciseVideo old) {
    super.didUpdateWidget(old);
    if (old.asset != widget.asset && _started) {
      unawaited(_load(widget.asset));
    }
  }

  Future<void> _load(String asset) async {
    final VideoPlayerController? old = _c;
    // Muted clips must not take audio focus: otherwise a voice cue or
    // another app (seen on Xiaomi phones) makes the player pause for good.
    final VideoPlayerController c = VideoPlayerController.asset(
      asset,
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
    _c = c;
    _ready = false;
    _stopWatchdog();
    _restarts = 0;
    if (mounted) {
      setState(() {});
    }
    // Dispose the old clip only once the new frame no longer shows it.
    if (old != null) {
      old.removeListener(_onValue);
      WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
    }
    final String basename = asset.contains('/')
        ? asset.substring(asset.lastIndexOf('/') + 1)
        : asset;
    final Trace? videoTrace = PerfTraces.start('video_init');
    PerfTraces.putAttribute(videoTrace, 'asset', basename);
    CrashReporting.log('video: init start $basename');
    try {
      await c.initialize();
      await c.setVolume(0);
      await c.setLooping(widget.looping);
      if (!mounted || _c != c) {
        PerfTraces.abandon(videoTrace);
        return;
      }
      await c.play();
      if (!mounted || _c != c) {
        PerfTraces.abandon(videoTrace);
        return;
      }
      c.addListener(_onValue);
      setState(() => _ready = true);
      _startWatchdog();
      PerfTraces.putMetric(videoTrace, 'ok', 1);
      await PerfTraces.stop(videoTrace);
      CrashReporting.log('video: ready $basename');
    } on Object catch (error, st) {
      PerfTraces.putMetric(videoTrace, 'ok', 0);
      await PerfTraces.stop(videoTrace);
      CrashReporting.log('video: error $basename');
      unawaited(CrashReporting.record(error, stackTrace: st));
      debugPrint('Exercise video unavailable ($asset): $error');
    }
  }

  /// Falls back to the poster on errors and resumes a looping clip that the
  /// system paused from outside (audio focus, decoder reset).
  void _onValue() {
    final VideoPlayerController? c = _c;
    if (c == null || !mounted || !_ready) {
      return;
    }
    final VideoPlayerValue v = c.value;
    if (!v.hasError && !_inForeground) {
      return;
    }
    if (v.hasError) {
      debugPrint('Exercise video error: ${v.errorDescription}');
      CrashReporting.log('video: playback error');
      unawaited(
        CrashReporting.record(
          StateError(v.errorDescription ?? 'video playback error'),
        ),
      );
      _fallBackToPoster();
      return;
    }
    final bool ended = !widget.looping && v.position >= v.duration;
    if (!v.isPlaying && !v.isBuffering && !ended) {
      unawaited(c.play());
    }
  }

  bool get _inForeground =>
      WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;

  void _startWatchdog() {
    _lastPosition = Duration.zero;
    _stalledChecks = 0;
    _watchdog = Timer.periodic(_watchEvery, (_) => _checkStall());
  }

  void _stopWatchdog() {
    _watchdog?.cancel();
    _watchdog = null;
  }

  /// A clip whose position stops moving for two checks is restarted once;
  /// if it freezes again the poster stays instead of a stuck frame.
  void _checkStall() {
    final VideoPlayerController? c = _c;
    if (c == null || !mounted || !_ready) {
      return;
    }
    final VideoPlayerValue v = c.value;
    final bool ended = !widget.looping && v.position >= v.duration;
    if (ended || !_inForeground || !TickerMode.valuesOf(context).enabled) {
      _stalledChecks = 0;
      return;
    }
    if (v.position != _lastPosition) {
      _lastPosition = v.position;
      _stalledChecks = 0;
      return;
    }
    _stalledChecks++;
    if (_stalledChecks < 2) {
      return;
    }
    _stalledChecks = 0;
    if (_restarts >= 1) {
      _fallBackToPoster();
      return;
    }
    _restarts++;
    unawaited(_restart(c));
  }

  Future<void> _restart(VideoPlayerController c) async {
    try {
      await c.seekTo(Duration.zero);
      await c.play();
    } on Object catch (error) {
      debugPrint('Exercise video restart failed: $error');
      _fallBackToPoster();
    }
  }

  void _fallBackToPoster() {
    _stopWatchdog();
    final VideoPlayerController? c = _c;
    if (c != null) {
      c.removeListener(_onValue);
      unawaited(c.pause().catchError((Object _) {}));
    }
    if (mounted && _ready) {
      setState(() => _ready = false);
    }
  }

  @override
  void dispose() {
    _stopWatchdog();
    final VideoPlayerController? c = _c;
    c?.removeListener(_onValue);
    _c = null;
    // Let VideoPlayer detach from the tree before disposing the controller.
    if (c != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        c.dispose();
      });
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final VideoPlayerController? c = _c;
    return Semantics(
      image: true,
      label: widget.semanticLabel,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.radius),
        child: AspectRatio(
          aspectRatio: widget.aspectRatio,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                widget.poster,
                fit: BoxFit.cover,
                gaplessPlayback: true,
                excludeFromSemantics: true,
              ),
              if (_ready && c != null)
                FittedBox(
                  fit: BoxFit.cover,
                  clipBehavior: Clip.hardEdge,
                  child: SizedBox(
                    width: c.value.size.width,
                    height: c.value.size.height,
                    child: VideoPlayer(c),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
