import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../content/content_models.dart';
import '../content/content_repository.dart';
import '../domain/session_record.dart';
import '../domain/user_profile.dart';
import '../plan/plan_models.dart';
import '../plan/plan_service.dart';
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

/// App clock (override in tests).
final appClockProvider = Provider<AppClock>((Ref ref) => const SystemClock());

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

final latestSessionsProvider =
    FutureProvider.family<List<SessionRecord>, int>((Ref ref, int limit) {
  return ref.watch(sessionRepositoryProvider).latest(limit);
});

final todayPlanProvider = FutureProvider<TodayPlan>((Ref ref) async {
  final UserProfile profile = ref.watch(userProfileProvider);
  final List<SessionRecord> sessions =
      await ref.watch(sessionsProvider.future);
  return ref.watch(planServiceProvider).todayPlan(
        profile: profile,
        sessions: sessions,
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
