import 'dart:async';

import 'package:kegelexercisesapp/core/motion/app_motion.dart';

/// Runs before every test file (Flutter picks this file up automatically).
///
/// Widget tests check behaviour, not motion: render every animation at its
/// end state so `pump()` and `pumpAndSettle()` never wait on loops.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  AppMotion.reduce = true;
  await testMain();
}
