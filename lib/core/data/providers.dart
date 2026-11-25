import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../content/content_models.dart';
import '../content/content_repository.dart';
import '../domain/enums.dart';
import '../domain/session_record.dart';
import '../domain/user_profile.dart';
import '../plan/plan_models.dart';
import '../plan/plan_service.dart';
import '../plan/session_definition.dart';
import '../time/app_clock.dart';
import '../cloud/sync_coordinator.dart';
import '../cloud/sync_metadata_store.dart';
import 'database/app_database.dart';
import 'repositories/checkin_repository.dart';
import 'repositories/data_reset_service.dart';
import 'repositories/habit_repository.dart';
import 'repositories/hold_test_repository.dart';
import 'repositories/session_repository.dart';
import 'repositories/settings_repository.dart';

// Sync coordinator is provided from cloud_providers to avoid a cycle;
// repositories receive a lazy notify callback.
SyncCoordinator? _syncCoordinatorRef;
SyncMetadataStore? _syncMetaRef;

/// Called once from [cloudProvidersReady] / app bootstrap.
void bindSyncHooks({
  required SyncCoordinator coordinator,
  required SyncMetadataStore meta,
}) {
  _syncCoordinatorRef = coordinator;
  _syncMetaRef = meta;
}

void _notifyDirty() => _syncCoordinatorRef?.notifyLocalChange();

/// Shared preferences instance.
final sharedPreferencesProvider = Provider<SharedPreferences>((Ref ref) {
  throw UnimplementedError('Override sharedPreferencesProvider in main()');
});

/// Debug-only day offset applied on top of the system clock (H1 tools).
final debugDayOffsetProvider = NotifierProvider<DebugDayOffsetNotifier, int>(
  DebugDayOffsetNotifier.new,
);

/// Holds a debug day offset for [appClockProvider].
class DebugDayOffsetNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void set(int value) => state = value;

  void shift(int delta) => state = state + delta;
}

/// Premium entitlement stub until RevenueCat (Prompt 10).
/// Debug builds default to unlocked so Levels 2–5 can be tested; toggle in Settings.
final isPremiumOverrideProvider =
    NotifierProvider<PremiumOverrideNotifier, bool>(
      PremiumOverrideNotifier.new,
    );

/// Holds the debug Premium override.
class PremiumOverrideNotifier extends Notifier<bool> {
  @override
  bool build() => kDebugMode;

  void set(bool value) => state = value;
}

/// Whether Premium features are unlocked.
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
  return SessionRepository(
    ref.watch(appDatabaseProvider),
    onDirty: _notifyDirty,
  );
});

final checkInRepositoryProvider = Provider<CheckInRepository>((Ref ref) {
  return CheckInRepository(
    ref.watch(appDatabaseProvider),
    onDirty: _notifyDirty,
  );
});

final habitRepositoryProvider = Provider<HabitRepository>((Ref ref) {
  return HabitRepository(
    ref.watch(appDatabaseProvider),
    onDirty: _notifyDirty,
  );
});

final walkingRepositoryProvider = Provider<WalkingRepository>((Ref ref) {
  return WalkingRepository(
    ref.watch(appDatabaseProvider),
    onDirty: _notifyDirty,
  );
});

final dataResetServiceProvider = Provider<DataResetService>((Ref ref) {
  return DataResetService(
    settings: ref.watch(settingsRepositoryProvider),
    sessions: ref.watch(sessionRepositoryProvider),
    checkIns: ref.watch(checkInRepositoryProvider),
    habits: ref.watch(habitRepositoryProvider),
    walking: ref.watch(walkingRepositoryProvider),
    holdTests: ref.watch(holdTestRepositoryProvider),
    syncMeta: SyncMetadataStore(ref.watch(sharedPreferencesProvider)),
  );
});

final holdTestRepositoryProvider = Provider<HoldTestRepository>((Ref ref) {
  return HoldTestRepository(ref.watch(sharedPreferencesProvider));
});

/// Saved pelvic floor hold tests, oldest first. On-device only.
final holdTestsProvider =
    NotifierProvider<HoldTestsNotifier, List<HoldTestResult>>(
      HoldTestsNotifier.new,
    );

class HoldTestsNotifier extends Notifier<List<HoldTestResult>> {
  @override
  List<HoldTestResult> build() => ref.watch(holdTestRepositoryProvider).all();

  Future<void> add(double seconds) async {
    final HoldTestRepository repo = ref.read(holdTestRepositoryProvider);
    final HoldTestResult saved = await repo.add(
      HoldTestResult(at: ref.read(appClockProvider).now(), seconds: seconds),
    );
    final String? syncId = saved.syncId;
    if (syncId != null) {
      await _syncMetaRef?.markHoldDirty(syncId);
      _notifyDirty();
    }
    state = repo.all();
  }
}

