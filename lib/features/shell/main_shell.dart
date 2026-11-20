import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/theme/system_ui.dart';
import '../../core/widgets/bottom_tab_bar.dart';

/// Hosts the Today / Progress / Learn tabs with the shared bottom bar.
///
/// Android system back: Progress/Learn → Today; Today exits the app.
/// Each tab keeps its own stack via [StatefulNavigationShell].
class MainShell extends StatelessWidget {
  const MainShell({
    super.key,
    required this.navigationShell,
    required this.todayLabel,
    required this.progressLabel,
    required this.learnLabel,
  });

  final StatefulNavigationShell navigationShell;
  final String todayLabel;
  final String progressLabel;
  final String learnLabel;

  @override
  Widget build(BuildContext context) {
    final AppTab current = switch (navigationShell.currentIndex) {
      0 => AppTab.today,
      1 => AppTab.progress,
      _ => AppTab.learn,
    };

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) {
          return;
        }
        if (navigationShell.currentIndex != 0) {
          navigationShell.goBranch(0);
          return;
        }
        SystemNavigator.pop();
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: AppSystemUi.lightScreen,
        child: Scaffold(
          extendBody: true,
          body: navigationShell,
          bottomNavigationBar: BottomTabBar(
            current: current,
            todayLabel: todayLabel,
            progressLabel: progressLabel,
            learnLabel: learnLabel,
            onSelect: (AppTab tab) {
              final int index = switch (tab) {
                AppTab.today => 0,
                AppTab.progress => 1,
                AppTab.learn => 2,
              };
              navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              );
            },
          ),
        ),
      ),
    );
  }
}
