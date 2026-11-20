import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kegelexercisesapp/core/data/providers.dart';

/// Loads the bundled content JSON with real async.
///
/// Large assets are decoded on a background isolate, which never finishes
/// inside a widget test's fake clock. Loading them here first caches the
/// providers so screens built afterwards read them straight away.
Future<void> preloadContent(WidgetTester tester, ProviderContainer c) async {
  await tester.runAsync(() async {
    await c.read(levelsProvider.future);
    await c.read(tracksProvider.future);
    await c.read(exercisesProvider.future);
    await c.read(articlesProvider.future);
  });
}
