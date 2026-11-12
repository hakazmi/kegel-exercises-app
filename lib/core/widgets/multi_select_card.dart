import 'package:material_ui/material_ui.dart';

import '../../app/theme/tokens.dart';

/// Multi-select row with checkbox affordance.
class MultiSelectCard extends StatelessWidget {
  const MultiSelectCard({
    super.key,
    required this.title,
    required this.selected,
    required this.onChanged,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final bool selected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: AppRadii.lgAll,
      child: InkWell(
        onTap: () => onChanged(!selected),
        borderRadius: AppRadii.lgAll,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSpacing.minTouchTarget),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: AppRadii.lgAll,
              border: Border.all(
                color: selected ? AppColors.borderStrong : AppColors.border,
                width: selected ? 2 : 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTypography.body.copyWith(fontWeight: FontWeight.w700),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: AppSpacing.xxs),
                          Text(subtitle!, style: AppTypography.caption),
                        ],
                      ],
                    ),
                  ),
                  Checkbox(
                    value: selected,
                    onChanged: (bool? value) => onChanged(value ?? false),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
