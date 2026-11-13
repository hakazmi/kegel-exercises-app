import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../content/content_models.dart';
import '../content/content_repository.dart';
import '../domain/session_record.dart';
import '../domain/user_profile.dart';
import '../plan/plan_models.dart';
import '../plan/plan_service.dart';
import '../plan/session_definition.dart';
import '../time/app_clock.dart';
import 'database/app_database.dart';
import 'repositories/checkin_repository.dart';
import 'repositories/data_reset_service.dart';
import 'repositories/session_repository.dart';
import 'repositories/settings_repository.dart';

/// Shared preferences instance.
final sharedPreferencesProvider = Provider<SharedPreferences>((Ref ref) {
  throw UnimplementedError('Override sharedPreferencesProvider in main()');
});

/// Debug-only day offset applied on top of the system clock (H1 tools).
final debugDayOffsetProvider =
    NotifierProvider<DebugDayOffsetNotifier, int>(DebugDayOffsetNotifier.new);

/// Holds a debug day offset for [appClockProvider].
class DebugDayOffsetNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void set(int value) => state = value;

  void shift(int delta) => state = state + delta;
}

/// Premium entitlement stub until RevenueCat (Prompt 10). Debug can override.
final isPremiumOverrideProvider =
    NotifierProvider<PremiumOverrideNotifier, bool>(PremiumOverrideNotifier.new);

/// Holds the debug Premium override (defaults to false).
class PremiumOverrideNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool value) => state = value;
}

/// Whether Premium features are unlocked. Defaults to false.
final isPremiumProvider = Provider<bool>((Ref ref) {
  return ref.watch(isPremiumOverrideProvider);
});

/// App clock (override in tests). Honour [debugDayOffsetProvider] in debug builds.
final appClockProvider = Provider<AppClock>((Ref ref) {
  final int offsetDays = ref.watch(debugDayOffsetProvider);
  if (offsetDays == 0) {
    return const SystemClock();
  }
  return OffsetClock(Duration(days: offsetDays));
});

/// Drift database.
final appDatabaseProvider = Provider<AppDatabase>((Ref ref) {
  final AppDatabase db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final settingsRepositoryProvider = Provider<SettingsRepository>((Ref ref) {
  return SettingsRepository(ref.watch(sharedPreferencesProvider));
});

final sessionRepositoryProvider = Provider<SessionRepository>((Ref ref) {
  return SessionRepository(ref.watch(appDatabaseProvider));
});

final checkInRepositoryProvider = Provider<CheckInRepository>((Ref ref) {
  return CheckInRepository(ref.watch(appDatabaseProvider));
});

final dataResetServiceProvider = Provider<DataResetService>((Ref ref) {
  return DataResetService(
    settings: ref.watch(settingsRepositoryProvider),
    sessions: ref.watch(sessionRepositoryProvider),
    checkIns: ref.watch(checkInRepositoryProvider),
  );
});

final contentRepositoryProvider = Provider<ContentRepository>((Ref ref) {
  return ContentRepository();
});

final planServiceProvider = Provider<PlanService>((Ref ref) {
  return PlanService(clock: ref.watch(appClockProvider));
});

/// Reactive user profile.
final userProfileProvider =
    NotifierProvider<UserProfileNotifier, UserProfile>(UserProfileNotifier.new);

/// Holds and persists [UserProfile].
class UserProfileNotifier extends Notifier<UserProfile> {
  @override
  UserProfile build() {
    return ref.watch(settingsRepositoryProvider).load();
  }

  Future<void> save(UserProfile profile) async {
    await ref.read(settingsRepositoryProvider).save(profile);
    state = profile;
  }

  Future<void> reload() async {
    state = ref.read(settingsRepositoryProvider).load();
  }
}

/// Latest sessions for debug / plan.
final sessionsProvider = FutureProvider<List<SessionRecord>>((Ref ref) {
  return ref.watch(sessionRepositoryProvider).getAll();
});

/// All local check-in rows (never sent to analytics).
final checkInsProvider = FutureProvider<List<CheckInRecord>>((Ref ref) {
  return ref.watch(checkInRepositoryProvider).getAll();
});

final latestSessionsProvider =
    FutureProvider.family<List<SessionRecord>, int>((Ref ref, int limit) {
  return ref.watch(sessionRepositoryProvider).latest(limit);
});

final todayPlanProvider = FutureProvider<TodayPlan>((Ref ref) async {
  final UserProfile profile = ref.watch(userProfileProvider);
  final List<SessionRecord> sessions =
      await ref.watch(sessionsProvider.future);
  final List<LevelContent> levels =
      await ref.watch(levelsProvider.future);
  final LevelContent level = levels.firstWhere(
    (LevelContent l) => l.id == profile.level,
    orElse: () => levels.first,
  );
  final int strengthSeconds =
      SessionDefinitionBuilder.strengtheningDurationForLevel(level);
  return ref.watch(planServiceProvider).todayPlan(
        profile: profile,
        sessions: sessions,
        strengtheningDurationSeconds: strengthSeconds,
      );
});

/// Cached level definitions from content JSON.
final levelsProvider = FutureProvider<List<LevelContent>>((Ref ref) {
  return ref.watch(contentRepositoryProvider).loadLevels();
});

/// Cached exercise definitions from content JSON.
final exercisesProvider = FutureProvider<List<ExerciseContent>>((Ref ref) {
  return ref.watch(contentRepositoryProvider).loadExercises();
});

/// Learn article index (bodies load on the article screen).
final articlesProvider = FutureProvider<List<ArticleContent>>((Ref ref) {
  return ref.watch(contentRepositoryProvider).loadArticles();
});
