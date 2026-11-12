import 'package:material_ui/material_ui.dart';

import '../../app/theme/tokens.dart';

/// White surface card with optional border and padding.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.borderColor,
    this.backgroundColor = AppColors.surface,
    this.elevation = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? borderColor;
  final Color backgroundColor;
  final bool elevation;

  @override
  Widget build(BuildContext context) {
    final Widget content = DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: borderColor ?? AppColors.border),
        boxShadow: elevation ? AppElevation.level1 : AppElevation.none,
      ),
      child: Padding(padding: padding, child: child),
    );

    if (onTap == null) {
      return content;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.lgAll,
        child: content,
      ),
    );
  }
}
