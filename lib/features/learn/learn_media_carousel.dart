import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../app/theme/tokens.dart';
import '../../core/content/content_models.dart';
import '../../core/motion/app_motion.dart';
import '../../core/widgets/widgets.dart';

/// Auto-advancing Learn media strip: videos loop, stills/GIFs cross-fade
/// to the next item like an animated panel.
class LearnMediaCarousel extends StatefulWidget {
  const LearnMediaCarousel({
    super.key,
    required this.media,
    this.aspectRatio = 16 / 9,
    this.showCaption = true,
    this.showDots = true,
    this.autoAdvance = true,
    this.interval = const Duration(milliseconds: 2800),
    this.borderRadius = AppRadii.xlAll,
    this.fitStill = BoxFit.cover,
    this.onPageChanged,
  });

  final List<ArticleMedia> media;
  final double aspectRatio;
  final bool showCaption;
  final bool showDots;
  final bool autoAdvance;
  final Duration interval;
  final BorderRadius borderRadius;
  final BoxFit fitStill;
  final ValueChanged<int>? onPageChanged;

  @override
  State<LearnMediaCarousel> createState() => _LearnMediaCarouselState();
}

class _LearnMediaCarouselState extends State<LearnMediaCarousel> {
  late final PageController _page = PageController();
  Timer? _timer;
  int _index = 0;

  @override
  void didUpdateWidget(covariant LearnMediaCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.media != widget.media ||
        oldWidget.autoAdvance != widget.autoAdvance ||
        oldWidget.interval != widget.interval) {
      _armTimer();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // MediaQuery (via AppMotion.isReduced) is only safe after initState.
    _armTimer();
  }

  void _armTimer() {
    _timer?.cancel();
    _timer = null;
    if (!widget.autoAdvance ||
        widget.media.length < 2 ||
        AppMotion.isReduced(context)) {
      return;
    }
    _timer = Timer.periodic(widget.interval, (_) {
      if (!mounted || !_page.hasClients) {
        return;
      }
      final int next = (_index + 1) % widget.media.length;
      _page.animateToPage(
        next,
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.media.isEmpty) {
      return const SizedBox.shrink();
    }
    final ArticleMedia current =
        widget.media[_index.clamp(0, widget.media.length - 1)];
    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: AspectRatio(
        aspectRatio: widget.aspectRatio,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(
              color: AppColors.sessionBackground,
              child: PageView.builder(
                controller: _page,
                itemCount: widget.media.length,
                onPageChanged: (int i) {
                  setState(() => _index = i);
                  widget.onPageChanged?.call(i);
                  _armTimer();
                },
                itemBuilder: (BuildContext context, int i) {
                  final ArticleMedia item = widget.media[i];
                  if (item.isVideo) {
                    return ExerciseVideo(
                      asset: item.video!,
                      poster: item.poster,
                      radius: 0,
                      semanticLabel: item.caption,
                    );
                  }
                  return Image.asset(
                    item.poster,
                    fit: widget.fitStill,
                    gaplessPlayback: true,
                    semanticLabel: item.caption,
                  );
                },
              ),
            ),
            const IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[Color(0x00000000), Color(0x660B1A12)],
                    stops: <double>[0.55, 1],
                  ),
                ),
              ),
            ),
            if (widget.showCaption)
              Positioned(
                left: AppSpacing.sm,
                right: AppSpacing.sm,
                bottom: widget.showDots && widget.media.length > 1
                    ? AppSpacing.lg + 4
                    : AppSpacing.sm,
                child: _Caption(text: current.caption),
              ),
            if (widget.showDots && widget.media.length > 1)
              Positioned(
                left: 0,
                right: 0,
                bottom: AppSpacing.sm,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int i = 0; i < widget.media.length; i++) ...[
                      if (i > 0) const SizedBox(width: 5),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        width: i == _index ? 16 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: i == _index
                              ? AppColors.surface
                              : AppColors.surface.withValues(alpha: 0.45),
                          borderRadius: AppRadii.pillAll,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Caption extends StatelessWidget {
  const _Caption({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs + 2,
        ),
        decoration: const BoxDecoration(
          color: Color(0xB30B1A12),
          borderRadius: AppRadii.pillAll,
        ),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.caption.copyWith(
            color: AppColors.textOnPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
