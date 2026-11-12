import 'package:material_ui/material_ui.dart';

import '../../app/theme/tokens.dart';

/// Coloured icon chip with a large value and supporting label.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    this.iconBackground = AppColors.mint,
    this.iconForeground = AppColors.primary,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color iconBackground;
  final Color iconForeground;

  @override
  Widget build(BuildContext context) {
    return AppSizedStat(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: AppRadii.mdAll,
            ),
            child: Icon(icon, color: iconForeground),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: AppTypography.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: AppTypography.caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Ensures the tile meets the minimum touch height without forcing a fixed height.
class AppSizedStat extends StatelessWidget {
  const AppSizedStat({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppSpacing.minTouchTarget),
      child: child,
    );
  }
}
