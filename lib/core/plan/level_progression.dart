import '../domain/session_record.dart';
import '../domain/user_profile.dart';
import '../time/app_clock.dart';
import 'plan_rules.dart';

/// Result of tapping "Start Level N".
enum LevelStartOutcome {
  /// Free user trying Levels 2–5 — open paywall, level unchanged.
  needsPremium,

  /// Level advanced (premium, or destination Level 1).
  advanced,
}

/// Pure helpers for the Level unlocked offer (never silent).
abstract final class LevelProgression {
  /// Whether the unlock rule is met for the current level.
  static bool isUnlockReady({
    required UserProfile profile,
    required List<SessionRecord> sessions,
    required DateTime today,
    int? daySpan,
  }) {
    return PlanRules.canUnlockNextLevel(
      level: profile.level,
      sessions: sessions,
      today: today,
      track: profile.track,
      sessionsPerDay: profile.sessionsPerDay,
      daySpan: daySpan,
    );
  }

  /// Show the unlock card on Today / Done when ready and not snoozed.
  static bool shouldShowUnlockCard({
    required UserProfile profile,
    required List<SessionRecord> sessions,
    required DateTime today,
    int? daySpan,
  }) {
    if (profile.levelUnlockSnoozed) {
      return false;
    }
    return isUnlockReady(
      profile: profile,
      sessions: sessions,
      today: today,
      daySpan: daySpan,
    );
  }

  /// Next level to offer, or null if none.
  static int? offeredLevel(UserProfile profile) =>
      PlanRules.nextLevel(profile.level);

  /// Profile after "Stay on this level a bit longer".
  static UserProfile snooze(UserProfile profile) =>
      profile.copyWith(levelUnlockSnoozed: true);

  /// Clear snooze after a completed session so the card can return.
  static UserProfile clearSnooze(UserProfile profile) =>
      profile.copyWith(levelUnlockSnoozed: false);

  /// Advance to [nextLevel] (caller already gated premium). Resets day progress.
  static UserProfile advanceTo({
    required UserProfile profile,
    required int nextLevel,
    required DateTime now,
  }) {
    return profile.copyWith(
      level: nextLevel.clamp(1, 5),
      levelStartedOn: dateOnly(now),
      levelUnlockSnoozed: false,
    );
  }

  /// Decide Start Level N without mutating — premium gate for Levels 2–5.
  static LevelStartOutcome startOutcome({
    required int nextLevel,
    required bool isPremium,
  }) {
    if (nextLevel >= 2 && !isPremium) {
      return LevelStartOutcome.needsPremium;
    }
    return LevelStartOutcome.advanced;
  }
}
