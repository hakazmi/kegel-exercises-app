import 'package:material_ui/material_ui.dart';

import '../../../app/theme/tokens.dart';
import '../../../core/motion/app_motion.dart';

/// Floating icon badge at the top of an onboarding step, with a soft halo.
class ScreenBadge extends StatelessWidget {
  const ScreenBadge({
    super.key,
    required this.icon,
    this.background = AppColors.mint,
    this.foreground = AppColors.primary,
    this.trailing,
  });

  final IconData icon;
  final Color background;
  final Color foreground;

  /// Optional widget on the right of the row (e.g. an info button).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        PulseHalo(
          color: foreground.withValues(alpha: 0.5),
          size: 56,
          child: FloatBob(
            lift: 3,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: background,
                borderRadius: AppRadii.lgAll,
                boxShadow: AppElevation.level1,
              ),
              child: Icon(icon, color: foreground, size: 28),
            ),
          ),
        ),
        const Spacer(),
        ?trailing,
      ],
    );
  }
}
