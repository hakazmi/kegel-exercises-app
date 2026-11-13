import '../domain/enums.dart';
import '../domain/session_record.dart';
import '../domain/user_profile.dart';
import '../time/app_clock.dart';

/// Pure plan rules. No Flutter imports.
///
/// Rest day comes from [UserProfile.restWeekday] (default Sunday). See
/// docs/decisions.md. Rest never applies before the first completed session.
abstract final class PlanRules {
  static const int maxStrengtheningPerDay = 3;
  static const int breathingDurationSeconds = 120;
  static const int checkInBaselineSessionCount = 3;
  static const int checkInIntervalDays = 28;
  static const int levelUnlockWindowDays = 7;
  static const int levelUnlockMinCompletedDays = 5;
  static const int relaxationFirstWeeks = 2;

  /// Calendar length of the relaxation-first track (spec: 2 weeks).
  static int get relaxationFirstDays => relaxationFirstWeeks * 7;

  /// Default ISO weekday for rest day: 7 = Sunday.
  static const int defaultRestWeekday = DateTime.sunday;

  /// Whether [date] falls on the configured rest weekday (ignores first-session rule).
  static bool isConfiguredRestWeekday(DateTime date, int restWeekday) =>
      date.weekday == restWeekday;

  /// Active rest day for the plan: configured weekday, but never before the
  /// first completed session (so install-on-rest-day still gets Level 1 Day 1).
  static bool isRestDay({
    required DateTime date,
    required int restWeekday,
    required List<SessionRecord> sessions,
  }) {
    if (!_hasCompletedSession(sessions)) {
      return false;
    }
    return isConfiguredRestWeekday(date, restWeekday);
  }

  static bool _hasCompletedSession(List<SessionRecord> sessions) {
    return sessions.any((SessionRecord s) => s.completed);
  }

  /// A calendar day counts for streak / unlock when ≥1 completed session exists.
  static bool dayCounts(DateTime day, List<SessionRecord> sessions) {
    final DateTime d = dateOnly(day);
    return sessions.any(
      (SessionRecord s) =>
          s.completed && isSameDay(dateOnly(s.completedAt ?? s.startedAt), d),
    );
  }

  /// Completed calendar days (date-only) from history, newest last.
  static List<DateTime> completedDays(List<SessionRecord> sessions) {
    final Set<DateTime> days = <DateTime>{};
    for (final SessionRecord s in sessions) {
      if (!s.completed) {
        continue;
      }
      days.add(dateOnly(s.completedAt ?? s.startedAt));
    }
    final List<DateTime> sorted = days.toList()..sort();
    return sorted;
  }

