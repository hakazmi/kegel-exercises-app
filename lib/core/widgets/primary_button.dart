import 'dart:async';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/theme/tokens.dart';
import '../motion/app_motion.dart';

/// Full-width primary CTA (ink fill, pill radius, 48dp min height).
///
/// Presses scale down slightly with a light haptic. Optional [icon] leads the
/// label, [trailingArrow] adds a nudging arrow, and [shimmer] runs a soft
/// sheen across the fill to draw the eye to the main action.
class PrimaryButton extends StatefulWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.enabled = true,
    this.expand = true,
    this.icon,
    this.trailingArrow = false,
    this.shimmer = false,
    this.color,
    this.foregroundColor,
    this.height = 56,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool enabled;
  final bool expand;
  final IconData? icon;
  final bool trailingArrow;
  final bool shimmer;

  /// Fill override (defaults to ink). Accent fills are used on dark screens.
  final Color? color;
  final Color? foregroundColor;
  final double height;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.enabled && widget.onPressed != null;
    final Color fill = isEnabled
        ? (widget.color ?? AppColors.ink)
        : AppColors.buttonDisabled;
    final Color fg = isEnabled
        ? (widget.foregroundColor ?? AppColors.textOnPrimary)
        : AppColors.textDisabledLabel;
    final bool reduced = AppMotion.isReduced(context);

    final Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
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
        if (widget.trailingArrow) ...[
          const SizedBox(width: AppSpacing.xs),
          if (isEnabled)
            NudgeArrow(color: fg, size: 20)
          else
            Icon(Icons.arrow_forward_rounded, size: 20, color: fg),
        ],
      ],
    );

    Widget button = ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: widget.height < AppSpacing.minTouchTarget
            ? AppSpacing.minTouchTarget
            : widget.height,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: fill,
          borderRadius: AppRadii.pillAll,
          boxShadow: isEnabled
              ? <BoxShadow>[
                  BoxShadow(
                    color: fill.withValues(alpha: 0.28),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ]
              : AppElevation.none,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: isEnabled
                ? () {
                    unawaited(HapticFeedback.lightImpact());
                    widget.onPressed!();
                  }
                : null,
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
              child: Center(widthFactor: 1, child: content),
            ),
          ),
        ),
      ),
    );

    if (widget.shimmer && isEnabled) {
      button = ShimmerSweep(borderRadius: AppRadii.pillAll, child: button);
    }

    button = AnimatedScale(
      scale: _pressed && !reduced ? 0.97 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: button,
    );

    if (!widget.expand) {
      return button;
    }
    return SizedBox(width: double.infinity, child: button);
  }
}
