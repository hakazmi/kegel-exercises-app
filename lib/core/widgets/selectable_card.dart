import 'package:material_ui/material_ui.dart';

import '../../app/theme/tokens.dart';
import '../motion/app_motion.dart';
import 'info_sheet.dart';

/// Single-select row: optional icon chip, title, subtitle, check indicator.
///
/// Presses scale down; selecting tints the card, bounces the icon chip and
/// draws a check. An optional [info] adds an "i" button.
class SelectableCard extends StatelessWidget {
  const SelectableCard({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
    this.subtitle,
    this.leading,
    this.iconBackground,
    this.iconForeground,
    this.info,
  });

  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;
  final Widget? leading;
  final Color? iconBackground;
  final Color? iconForeground;
  final InfoContent? info;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: PressScale(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
          constraints: const BoxConstraints(minHeight: AppSpacing.minTouchTarget),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 2,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadii.lgAll,
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 2 : 1,
            ),
            boxShadow: AppElevation.level1,
          ),
          child: Row(
            children: [
              if (leading != null) ...[
                AnimatedScale(
                  scale: selected ? 1.08 : 1,
                  duration: const Duration(milliseconds: 320),
                  curve: AppMotion.dropCurve,
                  child: _IconChip(
                    background: selected
                        ? AppColors.surface
                        : (iconBackground ?? AppColors.mint),
                    foreground: iconForeground ?? AppColors.primary,
                    child: leading!,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.body
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      Text(subtitle!, style: AppTypography.caption),
                    ],
                  ],
                ),
              ),
              if (info != null) InfoButton(content: info!, size: 26),
              const SizedBox(width: AppSpacing.xs),
              _CheckDot(selected: selected),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconChip extends StatelessWidget {
  const _IconChip({
    required this.background,
    required this.foreground,
    required this.child,
  });

  final Color background;
  final Color foreground;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppMotion.quick,
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadii.mdAll,
      ),
      alignment: Alignment.center,
      child: IconTheme(
        data: IconThemeData(color: foreground, size: 22),
        child: child,
      ),
    );
  }
}

/// Empty ring, or a check that draws itself when selected.
class _CheckDot extends StatelessWidget {
  const _CheckDot({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      transitionBuilder: (Widget child, Animation<double> a) =>
          ScaleTransition(scale: a, child: child),
      child: selected
          ? const AnimatedCheckBadge(
              key: ValueKey<String>('on'),
              size: 24,
              color: AppColors.primary,
              checkColor: AppColors.textOnPrimary,
              strokeWidth: 2.4,
            )
          : Container(
              key: const ValueKey<String>('off'),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border, width: 2),
              ),
            ),
    );
  }
}
