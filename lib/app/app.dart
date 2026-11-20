import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../core/constants/app_constants.dart';
import '../core/motion/app_motion.dart';
import '../core/services/reminder_service.dart';
import '../features/shell/splash_overlay.dart';
import 'l10n/app_localizations.dart';
import 'router.dart';
import 'theme/app_theme.dart';

/// Root widget: Riverpod scope, theme, localisation, router and splash.
class KegelApp extends ConsumerStatefulWidget {
  const KegelApp({super.key});

  @override
  ConsumerState<KegelApp> createState() => _KegelAppState();
}

class _KegelAppState extends ConsumerState<KegelApp>
    with WidgetsBindingObserver {
  /// Splash overlay is shown on cold start, never in tests (motion reduced).
  bool _showSplash = !AppMotion.reduce;

  Timer? _bootstrapTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Reminder setup parses the timezone database and queries the plan.
    // Run it after the first screen has loaded instead of competing with it.
    _bootstrapTimer = Timer(
      _showSplash ? const Duration(seconds: 3) : Duration.zero,
      () => unawaited(_bootstrapReminders()),
    );
  }

  @override
  void dispose() {
    _bootstrapTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        _bootstrapTimer?.isActive != true) {
      unawaited(_bootstrapReminders());
    }
  }

  /// Reminders are best-effort: if the platform notification plugin is not
  /// available (tests, an unsupported device) the app keeps working without
  /// them instead of surfacing an error.
  Future<void> _bootstrapReminders() async {
    try {
      final ReminderService reminders = ref.read(reminderServiceProvider);
      await reminders.initialize();
      await reminders.reschedule();
    } on Object catch (error) {
      debugPrint('Reminder setup skipped: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final GoRouter router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: AppConstants.displayName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (BuildContext context, Widget? child) {
        if (!_showSplash) {
          return child ?? const SizedBox.shrink();
        }
        return Stack(
          children: [
            ?child,
            Positioned.fill(
              child: SplashOverlay(
                onFinished: () => setState(() => _showSplash = false),
              ),
            ),
          ],
        );
      },
    );
  }
}
