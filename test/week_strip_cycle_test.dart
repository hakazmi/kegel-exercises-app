import 'package:flutter_test/flutter_test.dart';
import 'package:kegelexercisesapp/core/domain/user_profile.dart';
import 'package:kegelexercisesapp/features/home/week_strip_builder.dart';

void main() {
  // Joined on Wednesday 2026-11-18 → rest day is Tuesday.
  final DateTime start = DateTime(2026, 11, 18);

  test('first plan week starts on the join day and ends on the rest day', () {
    final DateTime first = weekStripStart(today: start, planStart: start);
    expect(first, start);
    final DateTime last = first.add(const Duration(days: 6));
    expect(last.weekday, restWeekdayForStart(start));
    expect(planWeekNumber(today: start, planStart: start), 1);
  });

  test('stays on the same 7 days until the rest day has passed', () {
    final DateTime restDay = DateTime(2026, 11, 24); // Tuesday, day 7
    expect(weekStripStart(today: restDay, planStart: start), start);
    expect(planWeekNumber(today: restDay, planStart: start), 1);
  });

  test('rolls to the next 7 days after day 7', () {
    final DateTime day8 = DateTime(2026, 11, 25);
    expect(weekStripStart(today: day8, planStart: start), day8);
    expect(planWeekNumber(today: day8, planStart: start), 2);
    final DateTime day20 = DateTime(2026, 12, 7, 22, 30);
    expect(
      weekStripStart(today: day20, planStart: start),
      DateTime(2026, 12, 2),
    );
    expect(planWeekNumber(today: day20, planStart: start), 3);
  });

  test('without a plan start the strip falls back to Monday–Sunday', () {
    final DateTime wednesday = DateTime(2026, 11, 18, 9);
    expect(
      weekStripStart(today: wednesday, planStart: null),
      DateTime(2026, 11, 16),
    );
    expect(planWeekNumber(today: wednesday, planStart: null), isNull);
  });
}