/// When the "How to do a Kegel" guide was last finished (null = never).
final guideSeenOnProvider = NotifierProvider<GuideSeenNotifier, DateTime?>(
  GuideSeenNotifier.new,
);

class GuideSeenNotifier extends Notifier<DateTime?> {
  @override
  DateTime? build() => ref.watch(holdTestRepositoryProvider).guideSeenOn();

  Future<void> markToday() async {
    final DateTime now = ref.read(appClockProvider).now();
    await ref.read(holdTestRepositoryProvider).markGuideSeen(now);
    state = now;
  }
}

final contentRepositoryProvider = Provider<ContentRepository>((Ref ref) {
  return ContentRepository();
});

final planServiceProvider = Provider<PlanService>((Ref ref) {
  return PlanService(clock: ref.watch(appClockProvider));
});

/// Reactive user profile.
final userProfileProvider = NotifierProvider<UserProfileNotifier, UserProfile>(
  UserProfileNotifier.new,
);

/// Holds and persists [UserProfile].
class UserProfileNotifier extends Notifier<UserProfile> {
  @override
  UserProfile build() {
    return ref.watch(settingsRepositoryProvider).load();
  }

  Future<void> save(UserProfile profile) async {
    await ref.read(settingsRepositoryProvider).save(profile);
    state = profile;
    final SyncMetadataStore? meta = _syncMetaRef;
    if (meta != null) {
      // Safety-only edits still mark profile dirty; payload strips safety.
      await meta.markProfileDirty();
      await meta.markPrefsDirty();
      _notifyDirty();
    }
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

final latestSessionsProvider = FutureProvider.family<List<SessionRecord>, int>((
  Ref ref,
  int limit,
) {
  return ref.watch(sessionRepositoryProvider).latest(limit);
});

final todayPlanProvider = FutureProvider<TodayPlan>((Ref ref) async {
  final UserProfile profile = ref.watch(userProfileProvider);
  final List<SessionRecord> sessions = await ref.watch(sessionsProvider.future);
  final List<LevelContent> levels = await ref.watch(levelsProvider.future);
  final List<TrackContent> tracks = await ref.watch(tracksProvider.future);
  final List<ExerciseContent> exercises = await ref.watch(
    exercisesProvider.future,
  );
  final LevelContent level = levels.firstWhere(
    (LevelContent l) => l.id == profile.level,
    orElse: () => levels.first,
  );
  final TrackContent track = tracks.firstWhere(
    (TrackContent t) => t.id == profile.track.contentId,
    orElse: () => tracks.first,
  );
  final Map<String, ExerciseContent> byId = <String, ExerciseContent>{
    for (final ExerciseContent e in exercises) e.id: e,
  };
  final DateTime today = ref.watch(appClockProvider).now();
  final Set<String> habitsDone = await ref
      .watch(habitRepositoryProvider)
      .doneHabitIdsOn(today);
  final int strengthSeconds =
      SessionDefinitionBuilder.strengtheningDurationForLevel(level);
  return ref
      .watch(planServiceProvider)
      .todayPlan(
        profile: profile,
        sessions: sessions,
        trackContent: track,
        levelContent: level,
        exercisesById: byId,
        habitsDoneToday: habitsDone,
        isPremium: ref.watch(isPremiumProvider),
        strengtheningDurationSeconds: strengthSeconds,
      );
});

/// Cached level definitions from content JSON.
final levelsProvider = FutureProvider<List<LevelContent>>((Ref ref) {
  return ref.watch(contentRepositoryProvider).loadLevels();
});

/// Cached track definitions from content JSON.
final tracksProvider = FutureProvider<List<TrackContent>>((Ref ref) {
  return ref.watch(contentRepositoryProvider).loadTracks();
});

/// Cached exercise definitions from content JSON.
final exercisesProvider = FutureProvider<List<ExerciseContent>>((Ref ref) {
  return ref.watch(contentRepositoryProvider).loadExercises();
});

/// Learn article index (bodies load on the article screen).
final articlesProvider = FutureProvider<List<ArticleContent>>((Ref ref) {
  return ref.watch(contentRepositoryProvider).loadArticles();
});

/// Walking week stats for Progress (minutes + days with any minutes).
final walkingWeekProvider = FutureProvider<({int minutes, int days})>((
  Ref ref,
) async {
  final DateTime today = ref.watch(appClockProvider).now();
  return ref.watch(walkingRepositoryProvider).weekStats(today);
});
