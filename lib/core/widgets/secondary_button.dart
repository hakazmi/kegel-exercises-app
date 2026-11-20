import 'package:material_ui/material_ui.dart';

import '../../app/theme/tokens.dart';
import '../motion/app_motion.dart';

/// Outlined secondary CTA with pill radius, 48dp min height, optional icon.
/// Presses scale down slightly.
class SecondaryButton extends StatefulWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.enabled = true,
    this.expand = true,
    this.icon,
    this.color,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool enabled;
  final bool expand;
  final IconData? icon;

  /// Text, icon and border colour override (e.g. a destructive action).
  final Color? color;

  @override
  State<SecondaryButton> createState() => _SecondaryButtonState();
}

class _SecondaryButtonState extends State<SecondaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.enabled && widget.onPressed != null;
    final Color fg = isEnabled
        ? (widget.color ?? AppColors.textPrimary)
        : AppColors.textDisabledLabel;
    final Widget child = AnimatedScale(
      scale: _pressed && !AppMotion.isReduced(context) ? 0.97 : 1,
      duration: const Duration(milliseconds: 120),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppSpacing.minTouchTarget),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadii.pillAll,
            border: Border.all(
              color: isEnabled
                  ? (widget.color ?? AppColors.borderStrong)
                  : AppColors.border,
              width: 1.5,
            ),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: isEnabled ? widget.onPressed : null,
              onHighlightChanged: (bool v) {
                if (mounted && v != _pressed) {
                  setState(() => _pressed = v);
                }
              },
              borderRadius: AppRadii.pillAll,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.sm,
                ),
                child: Center(
                  widthFactor: 1,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, size: 20, color: fg),
                        const SizedBox(width: AppSpacing.xs),
                      ],
                      Flexible(
                        child: Text(
                          widget.label,
                          textAlign: TextAlign.center,
                          style: AppTypography.button.copyWith(color: fg),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (!widget.expand) {
      return child;
    }
    return SizedBox(width: double.infinity, child: child);
  }
}