  /// Current streak ending on [today] (inclusive). Breaks on a missed non-rest day.
  /// Rest days do not break the streak if the prior training day was completed.
  static int streak(
    List<SessionRecord> sessions,
    DateTime today, {
    int restWeekday = defaultRestWeekday,
  }) {
    final Set<DateTime> done = completedDays(sessions).toSet();
    if (done.isEmpty) {
      return 0;
    }
    bool rest(DateTime d) => isRestDay(
          date: d,
          restWeekday: restWeekday,
          sessions: sessions,
        );
    DateTime cursor = dateOnly(today);
    // If today is not done yet and is a rest day, start from yesterday.
    if (!done.contains(cursor) && rest(cursor)) {
      cursor = cursor.subtract(const Duration(days: 1));
    }
    if (!done.contains(cursor) && !rest(cursor)) {
      // Allow streak to count through "today not yet done" by starting yesterday.
      cursor = cursor.subtract(const Duration(days: 1));
    }
    int count = 0;
    while (true) {
      if (rest(cursor)) {
        cursor = cursor.subtract(const Duration(days: 1));
        continue;
      }
      if (!done.contains(cursor)) {
        break;
      }
      count += 1;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return count;
  }

  /// Level day index counted from completed training days in this level (not calendar).
  /// Rest days never advance [dayInLevel]. Missed calendar days do not rewind it.
  /// Relaxation-first counts days with a completed relaxation or breathing session.
  static int dayInLevel({
    required UserProfile profile,
    required List<SessionRecord> sessions,
  }) {
    final bool relaxationOnly = profile.track == TrackId.relaxationFirst;
    final int completedTrainingDays = sessions
        .where((SessionRecord s) {
          if (!s.completed) {
            return false;
          }
          if (relaxationOnly) {
            return s.kind == SessionKind.relaxation ||
                s.kind == SessionKind.breathing;
          }
          return s.level == profile.level &&
              s.kind == SessionKind.strengthening;
        })
        .map((SessionRecord s) => dateOnly(s.completedAt ?? s.startedAt))
        .toSet()
        .length;

    // dayInLevel is 1-based for the next/current plan day; min 1.
    return completedTrainingDays + 1;
  }

  /// True when ≥5 of the last 7 calendar days have a completed session at [level].
  static bool canUnlockNextLevel({
    required int level,
    required List<SessionRecord> sessions,
    required DateTime today,
  }) {
    if (level >= 5) {
      return false;
    }
    final DateTime end = dateOnly(today);
    int completed = 0;
    for (int i = 0; i < levelUnlockWindowDays; i++) {
      final DateTime day = end.subtract(Duration(days: i));
      final bool has = sessions.any(
        (SessionRecord s) =>
            s.completed &&
            s.level == level &&
            isSameDay(dateOnly(s.completedAt ?? s.startedAt), day),
      );
      if (has) {
        completed += 1;
      }
    }
    return completed >= levelUnlockMinCompletedDays;
  }

  /// Suggest step-down after two consecutive mild-discomfort answers. Never auto-apply.
  static bool shouldSuggestStepDown(List<SessionRecord> sessions) {
    final List<SessionRecord> completed = sessions
        .where(
          (SessionRecord s) =>
              s.completed &&
              s.kind == SessionKind.strengthening &&
              s.feel != null,
        )
        .toList()
      ..sort(
        (SessionRecord a, SessionRecord b) =>
            (a.completedAt ?? a.startedAt).compareTo(b.completedAt ?? b.startedAt),
      );
    if (completed.length < 2) {
      return false;
    }
    final SessionRecord last = completed[completed.length - 1];
    final SessionRecord prev = completed[completed.length - 2];
    return last.feel == SessionFeel.mildDiscomfort &&
        prev.feel == SessionFeel.mildDiscomfort;
  }

  /// Manual step down by one level (minimum 1).
  static int stepDownLevel(int level) => level <= 1 ? 1 : level - 1;

  /// Repeat stays on the same level (caller resets levelStartedOn / day progress).
  static int repeatLevel(int level) => level;

  /// Strengthening sessions completed on [day].
  static int strengtheningCountOnDay(
    List<SessionRecord> sessions,
    DateTime day,
  ) {
    final DateTime d = dateOnly(day);
    return sessions
        .where(
          (SessionRecord s) =>
              s.completed &&
              s.kind == SessionKind.strengthening &&
              isSameDay(dateOnly(s.completedAt ?? s.startedAt), d),
        )
        .length;
  }

  /// Daily strengthening cap reached.
  static bool dailyCapReached(List<SessionRecord> sessions, DateTime day) {
    return strengtheningCountOnDay(sessions, day) >= maxStrengtheningPerDay;
  }

  /// Switch profile to relaxation-first after pain.
  static UserProfile applyPainTrack(UserProfile profile, DateTime now) {
    return profile.copyWith(
      track: TrackId.relaxationFirst,
      level: 1,
      levelStartedOn: dateOnly(now),
      safetyFlags: profile.safetyFlags.copyWith(pain: true),
    );
  }

  /// Catheter blocks all exercises.
  static bool isCatheterBlocked(UserProfile profile) =>
      profile.safetyFlags.catheter;

  /// Relaxation-first: no strengthening.
  static bool isRelaxationOnly(UserProfile profile) =>
      profile.track == TrackId.relaxationFirst;

  /// Baseline check-in after the 3rd completed session overall, then every 4 weeks.
  static bool isCheckInDue({
    required List<SessionRecord> sessions,
    required List<CheckInRecord> checkIns,
    required DateTime today,
  }) {
    final int completedCount =
        sessions.where((SessionRecord s) => s.completed).length;
    if (completedCount < checkInBaselineSessionCount) {
      return false;
    }
    if (checkIns.isEmpty) {
      return completedCount >= checkInBaselineSessionCount;
    }
    final List<CheckInRecord> sorted = List<CheckInRecord>.from(checkIns)
      ..sort((CheckInRecord a, CheckInRecord b) => a.date.compareTo(b.date));
    final DateTime last = dateOnly(sorted.last.date);
    final DateTime due = last.add(const Duration(days: checkInIntervalDays));
    return !dateOnly(today).isBefore(due);
  }

  /// Required strengthening slots for today (third is optional when sessionsPerDay == 3).
  static int requiredStrengtheningSlots(int sessionsPerDay) {
    final int clamped = sessionsPerDay.clamp(1, 3);
    if (clamped == 3) {
      return 2;
    }
    return clamped;
  }

  static int plannedStrengtheningSlots(int sessionsPerDay) =>
      sessionsPerDay.clamp(1, 3);
}
