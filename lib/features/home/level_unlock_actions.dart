import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/l10n/app_localizations.dart';
import '../../app/router.dart';
import '../../core/data/providers.dart';
import '../../core/domain/user_profile.dart';
import '../../core/plan/level_progression.dart';
import '../../core/services/analytics_service.dart';
import '../../core/services/reminder_service.dart';

/// Shared Start / Stay handlers for H1, H2 and S4.
abstract final class LevelUnlockActions {
  static Future<void> snooze(WidgetRef ref) async {
    final UserProfile profile = ref.read(userProfileProvider);
    await ref
        .read(userProfileProvider.notifier)
        .save(LevelProgression.snooze(profile));
  }

  /// Returns true when the level was advanced (caller may show confirmation).
  static Future<bool> startNext({
    required BuildContext context,
    required WidgetRef ref,
    required int nextLevel,
  }) async {
    final bool isPremium = ref.read(isPremiumProvider);
    final LevelStartOutcome outcome = LevelProgression.startOutcome(
      nextLevel: nextLevel,
      isPremium: isPremium,
    );
    if (outcome == LevelStartOutcome.needsPremium) {
      if (context.mounted) {
        context.push('${AppRoutes.paywall}?source=locked_content');
      }
      return false;
    }

    final UserProfile profile = ref.read(userProfileProvider);
    final DateTime now = ref.read(appClockProvider).now();
    final UserProfile next = LevelProgression.advanceTo(
      profile: profile,
      nextLevel: nextLevel,
      now: now,
    );
    await ref.read(userProfileProvider.notifier).save(next);
    ref.invalidate(todayPlanProvider);
    await ref.read(reminderServiceProvider).clearLevelUnlockNotice();
    await ref
        .read(analyticsServiceProvider)
        .logEvent(
          'level_up',
          parameters: <String, Object?>{'level': nextLevel},
        );
    return true;
  }

  static void showStartedConfirm(
    BuildContext context,
    AppLocalizations l10n,
    int level,
  ) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.h1LevelStartedConfirm(level))));
  }
}
