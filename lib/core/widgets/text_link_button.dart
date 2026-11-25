import 'package:material_ui/material_ui.dart';

import '../../app/theme/tokens.dart';

/// Text-only link button with a 48dp minimum touch target.
class TextLinkButton extends StatelessWidget {
  const TextLinkButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = AppColors.primary,
    this.underline = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final bool underline;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppSpacing.minTouchTarget),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: color,
          minimumSize: const Size(
            AppSpacing.minTouchTarget,
            AppSpacing.minTouchTarget,
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTypography.body.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
            decoration: underline
                ? TextDecoration.underline
                : TextDecoration.none,
          ),
        ),
      ),
    );
  }
}
