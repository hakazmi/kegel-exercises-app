import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:video_player/video_player.dart';

import '../../app/theme/tokens.dart';
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
  VideoPlayerController? _c;
  bool _ready = false;
  bool _started = false;

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
    final VideoPlayerController c = VideoPlayerController.asset(asset);
    _c = c;
    _ready = false;
    if (mounted) {
      setState(() {});
    }
    // Dispose the old clip only once the new frame no longer shows it.
    if (old != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
    }
    try {
      await c.initialize();
      await c.setVolume(0);
      await c.setLooping(widget.looping);
      if (!mounted || _c != c) {
        return;
      }
      await c.play();
      if (!mounted || _c != c) {
        return;
      }
      setState(() => _ready = true);
    } on Object catch (error) {
      debugPrint('Exercise video unavailable ($asset): $error');
    }
  }

  @override
  void dispose() {
    final VideoPlayerController? c = _c;
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
