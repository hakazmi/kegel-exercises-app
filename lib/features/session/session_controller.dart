import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../core/content/content_models.dart';
import '../../core/data/providers.dart';
import '../../core/domain/enums.dart';
import '../../core/domain/session_record.dart';
import '../../core/domain/user_profile.dart';
import '../../core/plan/level_progression.dart';
import '../../core/plan/plan_models.dart';
import '../../core/plan/plan_rules.dart';
import '../../core/plan/session_definition.dart';
import '../../core/services/analytics_service.dart';
import '../../core/services/haptics_service.dart';
import '../../core/services/reminder_service.dart';
import '../../core/time/app_clock.dart';
import 'engine/engine_models.dart';
import 'engine/session_engine.dart';
import 'session_voice.dart';

/// Snapshot for the live session UI (S2–S4).
class SessionPlayState {
  const SessionPlayState({
    required this.itemId,
    required this.definition,
    required this.dayInLevel,
    required this.engineState,
    this.sessionStartLogged = false,
    this.summary,
  });

  final String itemId;
  final SessionDefinition definition;
  final int dayInLevel;
  final EngineState engineState;
  final bool sessionStartLogged;
  final SessionCompleteSummary? summary;

  bool get isReady => true;
}

/// Data shown on S4 after the engine finishes.
class SessionCompleteSummary {
  const SessionCompleteSummary({
    required this.durationSeconds,
    required this.longestHoldSeconds,
    required this.streak,
    required this.wasFirstEver,
    this.nextLabel,
  });

  final int durationSeconds;

  /// Longest prescribed hold completed in this session.
  /// The phone cannot measure the real hold — this is the programmed duration.
  final int longestHoldSeconds;

  final int streak;
  final bool wasFirstEver;
  final String? nextLabel;
}

/// Drives [SessionEngine] for the active countdown/player flow.
class SessionController extends Notifier<SessionPlayState?> {
  SessionEngine? _engine;
  StreamSubscription<EngineState>? _stateSub;
  StreamSubscription<EngineEvent>? _eventSub;
  final SessionVoice _voice = SessionVoice();
  DateTime? _startedAt;
  bool _completing = false;

  @override
  SessionPlayState? build() {
    ref.onDispose(_tearDown);
    return null;
  }

  SessionEngine? get engine => _engine;

  /// Builds the definition and starts the countdown.
  Future<void> begin(String itemId) async {
    await _tearDown();
    _completing = false;

    final UserProfile profile = ref.read(userProfileProvider);
    final AppClock clock = ref.read(appClockProvider);
    final TodayPlan plan = await ref.read(todayPlanProvider.future);
    final List<LevelContent> levels = await ref.read(levelsProvider.future);
    final LevelContent level = levels.firstWhere(
      (LevelContent l) => l.id == profile.level,
      orElse: () => levels.first,
    );
    final TodayItem item = _resolveItem(plan, itemId);
    final SessionDefinition definition =
        SessionDefinitionBuilder.fromLevelAndItem(
      level: level,
      item: item,
      sessionsToday: profile.sessionsPerDay.clamp(1, 3),
    );

    final SessionEngine engine = SessionEngine(
      definition: definition,
      clock: clock,
      countdownSeconds: 5,
    );
    _engine = engine;
    _startedAt = clock.now();

    _stateSub = engine.states.listen(_onState);
    _eventSub = engine.events.listen(_onEvent);

    // Fire-and-forget: platform channel can hang in tests without a plugin.
    unawaited(
      WakelockPlus.enable().catchError((Object _) {}),
    );

    state = SessionPlayState(
      itemId: item.id,
      definition: definition,
      dayInLevel: plan.dayInLevel,
      engineState: EngineState.idle,
    );
    engine.start();
  }

  void skipCountdown() {
    _engine?.skipCountdown();
    _logSessionStartIfNeeded();
  }

  void pause() => _engine?.pause();

  void resume() => _engine?.resume();

  void setVibration(bool value) {
    final UserProfile profile = ref.read(userProfileProvider);
    ref.read(userProfileProvider.notifier).save(
          profile.copyWith(vibrationOn: value),
        );
  }

  void setVoice(bool value) {
    final UserProfile profile = ref.read(userProfileProvider);
    ref.read(userProfileProvider.notifier).save(
          profile.copyWith(voiceOn: value),
        );
  }

