import 'package:material_ui/material_ui.dart';

import '../../../app/theme/tokens.dart';
import '../../../core/widgets/progress_header.dart';

/// Shared chrome for O1–O6: progress header and scrollable body.
class OnboardingScaffold extends StatelessWidget {
  const OnboardingScaffold({
    super.key,
    required this.step,
    required this.onBack,
    required this.body,
    this.pinnedPanel,
    this.pinnedAboveFooter,
    this.footer,
    this.showHeader = true,
    this.fadeListBottom = false,
    this.listMinExtent = 0,
  });

  final int step;
  final VoidCallback? onBack;
  final Widget body;

  /// Optional fixed panel between the scrolling body and [footer] (e.g. O3).
  final Widget? pinnedPanel;

  /// Fixed row between [pinnedPanel] and [footer] (e.g. surgery confirm).
  final Widget? pinnedAboveFooter;
  final Widget? footer;
  final bool showHeader;

  /// Soft fade at the bottom edge of the scrolling list.
  final bool fadeListBottom;

  /// Minimum height reserved for the scrolling list when [pinnedPanel] is set.
  final double listMinExtent;

  @override
  Widget build(BuildContext context) {
    final bool splitBody = pinnedPanel != null || listMinExtent > 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            if (showHeader)
              ProgressHeader(
                step: step,
                total: 6,
                onBack: onBack,
              ),
            Expanded(
              child: splitBody
                  ? LayoutBuilder(
                      builder: (BuildContext context, BoxConstraints constraints) {
                        final double panelCap =
                            MediaQuery.sizeOf(context).height * 0.4;
                        final double panelMax = (constraints.maxHeight -
                                listMinExtent)
                            .clamp(0.0, panelCap);
                        return Column(
                          children: [
                            Expanded(
                              child: _ScrollingBody(
                                fadeBottom: fadeListBottom,
                                child: body,
                              ),
                            ),
                            if (pinnedPanel != null)
                              ConstrainedBox(
                                constraints: BoxConstraints(maxHeight: panelMax),
                                child: pinnedPanel!,
                              ),
                          ],
                        );
                      },
                    )
                  : _ScrollingBody(
                      fadeBottom: fadeListBottom,
                      child: body,
                    ),
            ),
            ?pinnedAboveFooter,
            if (footer != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.md,
                  AppSpacing.xl,
                  AppSpacing.md,
                ),
                child: footer,
              ),
          ],
        ),
      ),
    );
  }
}

class _ScrollingBody extends StatelessWidget {
  const _ScrollingBody({
    required this.child,
    required this.fadeBottom,
  });

  final Widget child;
  final bool fadeBottom;

  @override
  Widget build(BuildContext context) {
    final Widget list = ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.sm,
        AppSpacing.xl,
        AppSpacing.md,
      ),
      children: [child],
    );

    if (!fadeBottom) {
      return list;
    }

    return Stack(
      children: [
        list,
        const Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 28,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Color(0x00F5F7F6),
                    AppColors.background,
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
