import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../features/dev/widget_gallery_screen.dart';
import '../features/shell/main_shell.dart';
import '../features/shell/placeholder_screen.dart';
import 'l10n/app_localizations.dart';

/// Named route paths for the whole app map.
abstract final class AppRoutes {
  static const String welcome = '/onboarding/welcome';
  static const String goal = '/onboarding/goal';
  static const String safety = '/onboarding/safety';
  static const String experience = '/onboarding/experience';
  static const String time = '/onboarding/time';
  static const String plan = '/onboarding/plan';
  static const String tutorial = '/tutorial';
  static const String before = '/session/before';
  static const String countdown = '/session/countdown';
  static const String player = '/session/player';
  static const String done = '/session/done';
  static const String paywall = '/paywall';
  static const String today = '/today';
  static const String levels = '/levels';
  static const String painHelp = '/pain-help';
  static const String progress = '/progress';
  static const String checkin = '/check-in';
  static const String learn = '/learn';
  static const String article = '/learn/article';
  static const String settings = '/settings';
  static const String gallery = '/dev/gallery';
}

/// Creates the app [GoRouter] with shell tabs and full-screen routes.
GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: AppRoutes.welcome,
    debugLogDiagnostics: kDebugMode,
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.welcome,
        builder: (BuildContext context, GoRouterState state) {
          if (kDebugMode) {
            return const PlaceholderScreen(
              id: 'O1',
              name: 'Welcome',
              nextRoutes: <RouteLink>[
                RouteLink(AppRoutes.goal, 'O2 Goal'),
                RouteLink(AppRoutes.gallery, 'Dev gallery'),
              ],
            );
          }
          return const PlaceholderScreen(
            id: 'O1',
            name: 'Welcome',
            nextRoutes: <RouteLink>[
              RouteLink(AppRoutes.goal, 'O2 Goal'),
            ],
          );
        },
      ),
      GoRoute(
        path: AppRoutes.goal,
        builder: (BuildContext context, GoRouterState state) {
          return const PlaceholderScreen(
            id: 'O2',
            name: 'Goal',
            nextRoutes: <RouteLink>[RouteLink(AppRoutes.safety, 'O3 Safety')],
          );
        },
      ),
      GoRoute(
        path: AppRoutes.safety,
        builder: (BuildContext context, GoRouterState state) {
          return const PlaceholderScreen(
            id: 'O3',
            name: 'Safety',
            nextRoutes: <RouteLink>[
              RouteLink(AppRoutes.experience, 'O4 Experience'),
            ],
          );
        },
      ),
      GoRoute(
        path: AppRoutes.experience,
        builder: (BuildContext context, GoRouterState state) {
          return const PlaceholderScreen(
            id: 'O4',
            name: 'Experience',
            nextRoutes: <RouteLink>[RouteLink(AppRoutes.time, 'O5 Time')],
          );
        },
      ),
      GoRoute(
        path: AppRoutes.time,
        builder: (BuildContext context, GoRouterState state) {
          return const PlaceholderScreen(
            id: 'O5',
            name: 'Time',
            nextRoutes: <RouteLink>[RouteLink(AppRoutes.plan, 'O6 Plan')],
          );
        },
      ),
      GoRoute(
        path: AppRoutes.plan,
        builder: (BuildContext context, GoRouterState state) {
          return const PlaceholderScreen(
            id: 'O6',
            name: 'Plan',
            nextRoutes: <RouteLink>[
              RouteLink(AppRoutes.tutorial, 'T1 Tutorial'),
              RouteLink(AppRoutes.before, 'S1 Before (skip tutorial)'),
            ],
          );
        },
      ),
      GoRoute(
        path: AppRoutes.tutorial,
        builder: (BuildContext context, GoRouterState state) {
          return const PlaceholderScreen(
            id: 'T1',
            name: 'Tutorial',
            nextRoutes: <RouteLink>[RouteLink(AppRoutes.before, 'S1 Before')],
          );
        },
      ),
      GoRoute(
        path: AppRoutes.before,
        builder: (BuildContext context, GoRouterState state) {
          return const PlaceholderScreen(
            id: 'S1',
            name: 'Before',
            nextRoutes: <RouteLink>[
              RouteLink(AppRoutes.countdown, 'S2 Countdown'),
              RouteLink(AppRoutes.tutorial, 'T1 Tutorial'),
            ],
          );
        },
      ),
      GoRoute(
        path: AppRoutes.countdown,
        builder: (BuildContext context, GoRouterState state) {
          return const PlaceholderScreen(
            id: 'S2',
            name: 'Countdown',
            useSessionTheme: true,
            nextRoutes: <RouteLink>[RouteLink(AppRoutes.player, 'S3 Player')],
          );
        },
      ),
      GoRoute(
        path: AppRoutes.player,
        builder: (BuildContext context, GoRouterState state) {
          return const PlaceholderScreen(
            id: 'S3',
            name: 'Player',
            useSessionTheme: true,
            nextRoutes: <RouteLink>[RouteLink(AppRoutes.done, 'S4 Done')],
          );
        },
      ),
      GoRoute(
        path: AppRoutes.done,
        builder: (BuildContext context, GoRouterState state) {
          return const PlaceholderScreen(
            id: 'S4',
            name: 'Done',
            useSessionTheme: true,
            nextRoutes: <RouteLink>[
              RouteLink(AppRoutes.paywall, 'P1 Paywall'),
              RouteLink(AppRoutes.today, 'H1 Today'),
              RouteLink(AppRoutes.painHelp, 'H3 PainHelp'),
            ],
          );
        },
      ),
      GoRoute(
        path: AppRoutes.paywall,
        builder: (BuildContext context, GoRouterState state) {
          return const PlaceholderScreen(
            id: 'P1',
            name: 'Paywall',
            nextRoutes: <RouteLink>[RouteLink(AppRoutes.today, 'H1 Today')],
          );
        },
      ),
      GoRoute(
        path: AppRoutes.levels,
        builder: (BuildContext context, GoRouterState state) {
          return const PlaceholderScreen(
            id: 'H2',
            name: 'Levels',
            nextRoutes: <RouteLink>[RouteLink(AppRoutes.today, 'H1 Today')],
          );
        },
      ),
      GoRoute(
        path: AppRoutes.painHelp,
        builder: (BuildContext context, GoRouterState state) {
          return const PlaceholderScreen(
            id: 'H3',
            name: 'PainHelp',
            nextRoutes: <RouteLink>[RouteLink(AppRoutes.today, 'H1 Today')],
          );
        },
      ),
      GoRoute(
        path: AppRoutes.checkin,
        builder: (BuildContext context, GoRouterState state) {
          return const PlaceholderScreen(
            id: 'G2',
            name: 'Checkin',
            nextRoutes: <RouteLink>[
              RouteLink(AppRoutes.progress, 'G1 Progress'),
            ],
          );
        },
      ),
      GoRoute(
        path: AppRoutes.article,
        builder: (BuildContext context, GoRouterState state) {
          return const PlaceholderScreen(
            id: 'L2',
            name: 'Article',
            nextRoutes: <RouteLink>[RouteLink(AppRoutes.learn, 'L1 Learn')],
          );
        },
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (BuildContext context, GoRouterState state) {
          return const PlaceholderScreen(
            id: 'X1',
            name: 'Settings',
            nextRoutes: <RouteLink>[RouteLink(AppRoutes.today, 'H1 Today')],
          );
        },
      ),
      if (kDebugMode)
        GoRoute(
          path: AppRoutes.gallery,
          builder: (BuildContext context, GoRouterState state) {
            return const WidgetGalleryScreen();
          },
        ),
      StatefulShellRoute.indexedStack(
        builder: (
          BuildContext context,
          GoRouterState state,
          StatefulNavigationShell navigationShell,
        ) {
          final AppLocalizations l10n = AppLocalizations.of(context);
          return MainShell(
            navigationShell: navigationShell,
            todayLabel: l10n.tabToday,
            progressLabel: l10n.tabProgress,
            learnLabel: l10n.tabLearn,
          );
        },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.today,
                builder: (BuildContext context, GoRouterState state) {
                  return const PlaceholderScreen(
                    id: 'H1',
                    name: 'Today',
                    showBottomGap: true,
                    nextRoutes: <RouteLink>[
                      RouteLink(AppRoutes.before, 'S1 Before'),
                      RouteLink(AppRoutes.levels, 'H2 Levels'),
                      RouteLink(AppRoutes.painHelp, 'H3 PainHelp'),
                      RouteLink(AppRoutes.settings, 'X1 Settings'),
                    ],
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.progress,
                builder: (BuildContext context, GoRouterState state) {
                  return const PlaceholderScreen(
                    id: 'G1',
                    name: 'Progress',
                    showBottomGap: true,
                    nextRoutes: <RouteLink>[
                      RouteLink(AppRoutes.checkin, 'G2 Checkin'),
                      RouteLink(AppRoutes.settings, 'X1 Settings'),
                    ],
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.learn,
                builder: (BuildContext context, GoRouterState state) {
                  return const PlaceholderScreen(
                    id: 'L1',
                    name: 'Learn',
                    showBottomGap: true,
                    nextRoutes: <RouteLink>[
                      RouteLink(AppRoutes.article, 'L2 Article'),
                      RouteLink(AppRoutes.tutorial, 'T1 Tutorial'),
                    ],
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
