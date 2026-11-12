import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/bottom_tab_bar.dart';

/// Hosts the Today / Progress / Learn tabs with the shared bottom bar.
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

    return Scaffold(
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
    );
  }
}
