import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/l10n/app_localizations.dart';
import '../../app/router.dart';
import '../../app/theme/tokens.dart';
import '../../core/widgets/widgets.dart';
import 'onboarding_controller.dart';
import 'onboarding_state.dart';
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

    return OnboardingScaffold(
      step: 3,
      onBack: () => context.go(AppRoutes.goal),
      fadeListBottom: true,
      listMinExtent: minOptionsListExtent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Illustration(
              assetPath: 'assets/images/shield.svg',
              semanticLabel: l10n.o3ShieldSemantic,
              width: 56,
              height: 56,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(l10n.o3Title, style: AppTypography.display),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.o3Subtitle,
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.lg),
          MultiSelectCard(
            title: l10n.o3Pain,
            selected: draft.pain,
            onChanged: (bool value) => controller.toggleSafety(pain: value),
          ),
          const SizedBox(height: AppSpacing.xs),
          MultiSelectCard(
            title: l10n.o3PainSexual,
            selected: draft.painSexual,
            onChanged: (bool value) =>
                controller.toggleSafety(painSexual: value),
          ),
          const SizedBox(height: AppSpacing.xs),
          MultiSelectCard(
            title: l10n.o3Surgery,
            selected: draft.recentSurgery,
            onChanged: (bool value) =>
                controller.toggleSafety(recentSurgery: value),
          ),
          const SizedBox(height: AppSpacing.xs),
          MultiSelectCard(
            title: l10n.o3Catheter,
            selected: draft.catheter,
            onChanged: (bool value) => controller.toggleSafety(catheter: value),
          ),
          const SizedBox(height: AppSpacing.xs),
          MultiSelectCard(
            title: l10n.o3None,
            selected: draft.noneOfThese,
            onChanged: (bool value) {
              if (value) {
                controller.toggleSafety(noneOfThese: true);
              }
            },
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
                messages[i],
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
