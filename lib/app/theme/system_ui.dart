import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

/// Edge-to-edge system bar styles. The whole app is light, so every
/// style uses dark status and navigation icons; the names are kept for the
/// screens that reference them.
abstract final class AppSystemUi {
  /// Dark icons on a light scaffold (onboarding, tabs, settings).
  static const SystemUiOverlayStyle lightScreen = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
    systemNavigationBarContrastEnforced: false,
    systemStatusBarContrastEnforced: false,
  );

  /// Light icons on a dark session scaffold (S2–S4, T1 practice).
  static const SystemUiOverlayStyle darkScreen = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
    systemNavigationBarContrastEnforced: false,
    systemStatusBarContrastEnforced: false,
  );

  /// S1: dark header under the status bar, light body under the nav bar.
  static const SystemUiOverlayStyle darkHeaderLightBody = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
    systemNavigationBarContrastEnforced: false,
    systemStatusBarContrastEnforced: false,
  );
}
