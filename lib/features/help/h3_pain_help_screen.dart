import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/l10n/app_localizations.dart';
import '../../app/router.dart';
import '../../app/theme/tokens.dart';
import '../../core/widgets/primary_button.dart';
import '../session/session_controller.dart';

/// H3 Pain help — placeholder; confirms relaxation-first after S4 pain.
class H3PainHelpScreen extends ConsumerWidget {
  const H3PainHelpScreen({
    super.key,
    this.fromSession = false,
  });

  final bool fromSession;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.h3Title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.h3Body, style: AppTypography.body),
            const Spacer(),
            PrimaryButton(
              label:
                  fromSession ? l10n.h3ConfirmRelaxation : l10n.commonContinue,
              onPressed: () async {
                if (fromSession) {
                  await ref
                      .read(sessionControllerProvider.notifier)
                      .confirmPainTrack();
                }
                if (!context.mounted) {
                  return;
                }
                context.go(AppRoutes.today);
              },
            ),
          ],
        ),
      ),
    );
  }
}
