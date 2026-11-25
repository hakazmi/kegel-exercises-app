import 'dart:async';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/l10n/app_localizations.dart';
import '../../app/theme/tokens.dart';
import '../motion/app_motion.dart';
import 'primary_button.dart';

/// Content shown by [InfoButton] in a bottom sheet.
class InfoContent {
  const InfoContent({
    required this.title,
    required this.body,
    this.points = const <String>[],
    this.icon = Icons.info_outline_rounded,
    this.iconBackground = AppColors.mint,
    this.iconForeground = AppColors.primary,
    this.note,
  });

  final String title;
  final String body;

  /// Short bulleted steps or tips, shown with check marks.
  final List<String> points;
  final IconData icon;
  final Color iconBackground;
  final Color iconForeground;

  /// Small safety or source note under the points.
  final String? note;
}

/// Small "i" button that explains something in a bottom sheet.
///
/// 48 dp touch target around a 28 dp visual. Use [dark] on session screens.
class InfoButton extends StatelessWidget {
  const InfoButton({
    super.key,
    required this.content,
    this.dark = false,
    this.size = 28,
    this.compact = false,
  });

  final InfoContent content;
  final bool dark;
  final double size;

  /// Lays out at the icon's size (next to text) while keeping the full
  /// 48 dp touch target overflowing around it.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final Widget button = _button(context);
    if (!compact) {
      return button;
    }
    return SizedBox(
      width: size + 8,
      height: size,
      child: OverflowBox(
        maxWidth: AppSpacing.minTouchTarget,
        maxHeight: AppSpacing.minTouchTarget,
        child: button,
      ),
    );
  }

  Widget _button(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Semantics(
      button: true,
      label: l10n.infoButtonLabel(content.title),
      child: InkResponse(
        onTap: () => InfoSheet.show(context, content),
        radius: 24,
        child: SizedBox(
          width: AppSpacing.minTouchTarget,
          height: AppSpacing.minTouchTarget,
          child: Center(
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dark
                    ? AppColors.sessionText.withValues(alpha: 0.08)
                    : AppColors.surfaceMuted,
              ),
              child: Icon(
                Icons.info_outline_rounded,
                size: size * 0.64,
                color: dark
                    ? AppColors.sessionTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet that explains one thing: icon, title, body, steps, note.
abstract final class InfoSheet {
  static Future<void> show(BuildContext context, InfoContent content) {
    unawaited(HapticFeedback.selectionClick());
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
      ),
      builder: (BuildContext ctx) => _InfoSheetBody(content: content),
    );
  }
}

class _InfoSheetBody extends StatelessWidget {
  const _InfoSheetBody({required this.content});

  final InfoContent content;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final double maxHeight = MediaQuery.sizeOf(context).height * 0.85;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: AppColors.border,
                    borderRadius: AppRadii.pillAll,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Reveal(
                from: RevealFrom.drop,
                child: Row(
                  children: [
                    FloatBob(
                      lift: 3,
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: content.iconBackground,
                          borderRadius: AppRadii.lgAll,
                        ),
                        child: Icon(
                          content.icon,
                          color: content.iconForeground,
                          size: 26,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(content.title, style: AppTypography.title),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Reveal(
                from: RevealFrom.left,
                delay: const Duration(milliseconds: 80),
                child: Text(content.body, style: AppTypography.body),
              ),
              if (content.points.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                for (int i = 0; i < content.points.length; i++)
                  Reveal(
                    from: RevealFrom.right,
                    delay: AppMotion.stagger(
                      i,
                      base: const Duration(milliseconds: 140),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            margin: const EdgeInsets.only(top: 1),
                            decoration: const BoxDecoration(
                              color: AppColors.mint,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              size: 14,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              content.points[i],
                              style: AppTypography.body,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
              if (content.note != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: AppRadii.mdAll,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.shield_outlined,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          content.note!,
                          style: AppTypography.caption,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                label: l10n.infoGotIt,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
