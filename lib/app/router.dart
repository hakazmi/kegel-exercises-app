import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../core/data/providers.dart';
import '../core/domain/user_profile.dart';
import '../features/holdtest/hold_test_screen.dart';
import '../features/dev/data_debug_screen.dart';
import '../features/dev/widget_gallery_screen.dart';
import '../features/onboarding/o1_welcome_screen.dart';
import '../features/onboarding/o2_goal_screen.dart';
import '../features/onboarding/o3_safety_screen.dart';
import '../features/onboarding/o4_experience_screen.dart';
import '../features/onboarding/o5_time_screen.dart';
import '../features/onboarding/o6_plan_screen.dart';
import '../features/help/h3_pain_help_screen.dart';
import '../features/home/h1_today_screen.dart';
import '../features/home/h2_level_day_screen.dart';
import '../features/home/h2_levels_screen.dart';
import '../features/learn/l1_learn_screen.dart';
import '../features/learn/l2_article_screen.dart';
import '../features/progress/g1_progress_screen.dart';
import '../features/progress/g2_checkin_screen.dart';
import '../features/session/s1_before_screen.dart';
import '../features/settings/settings_safety_screen.dart';
import '../features/settings/x1_settings_screen.dart';
import '../features/session/s2_countdown_screen.dart';
import '../features/session/s3_player_screen.dart';
import '../features/session/s4_done_screen.dart';
import '../features/shell/main_shell.dart';
import '../features/shell/placeholder_screen.dart';
import '../features/tutorial/t1_tutorial_screen.dart';
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
  static const String holdTest = '/hold-test';
  static const String before = '/session/before';
  static const String countdown = '/session/countdown';
  static const String player = '/session/player';
  static const String done = '/session/done';
  static const String paywall = '/paywall';
  static const String today = '/today';
  static const String levels = '/levels';
  static const String levelDay = '/levels/day';
  static const String painHelp = '/pain-help';
  static const String progress = '/progress';
  static const String checkin = '/check-in';
  static const String learn = '/learn';
  static const String article = '/learn/article';
  static const String settings = '/settings';
  static const String settingsSafety = '/settings/safety';
  static const String gallery = '/dev/gallery';
  static const String dataDebug = '/dev/data';

  static const Set<String> onboarding = <String>{
    welcome,
    goal,
    safety,
    experience,
    time,
    plan,
  };
}

/// Riverpod-backed router with onboarding redirects.
final routerProvider = Provider<GoRouter>((Ref ref) {
  final ValueNotifier<int> refresh = ValueNotifier<int>(0);
  ref.listen<UserProfile>(userProfileProvider, (UserProfile? previous, UserProfile next) {
    refresh.value++;
  });
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: AppRoutes.welcome,
    debugLogDiagnostics: kDebugMode,
    refreshListenable: refresh,
    redirect: (BuildContext context, GoRouterState state) {
      final bool done = ref.read(userProfileProvider).onboardingDone;
      final String loc = state.matchedLocation;
      final bool isOnboarding = AppRoutes.onboarding.contains(loc);
      final bool isDev = loc.startsWith('/dev');

      if (!done && !isOnboarding && !(kDebugMode && isDev)) {
        return AppRoutes.welcome;
      }
      if (done && isOnboarding) {
        return AppRoutes.today;
      }
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.welcome,
        builder: (BuildContext context, GoRouterState state) {
          return const O1WelcomeScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.goal,
        builder: (BuildContext context, GoRouterState state) {
          return const O2GoalScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.safety,
        builder: (BuildContext context, GoRouterState state) {
          return const O3SafetyScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.experience,
        builder: (BuildContext context, GoRouterState state) {
          return const O4ExperienceScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.time,
        builder: (BuildContext context, GoRouterState state) {
          return const O5TimeScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.plan,
        builder: (BuildContext context, GoRouterState state) {
          return const O6PlanScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.tutorial,
        builder: (BuildContext context, GoRouterState state) {
          final bool replay = state.uri.queryParameters['replay'] == '1' ||
              state.uri.queryParameters['replay'] == 'true';
          final String? next = state.uri.queryParameters['next'];
          return T1TutorialScreen(replay: replay, nextPath: next);
        },
      ),
      GoRoute(
        path: AppRoutes.holdTest,
        builder: (BuildContext context, GoRouterState state) {
          return const HoldTestScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.before,
        builder: (BuildContext context, GoRouterState state) {
          return S1BeforeScreen(
            itemId: state.uri.queryParameters['itemId'],
          );
        },
      ),
      GoRoute(
        path: AppRoutes.countdown,
        builder: (BuildContext context, GoRouterState state) {
          return S2CountdownScreen(
            itemId: state.uri.queryParameters['itemId'],
          );
        },
      ),
      GoRoute(
        path: AppRoutes.player,
        builder: (BuildContext context, GoRouterState state) {
          return S3PlayerScreen(
            itemId: state.uri.queryParameters['itemId'],
          );
        },
      ),
      GoRoute(
        path: AppRoutes.done,
        builder: (BuildContext context, GoRouterState state) {
          return S4DoneScreen(
            itemId: state.uri.queryParameters['itemId'],
          );
        },
      ),
      GoRoute(
        path: AppRoutes.paywall,
        builder: (BuildContext context, GoRouterState state) {
          final String source =
              state.uri.queryParameters['source'] ?? 'unknown';
          return PlaceholderScreen(
            id: 'P1',
            name: 'Paywall ($source)',
            nextRoutes: const <RouteLink>[
              RouteLink(AppRoutes.today, 'H1 Today'),
            ],
          );
        },
      ),
      GoRoute(
        path: AppRoutes.levels,
        builder: (BuildContext context, GoRouterState state) {
          return const H2LevelsScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.levelDay,
        builder: (BuildContext context, GoRouterState state) {
          return H2LevelDayScreen(
            level: int.tryParse(state.uri.queryParameters['level'] ?? '') ?? 1,
            day: int.tryParse(state.uri.queryParameters['day'] ?? '') ?? 1,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.painHelp,
        builder: (BuildContext context, GoRouterState state) {
          final bool fromSession =
              state.uri.queryParameters['fromSession'] == '1';
          return H3PainHelpScreen(fromSession: fromSession);
        },
      ),
      GoRoute(
        path: AppRoutes.checkin,
        builder: (BuildContext context, GoRouterState state) {
          return const G2CheckInScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.article,
        builder: (BuildContext context, GoRouterState state) {
          final String id = state.uri.queryParameters['id'] ?? '';
          return L2ArticleScreen(articleId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (BuildContext context, GoRouterState state) {
          return const X1SettingsScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.settingsSafety,
        builder: (BuildContext context, GoRouterState state) {
          return const SettingsSafetyScreen();
        },
      ),
      if (kDebugMode) ...<RouteBase>[
        GoRoute(
          path: AppRoutes.gallery,
          builder: (BuildContext context, GoRouterState state) {
            return const WidgetGalleryScreen();
          },
        ),
        GoRoute(
          path: AppRoutes.dataDebug,
          builder: (BuildContext context, GoRouterState state) {
            return const DataDebugScreen();
          },
        ),
      ],
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
                  return const H1TodayScreen();
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.progress,
                builder: (BuildContext context, GoRouterState state) {
                  return const G1ProgressScreen();
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.learn,
                builder: (BuildContext context, GoRouterState state) {
                  return const L1LearnScreen();
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
