import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/theme/system_ui.dart';
import 'core/cloud/cloud_bootstrap.dart';
import 'core/cloud/cloud_providers.dart';
import 'core/data/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await bootstrapCloud();

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
      child: const _CloudHooksBinder(child: KegelApp()),
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
