import '../domain/session_record.dart';
import '../time/app_clock.dart';
import 'plan_rules.dart';

/// Pure helpers for check-in scheduling, week labels and doctor hint.
abstract final class CheckInRules {
  static const int doctorHintAfterWeeks = 8;
  static const int minScore = 1;
  static const int maxScore = 5;

  /// Weeks since the baseline check-in (0 = baseline week).
  static int weekIndex({
    required DateTime baselineDate,
    required DateTime at,
  }) {
    final DateTime start = dateOnly(baselineDate);
    final DateTime day = dateOnly(at);
    if (day.isBefore(start)) {
      return 0;
    }
    return day.difference(start).inDays ~/ 7;
  }

  /// Sorted ascending by date.
  static List<CheckInRecord> sorted(List<CheckInRecord> checkIns) {
    final List<CheckInRecord> copy = List<CheckInRecord>.from(checkIns)
      ..sort((CheckInRecord a, CheckInRecord b) => a.date.compareTo(b.date));
    return copy;
  }

  /// Free users only see the baseline row in history UI.
  static List<CheckInRecord> visibleHistory({
    required List<CheckInRecord> checkIns,
    required bool isPremium,
  }) {
    final List<CheckInRecord> ordered = sorted(checkIns);
    if (ordered.isEmpty) {
      return const <CheckInRecord>[];
    }
    if (isPremium) {
      return ordered;
    }
    return <CheckInRecord>[ordered.first];
  }

  /// Spec: still at the lowest scale value after 8 weeks from baseline.
  static bool shouldSuggestDoctor({
    required List<CheckInRecord> checkIns,
    required DateTime today,
  }) {
    final List<CheckInRecord> ordered = sorted(checkIns);
    if (ordered.isEmpty) {
      return false;
    }
    final CheckInRecord baseline = ordered.first;
    final int weeks = weekIndex(baselineDate: baseline.date, at: today);
    if (weeks < doctorHintAfterWeeks) {
      return false;
    }
    return ordered.last.score == minScore;
  }

  /// Whether a new check-in should be offered on [today].
  static bool isDue({
    required List<SessionRecord> sessions,
    required List<CheckInRecord> checkIns,
    required DateTime today,
  }) {
    return PlanRules.isCheckInDue(
      sessions: sessions,
      checkIns: checkIns,
      today: today,
    );
  }
}
