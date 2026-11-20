import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/l10n/app_localizations.dart';
import '../../app/router.dart';
import '../../app/theme/tokens.dart';
import '../../core/content/info_copy.dart';
import '../../core/motion/app_motion.dart';
import '../../core/widgets/widgets.dart';
import 'onboarding_controller.dart';
import 'onboarding_state.dart';
import 'widgets/onboarding_stage.dart';
import 'widgets/onboarding_scaffold.dart';

/// O3 Safety check — multi-select with pain / catheter / surgery routing.
class O3SafetyScreen extends ConsumerWidget {
  const O3SafetyScreen({super.key});

  /// Estimated MultiSelectCard height on a 360-wide phone (padding + wrapped title).
  @visibleForTesting
  static const double optionRowExtent = 101;

  /// List viewport must fit three option rows plus the gaps between them.
  @visibleForTesting
  static const double minOptionsListExtent =
      optionRowExtent * 3 + AppSpacing.xs * 2;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final OnboardingDraft draft = ref.watch(onboardingControllerProvider);
    final OnboardingController controller =
        ref.read(onboardingControllerProvider.notifier);

    // Catheter overrides surgery confirmation for enabling the button.
    final bool canContinue = draft.safetySelectionValid &&
        (draft.catheter || !draft.recentSurgery || draft.surgeryConfirmed);

    final bool showPanel = draft.catheter ||
        (!draft.catheter && (draft.hasPain || draft.recentSurgery));

    final bool showSurgeryConfirm =
        draft.recentSurgery && !draft.catheter;

    final List<_SafetyOption> options = <_SafetyOption>[
      _SafetyOption(
        title: l10n.o3Pain,
        icon: Icons.accessibility_new_rounded,
        selected: draft.pain,
        iconBackground: AppColors.streakBg,
        iconForeground: AppColors.streakFg,
        onChanged: (bool v) => controller.toggleSafety(pain: v),
      ),
      _SafetyOption(
        title: l10n.o3PainSexual,
        icon: Icons.male_rounded,
        selected: draft.painSexual,
        iconBackground: AppColors.goalBladderBg,
        iconForeground: AppColors.goalBladderFg,
        onChanged: (bool v) => controller.toggleSafety(painSexual: v),
      ),
      _SafetyOption(
        title: l10n.o3Surgery,
        icon: Icons.medical_services_outlined,
        selected: draft.recentSurgery,
        iconBackground: AppColors.goalEjaculationBg,
        iconForeground: AppColors.goalEjaculationFg,
        onChanged: (bool v) => controller.toggleSafety(recentSurgery: v),
      ),
      _SafetyOption(
        title: l10n.o3Catheter,
        icon: Icons.water_drop_outlined,
        selected: draft.catheter,
        iconBackground: AppColors.goalErectionBg,
        iconForeground: AppColors.goalErectionFg,
        onChanged: (bool v) => controller.toggleSafety(catheter: v),
      ),
    ];