  /// Exit mid-session without saving a completed row.
  Future<void> exitSession() async {
    final SessionPlayState? current = state;
    final EngineState? before = current?.engineState;
    _engine?.exit();
    final AnalyticsService analytics = ref.read(analyticsServiceProvider);
    await analytics.logEvent(
      'session_exit',
      parameters: <String, Object?>{
        'level': current?.definition.level ?? 0,
        'phase': before?.phaseWord ?? '',
      },
    );
    await _tearDown();
    state = null;
  }

  /// Persists the completed session with [feel] and applies post-session rules.
  Future<SessionSaveResult> saveWithFeel(SessionFeel feel) async {
    final SessionPlayState? current = state;
    final SessionCompleteSummary? summary = current?.summary;
    if (current == null || summary == null) {
      return const SessionSaveResult(goTo: SessionNext.goToday);
    }

    final UserProfile profile = ref.read(userProfileProvider);
    final AppClock clock = ref.read(appClockProvider);
    final DateTime now = clock.now();

    // longestHoldSeconds is the longest prescribed hold completed — the phone
    // cannot measure the real hold duration the user actually achieved.
    final SessionRecord record = SessionRecord(
      startedAt: _startedAt ?? now,
      completedAt: now,
      level: current.definition.level,
      dayInLevel: current.dayInLevel,
      track: profile.track,
      kind: current.definition.kind,
      durationSeconds: summary.durationSeconds,
      longestHoldSeconds: summary.longestHoldSeconds,
      completed: true,
      feel: feel,
    );
    await ref.read(sessionRepositoryProvider).insert(record);
    ref.invalidate(sessionsProvider);
    ref.invalidate(todayPlanProvider);

    final List<SessionRecord> sessions =
        await ref.read(sessionRepositoryProvider).getAll();
    final bool suggestStepDown = PlanRules.shouldSuggestStepDown(sessions);

    // Re-show unlock card after the next session if it was snoozed.
    if (profile.levelUnlockSnoozed) {
      await ref
          .read(userProfileProvider.notifier)
          .save(LevelProgression.clearSnooze(profile));
    }

    final UserProfile fresh = ref.read(userProfileProvider);
    final bool unlockReady = LevelProgression.shouldShowUnlockCard(
      profile: fresh,
      sessions: sessions,
      today: now,
    );
    final int? nextLevel =
        unlockReady ? LevelProgression.offeredLevel(fresh) : null;

    unawaited(
      ref.read(reminderServiceProvider).reschedule().catchError((Object _) {}),
    );

    if (feel == SessionFeel.pain) {
      return SessionSaveResult(
        goTo: SessionNext.goPainHelp,
        suggestStepDown: suggestStepDown,
        levelUnlockReady: unlockReady,
        nextLevel: nextLevel,
      );
    }

    if (summary.wasFirstEver && !profile.paywallSeen) {
      return SessionSaveResult(
        goTo: SessionNext.goPaywall,
        suggestStepDown: suggestStepDown,
        levelUnlockReady: unlockReady,
        nextLevel: nextLevel,
      );
    }

    return SessionSaveResult(
      goTo: SessionNext.goToday,
      suggestStepDown: suggestStepDown,
      levelUnlockReady: unlockReady,
      nextLevel: nextLevel,
    );
  }

  /// Applies relaxation-first after the user confirms on H3.
  Future<void> confirmPainTrack() async {
    final UserProfile profile = ref.read(userProfileProvider);
    final AppClock clock = ref.read(appClockProvider);
    await ref.read(userProfileProvider.notifier).save(
          PlanRules.applyPainTrack(profile, clock.now()),
        );
  }

  Future<void> clear() async {
    await _tearDown();
    state = null;
  }

  void _onState(EngineState next) {
    final SessionPlayState? current = state;
    if (current == null) {
      return;
    }

    if (next.machine != EngineMachineState.countdown &&
        next.machine != EngineMachineState.idle &&
        !next.exited) {
      _logSessionStartIfNeeded();
    }

    if (next.completed && !next.exited && !_completing) {
      _completing = true;
      unawaited(_handleComplete(current, next));
      return;
    }

    state = SessionPlayState(
      itemId: current.itemId,
      definition: current.definition,
      dayInLevel: current.dayInLevel,
      engineState: next,
      sessionStartLogged: current.sessionStartLogged,
      summary: current.summary,
    );
  }

