import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../app/theme/tokens.dart';
import '../motion/app_motion.dart';

/// Bottom navigation destinations for the main shell.
enum AppTab { today, progress, learn }

/// Floating pill tab bar (Today / Progress / Learn).
///
/// A dark pill that floats above the content with nothing painted behind
/// it. The selected tab sits in a white bubble that slides between tabs.
/// It lifts itself above the phone's own navigation (gesture bar or
/// three-button bar) using the system bottom inset, so it never sits under
/// the system buttons. Pair with `Scaffold(extendBody: true)`; the scaffold
/// then reports this bar's full height as bottom padding to the tab body.
class BottomTabBar extends StatelessWidget {
  const BottomTabBar({
    super.key,
    required this.current,
    required this.onSelect,
    required this.todayLabel,
    required this.progressLabel,
    required this.learnLabel,
  });

  final AppTab current;
  final ValueChanged<AppTab> onSelect;
  final String todayLabel;
  final String progressLabel;
  final String learnLabel;

  /// Height of the pill itself.
  static const double pillHeight = 64;

  /// Gap between the pill and the system navigation / screen edge.
  static const double gap = 10;

  static const List<(IconData, IconData)> _icons = <(IconData, IconData)>[
    (Icons.today_outlined, Icons.today_rounded),
    (Icons.insights_outlined, Icons.insights_rounded),
    (Icons.auto_stories_outlined, Icons.auto_stories_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    // viewPadding keeps the real system inset even when an ancestor has
    // already consumed `padding` (e.g. extendBody).
    final double system = math.max(
      MediaQuery.viewPaddingOf(context).bottom,
      MediaQuery.paddingOf(context).bottom,
    );
    final List<String> labels = <String>[todayLabel, progressLabel, learnLabel];
    final int index = AppTab.values.indexOf(current);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        0,
        AppSpacing.xl,
        system + gap,
      ),
      child: Container(
        height: pillHeight,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.ink,
          borderRadius: AppRadii.pillAll,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.ink.withValues(alpha: 0.28),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints box) {
            final double slot = box.maxWidth / labels.length;
            return Stack(
              children: [
                // Sliding white bubble behind the selected tab.
                AnimatedPositioned(
                  duration: AppMotion.isReduced(context)
                      ? Duration.zero
                      : const Duration(milliseconds: 380),
                  curve: Curves.easeOutBack,
                  left: slot * index,
                  top: 0,
                  bottom: 0,
                  width: slot,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadii.pillAll,
                    ),
                  ),
                ),
                Row(
                  children: [
                    for (int i = 0; i < labels.length; i++)
                      Expanded(
                        child: _TabItem(
                          label: labels[i],
                          icon: _icons[i].$1,
                          activeIcon: _icons[i].$2,
                          selected: i == index,
                          onTap: () {
                            if (i != index) {
                              onSelect(AppTab.values[i]);
                            }
                          },
                        ),
                      ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Duration d = AppMotion.isReduced(context)
        ? Duration.zero
        : const Duration(milliseconds: 260);
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Center(
          child: AnimatedSwitcher(
            duration: d,
            transitionBuilder: (Widget child, Animation<double> a) =>
                ScaleTransition(scale: a, child: child),
            child: selected
                ? Row(
                    key: const ValueKey<bool>(true),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(activeIcon, size: 22, color: AppColors.ink),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.ink,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  )
                : Icon(
                    icon,
                    key: const ValueKey<bool>(false),
                    size: 24,
                    color: AppColors.textOnPrimary.withValues(alpha: 0.75),
                  ),
          ),
        ),
      ),
    );
  }
}