    return OnboardingScaffold(
      step: 3,
      onBack: () => context.go(AppRoutes.goal),
      fadeListBottom: true,
      listMinExtent: minOptionsListExtent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Reveal(
            from: RevealFrom.drop,
            child: Stack(
              children: [
                SafetyScene(semanticLabel: l10n.o3HeroSemantic),
                Positioned(
                  top: AppSpacing.xs,
                  right: AppSpacing.xs,
                  child: InfoButton(content: InfoCopy.safetyWhy(l10n)),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Reveal(
            from: RevealFrom.left,
            delay: const Duration(milliseconds: 60),
            child: Text(l10n.o3Title, style: AppTypography.display),
          ),
          const SizedBox(height: AppSpacing.xs),
          Reveal(
            from: RevealFrom.left,
            delay: const Duration(milliseconds: 110),
            child: Text(
              l10n.o3Subtitle,
              style: AppTypography.body.copyWith(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final (int i, _SafetyOption option) in options.indexed) ...[
            Reveal(
              from: i.isEven ? RevealFrom.left : RevealFrom.right,
              delay: AppMotion.stagger(
                i,
                base: const Duration(milliseconds: 160),
              ),
              child: MultiSelectCard(
                title: option.title,
                leading: option.icon,
                selected: option.selected,
                accent: AppColors.primary,
                selectedBackground: AppColors.mint,
                iconBackground: option.iconBackground,
                iconForeground: option.iconForeground,
                onChanged: option.onChanged,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
          Reveal(
            from: RevealFrom.rise,
            delay: AppMotion.stagger(
              4,
              base: const Duration(milliseconds: 160),
            ),
            child: MultiSelectCard(
              title: l10n.o3None,
              leading: Icons.not_interested_rounded,
              selected: draft.noneOfThese,
              accent: AppColors.goalErectionFg,
              selectedBackground: AppColors.goalErectionBg,
              iconBackground: AppColors.goalErectionBg,
              iconForeground: AppColors.goalErectionFg,
              onChanged: (bool value) {
                if (value) {
                  controller.toggleSafety(noneOfThese: true);
                }
              },
            ),
          ),
        ],
      ),
      pinnedPanel: showPanel
          ? _SafetyMessagePanel(draft: draft, l10n: l10n)
          : null,
      pinnedAboveFooter: showSurgeryConfirm
          ? Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                0,
                AppSpacing.xl,
                0,
              ),
              child: _SurgeryConfirmRow(
                label: l10n.o3SurgeryUnderstand,
                selected: draft.surgeryConfirmed,
                onChanged: controller.setSurgeryConfirmed,
                foreground: AppColors.streakFg,
              ),
            )
          : null,
      footer: PrimaryButton(
        label: draft.catheter ? l10n.o3ContinueBlocked : l10n.commonNext,
        trailingArrow: canContinue && !draft.catheter,
        enabled: canContinue,
        onPressed: !canContinue
            ? null
            : () async {
                await controller.completeStep('O3');
                if (!context.mounted) {
                  return;
                }
                if (draft.catheter) {
                  await controller.finish(reminderOn: false, catheterExit: true);
                  if (context.mounted) {
                    context.go(AppRoutes.today);
                  }
                  return;
                }
                context.go(AppRoutes.experience);
              },
      ),
    );
  }
}

class _SafetyOption {
  const _SafetyOption({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onChanged,
    required this.iconBackground,
    required this.iconForeground,
  });

  final String title;
  final IconData icon;
  final bool selected;
  final ValueChanged<bool> onChanged;
  final Color iconBackground;
  final Color iconForeground;
}

/// Pinned safety messages between the options list and the primary button.
class _SafetyMessagePanel extends StatelessWidget {
  const _SafetyMessagePanel({
    required this.draft,
    required this.l10n,
  });

  final OnboardingDraft draft;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final List<Widget> messages = <Widget>[];

    if (draft.catheter) {
      messages.add(
        _SafetyMessage(
          text: l10n.o3CatheterMessage,
          background: AppColors.goalGeneralBg,
          foreground: AppColors.goalGeneralFg,
        ),
      );
    } else {
      if (draft.hasPain) {
        messages.add(
          _SafetyMessage(
            text: l10n.o3PainMessage,
            background: AppColors.streakBg,
            foreground: AppColors.streakFg,
          ),
        );
      }
      if (draft.recentSurgery) {
        messages.add(
          _SafetyMessage(
            text: l10n.o3SurgeryMessage,
            background: AppColors.streakBg,
            foreground: AppColors.streakFg,
          ),
        );
      }
    }

    if (messages.isEmpty) {
      return const SizedBox.shrink();
    }

    return Semantics(
      liveRegion: true,
      container: true,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int i = 0; i < messages.length; i++) ...[
                if (i > 0) const SizedBox(height: AppSpacing.md),
                Reveal(from: RevealFrom.drop, child: messages[i]),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SafetyMessage extends StatelessWidget {
  const _SafetyMessage({
    required this.text,
    required this.background,
    required this.foreground,
  });

  final String text;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadii.lgAll,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.warning_amber_rounded, color: foreground, size: 22),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                text,
                style: AppTypography.body.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SurgeryConfirmRow extends StatelessWidget {
  const _SurgeryConfirmRow({
    required this.label,
    required this.selected,
    required this.onChanged,
    required this.foreground,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onChanged;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!selected),
      borderRadius: AppRadii.mdAll,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppSpacing.minTouchTarget),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                value: selected,
                onChanged: (bool? value) => onChanged(value ?? false),
                activeColor: foreground,
                checkColor: AppColors.textOnPrimary,
                side: BorderSide(color: foreground, width: 2),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: const VisualDensity(
                  horizontal: -4,
                  vertical: -4,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                label,
                style: AppTypography.body.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
