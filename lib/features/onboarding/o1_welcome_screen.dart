import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/l10n/app_localizations.dart';
import '../../app/router.dart';
import '../../app/theme/tokens.dart';
import '../../core/constants/links.dart';
import '../../core/widgets/widgets.dart';
import 'onboarding_controller.dart';
import 'widgets/onboarding_scaffold.dart';

/// O1 Welcome — age gate and disclaimer.
class O1WelcomeScreen extends ConsumerWidget {
  const O1WelcomeScreen({super.key});

  Future<void> _open(String url) async {
    final Uri uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final draft = ref.watch(onboardingControllerProvider);
    final OnboardingController controller =
        ref.read(onboardingControllerProvider.notifier);

    return OnboardingScaffold(
      step: 1,
      showHeader: false,
      onBack: null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Hero(l10n: l10n),
          const SizedBox(height: AppSpacing.xl),
          Text(l10n.o1Title, style: AppTypography.display),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.o1Body,
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.lg),
          _Bullet(text: l10n.o1BulletPlan),
          _Bullet(text: l10n.o1BulletDiscreet),
          _Bullet(text: l10n.o1BulletPrivate),
          const SizedBox(height: AppSpacing.lg),
          InkWell(
            onTap: () => controller.setAcceptedAge(!draft.acceptedAge),
            borderRadius: AppRadii.mdAll,
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(minHeight: AppSpacing.minTouchTarget),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Checkbox(
                      value: draft.acceptedAge,
                      onChanged: (bool? value) =>
                          controller.setAcceptedAge(value ?? false),
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
                      l10n.o1AgeCheckbox,
                      style: AppTypography.body
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          DisclaimerText(text: l10n.o1Disclaimer),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              TextLinkButton(
                label: l10n.o1Terms,
                underline: true,
                onPressed: () => _open(AppLinks.terms),
              ),
              const Text(' · ', style: AppTypography.caption),
              TextLinkButton(
                label: l10n.o1Privacy,
                underline: true,
                onPressed: () => _open(AppLinks.privacyPolicy),
              ),
            ],
          ),
        ],
      ),
      footer: PrimaryButton(
        label: l10n.o1GetStarted,
        enabled: draft.acceptedAge,
        onPressed: draft.acceptedAge
            ? () async {
                await controller.completeStep('O1');
                if (context.mounted) {
                  context.go(AppRoutes.goal);
                }
              }
            : null,
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: const BoxDecoration(
        color: AppColors.mint,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 28,
            top: 28,
            child: Illustration(
              assetPath: 'assets/images/calendar.svg',
              semanticLabel: l10n.o1CalendarSemantic,
              width: 36,
              height: 36,
            ),
          ),
          Positioned(
            right: 36,
            top: 24,
            child: Illustration(
              assetPath: 'assets/images/shield.svg',
              semanticLabel: l10n.o1ShieldSemantic,
              width: 36,
              height: 36,
            ),
          ),
          Positioned(
            left: 40,
            bottom: 28,
            child: Illustration(
              assetPath: 'assets/images/stopwatch.svg',
              semanticLabel: l10n.o1StopwatchSemantic,
              width: 32,
              height: 32,
            ),
          ),
          Positioned(
            right: 44,
            bottom: 24,
            child: Illustration(
              assetPath: 'assets/images/target.svg',
              semanticLabel: l10n.o1TargetSemantic,
              width: 32,
              height: 32,
            ),
          ),
          Illustration(
            assetPath: 'assets/images/standing.svg',
            semanticLabel: l10n.o1HeroSemantic,
            height: 130,
          ),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
          const SizedBox(width: AppSpacing.xs),
          Expanded(child: Text(text, style: AppTypography.body)),
        ],
      ),
    );
  }
}
