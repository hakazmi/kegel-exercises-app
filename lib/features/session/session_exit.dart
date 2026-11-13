import 'package:material_ui/material_ui.dart';

import '../../app/l10n/app_localizations.dart';
import '../../core/widgets/confirm_dialog.dart';

/// Shared "End this session?" confirm used by Exit and Android system back.
Future<bool> confirmSessionExit(BuildContext context) {
  final AppLocalizations l10n = AppLocalizations.of(context);
  return ConfirmDialog.show(
    context,
    title: l10n.s3ExitTitle,
    message: l10n.s3ExitMessage,
    confirmLabel: l10n.s3ExitConfirm,
    cancelLabel: l10n.commonCancel,
    isDestructive: true,
  );
}
