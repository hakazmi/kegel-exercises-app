import '../domain/enums.dart';
import '../domain/session_record.dart';
import '../domain/user_profile.dart';
import '../time/app_clock.dart';
import 'plan_rules.dart';

/// Aggregated Progress-tab numbers from session history (pure Dart).
class ProgressStats {
  const ProgressStats({
    required this.streakDays,
    required this.sessionsThisWeek,
    required this.longestHoldSeconds,
    required this.level,
    required this.dayInLevel,
    required this.track,
    required this.completedDays,
  });

  final int streakDays;
  final int sessionsThisWeek;
  final int longestHoldSeconds;
  final int level;
  final int dayInLevel;
  final TrackId track;
  final Set<DateTime> completedDays;

  bool get isRelaxationFirst => track == TrackId.relaxationFirst;

  /// Builds stats for [today] from [sessions] and [profile].
  static ProgressStats from({
    required UserProfile profile,
    required List<SessionRecord> sessions,
    required DateTime today,
  }) {
    final DateTime todayDate = dateOnly(today);
    final DateTime weekStart = todayDate.subtract(
      Duration(days: todayDate.weekday - DateTime.monday),
    );
    final DateTime weekEnd = weekStart.add(const Duration(days: 6));

    final List<SessionRecord> planSessions = PlanRules.sessionsForActivePlan(
      profile: profile,
      sessions: sessions,
    );
    int sessionsThisWeek = 0;
    int longestHold = 0;
    final Set<DateTime> completed = <DateTime>{};

    for (final SessionRecord session in planSessions) {
      if (!session.completed) {
        continue;
      }
      final DateTime day = dateOnly(session.completedAt ?? session.startedAt);
      completed.add(day);
      // Count every completed session this calendar week (Mon–Sun).
      if (!day.isBefore(weekStart) && !day.isAfter(weekEnd)) {
        sessionsThisWeek += 1;
      }
      // Longest prescribed hold completed in a finished strengthening session.
      if (session.kind == SessionKind.strengthening &&
          session.longestHoldSeconds > longestHold) {
        longestHold = session.longestHoldSeconds;
      }
    }

    return ProgressStats(
      streakDays: PlanRules.streak(
        planSessions,
        todayDate,
        restWeekday: profile.restWeekday,
      ),
      sessionsThisWeek: sessionsThisWeek,
      longestHoldSeconds: longestHold,
      level: profile.level,
      dayInLevel: PlanRules.dayInLevel(
        profile: profile,
        sessions: planSessions,
      ),
      track: profile.track,
      completedDays: completed,
    );
  }
}
