import 'package:material_ui/material_ui.dart';

import '../../app/l10n/app_localizations.dart';
import '../../app/theme/tokens.dart';
import '../../core/widgets/widgets.dart';

/// "Level N unlocked" offer — Start or Stay (never silent).
class LevelUnlockCard extends StatelessWidget {
  const LevelUnlockCard({
    super.key,
    required this.l10n,
    required this.nextLevel,
    required this.onStart,
    required this.onStay,
    this.dark = false,
  });

  final AppLocalizations l10n;
  final int nextLevel;
  final VoidCallback onStart;
  final VoidCallback onStay;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final Color titleColor = dark
        ? AppColors.sessionText
        : AppColors.textPrimary;
    final Color muted = dark
        ? AppColors.sessionTextSecondary
        : AppColors.textSecondary;
    return AppCard(
      backgroundColor: dark ? AppColors.sessionSurface : AppColors.mint,
      borderColor: dark ? AppColors.sessionSurface : AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.h1LevelUnlockedTitle(nextLevel),
            style: AppTypography.title.copyWith(color: titleColor),
          ),
          const SizedBox(height: AppSpacing.md),
          PrimaryButton(
            label: l10n.h1LevelUnlockedStart(nextLevel),
            onPressed: onStart,
          ),
          const SizedBox(height: AppSpacing.xs),
          Center(
            child: TextLinkButton(
              label: l10n.h1LevelUnlockedStay,
              color: muted,
              onPressed: onStay,
            ),
          ),
        ],
      ),
    );
  }
}
