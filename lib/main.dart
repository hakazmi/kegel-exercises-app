import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/theme/system_ui.dart';
import 'core/cloud/cloud_bootstrap.dart';
import 'core/cloud/cloud_providers.dart';
import 'core/data/providers.dart';
import 'core/diagnostics/crash_reporting.dart';
import 'core/diagnostics/diagnostics_router_binder.dart';
import 'core/diagnostics/firebase_bootstrap.dart';
import 'core/diagnostics/performance_traces.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FirebaseBootstrap.initialize();

  final Trace? hydrate = PerfTraces.start('app_hydrate');
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await CrashReporting.initialize(prefs);
  await bootstrapCloud();
  await PerfTraces.stop(hydrate);

  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(AppSystemUi.lightScreen);

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const _CloudHooksBinder(
        child: DiagnosticsRouterBinder(child: KegelApp()),
      ),
    ),
  );
}

/// Wires sync hooks once providers are available.
class _CloudHooksBinder extends ConsumerWidget {
  const _CloudHooksBinder({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bindSyncHooks(
      coordinator: ref.watch(syncCoordinatorProvider),
      meta: ref.watch(syncMetadataStoreProvider),
    );
    return child;
  }
}
