import 'package:material_ui/material_ui.dart';

import '../../app/theme/tokens.dart';
import '../motion/app_motion.dart';
import 'info_sheet.dart';

/// Multi-select row with an animated square check.
///
/// [accent] tints the selected state (green by default; safety answers use
/// the warning palette). Optional [leading] icon and [info] button.
class MultiSelectCard extends StatelessWidget {
  const MultiSelectCard({
    super.key,
    required this.title,
    required this.selected,
    required this.onChanged,
    this.subtitle,
    this.leading,
    this.info,
    this.accent = AppColors.primary,
    this.selectedBackground = AppColors.mint,
    this.iconBackground,
    this.iconForeground,
  });

  final String title;
  final String? subtitle;
  final bool selected;
  final ValueChanged<bool> onChanged;
  final IconData? leading;
  final InfoContent? info;
  final Color accent;
  final Color selectedBackground;
  final Color? iconBackground;
  final Color? iconForeground;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: selected,
      child: PressScale(
        onTap: () => onChanged(!selected),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
          constraints: const BoxConstraints(minHeight: AppSpacing.minTouchTarget),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 2,
          ),
          decoration: BoxDecoration(
            color: selected ? selectedBackground : AppColors.surface,
            borderRadius: AppRadii.lgAll,
            border: Border.all(
              color: selected ? accent : AppColors.border,
              width: selected ? 2 : 1,
            ),
            boxShadow: AppElevation.level1,
          ),
          child: Row(
            children: [
              if (leading != null) ...[
                AnimatedContainer(
                  duration: AppMotion.quick,
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconBackground ??
                        (selected ? AppColors.surface : AppColors.surfaceMuted),
                    borderRadius: AppRadii.mdAll,
                  ),
                  child: Icon(
                    leading,
                    size: 20,
                    color: iconForeground ??
                        (selected ? accent : AppColors.textSecondary),
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
              _CheckBox(selected: selected, color: accent),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckBox extends StatelessWidget {
  const _CheckBox({required this.selected, required this.color});

  final bool selected;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: selected ? color : Colors.transparent,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: selected ? color : AppColors.border,
          width: 2,
        ),
      ),
      child: AnimatedScale(
        scale: selected ? 1 : 0,
        duration: const Duration(milliseconds: 260),
        curve: AppMotion.dropCurve,
        child: const Icon(
          Icons.check_rounded,
          size: 16,
          color: AppColors.textOnPrimary,
        ),
      ),
    );
  }
}
