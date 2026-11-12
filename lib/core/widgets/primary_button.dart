import 'package:material_ui/material_ui.dart';

import '../../app/theme/tokens.dart';

/// Full-width primary CTA (ink fill, pill radius, 48dp min height).
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.enabled = true,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool enabled;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = enabled && onPressed != null;
    final Widget child = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppSpacing.minTouchTarget),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isEnabled ? AppColors.ink : AppColors.buttonDisabled,
          borderRadius: AppRadii.pillAll,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: isEnabled ? onPressed : null,
            borderRadius: AppRadii.pillAll,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.sm,
              ),
              child: Center(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: AppTypography.button.copyWith(
                    color: isEnabled
                        ? AppColors.textOnPrimary
                        : AppColors.textDisabledLabel,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (!expand) {
      return child;
    }
    return SizedBox(width: double.infinity, child: child);
  }
}