  Future<void> _handleComplete(
    SessionPlayState current,
    EngineState next,
  ) async {
    final AnalyticsService analytics = ref.read(analyticsServiceProvider);
    await analytics.logEvent(
      'session_done',
      parameters: <String, Object?>{
        'level': current.definition.level,
        'seconds': next.elapsedSeconds,
      },
    );

    final List<SessionRecord> prior =
        await ref.read(sessionRepositoryProvider).getAll();
    final bool wasFirstEver =
        !prior.any((SessionRecord s) => s.completed);

    final UserProfile profile = ref.read(userProfileProvider);
    final AppClock clock = ref.read(appClockProvider);
    final DateTime now = clock.now();

    final SessionRecord pending = SessionRecord(
      startedAt: _startedAt ?? now,
      completedAt: now,
      level: current.definition.level,
      dayInLevel: current.dayInLevel,
      track: profile.track,
      kind: current.definition.kind,
      durationSeconds: next.elapsedSeconds,
      longestHoldSeconds: next.longestHoldSeconds,
      completed: true,
    );
    final int streak = PlanRules.streak(
      <SessionRecord>[...prior, pending],
      now,
      restWeekday: profile.restWeekday,
    );

    String? nextLabel;
    try {
      final TodayPlan plan = await ref.read(todayPlanProvider.future);
      for (final TodayItem item in plan.items) {
        if (item.id == current.itemId) {
          continue;
        }
        if (!item.done) {
          nextLabel = item.label;
          break;
        }
      }
    } on Object {
      nextLabel = null;
    }

    unawaited(
      WakelockPlus.disable().catchError((Object _) {}),
    );

    state = SessionPlayState(
      itemId: current.itemId,
      definition: current.definition,
      dayInLevel: current.dayInLevel,
      engineState: next,
      sessionStartLogged: true,
      summary: SessionCompleteSummary(
        durationSeconds: next.elapsedSeconds,
        longestHoldSeconds: next.longestHoldSeconds,
        streak: streak,
        wasFirstEver: wasFirstEver,
        nextLabel: nextLabel,
      ),
    );
  }

  void _onEvent(EngineEvent event) {
    final UserProfile profile = ref.read(userProfileProvider);
    unawaited(
      ref.read(hapticsServiceProvider).playSessionEvent(
            event,
            vibrationOn: profile.vibrationOn,
          ),
    );
    unawaited(_voice.speak(event, voiceOn: profile.voiceOn));
  }

  void _logSessionStartIfNeeded() {
    final SessionPlayState? current = state;
    if (current == null || current.sessionStartLogged) {
      return;
    }
    state = SessionPlayState(
      itemId: current.itemId,
      definition: current.definition,
      dayInLevel: current.dayInLevel,
      engineState: current.engineState,
      sessionStartLogged: true,
      summary: current.summary,
    );
    unawaited(
      ref.read(analyticsServiceProvider).logEvent(
        'session_start',
        parameters: <String, Object?>{
          'level': current.definition.level,
          'session_number_today': current.definition.sessionNumber ?? 1,
        },
      ),
    );
  }

  TodayItem _resolveItem(TodayPlan plan, String? id) {
    if (id != null) {
      for (final TodayItem item in plan.items) {
        if (item.id == id) {
          return item;
        }
      }
    }
    for (final TodayItem item in plan.items) {
      if (!item.done) {
        return item;
      }
    }
    if (plan.items.isNotEmpty) {
      return plan.items.first;
    }
    return const TodayItem(
      id: 'strength_1',
      kind: SessionKind.strengthening,
      label: 'Session 1',
      durationSeconds: 55,
      done: false,
      sessionNumber: 1,
    );
  }

  Future<void> _tearDown() async {
    await _stateSub?.cancel();
    await _eventSub?.cancel();
    _stateSub = null;
    _eventSub = null;
    _engine?.dispose();
    _engine = null;
    await _voice.dispose();
    unawaited(
      WakelockPlus.disable().catchError((Object _) {}),
    );
  }
}

/// Where to navigate after saving a completed session.
enum SessionNext { goToday, goPaywall, goPainHelp }

/// Result of [SessionController.saveWithFeel].
class SessionSaveResult {
  const SessionSaveResult({
    required this.goTo,
    this.suggestStepDown = false,
    this.levelUnlockReady = false,
    this.nextLevel,
  });

  final SessionNext goTo;
  final bool suggestStepDown;
  final bool levelUnlockReady;
  final int? nextLevel;
}

/// Active session controller for S2–S4.
final sessionControllerProvider =
    NotifierProvider<SessionController, SessionPlayState?>(
  SessionController.new,
);
