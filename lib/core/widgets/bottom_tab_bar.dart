import 'package:material_ui/material_ui.dart';

import '../../app/theme/tokens.dart';

/// Bottom navigation destinations for the main shell.
enum AppTab { today, progress, learn }

/// App bottom tab bar: Today, Progress, Learn.
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

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      elevation: 0,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                Expanded(
                  child: _TabItem(
                    selected: current == AppTab.today,
                    icon: Icons.track_changes_outlined,
                    selectedIcon: Icons.track_changes,
                    label: todayLabel,
                    onTap: () => onSelect(AppTab.today),
                  ),
                ),
                Expanded(
                  child: _TabItem(
                    selected: current == AppTab.progress,
                    icon: Icons.bar_chart_outlined,
                    selectedIcon: Icons.bar_chart,
                    label: progressLabel,
                    onTap: () => onSelect(AppTab.progress),
                  ),
                ),
                Expanded(
                  child: _TabItem(
                    selected: current == AppTab.learn,
                    icon: Icons.menu_book_outlined,
                    selectedIcon: Icons.menu_book,
                    label: learnLabel,
                    onTap: () => onSelect(AppTab.learn),
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

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.selected,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = selected ? AppColors.ink : AppColors.textSecondary;
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppSpacing.minTouchTarget),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(selected ? selectedIcon : icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.caption.copyWith(
                color: color,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
