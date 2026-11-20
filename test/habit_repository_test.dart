import 'package:flutter_test/flutter_test.dart';
import 'package:kegelexercisesapp/core/data/database/app_database.dart';
import 'package:kegelexercisesapp/core/data/repositories/habit_repository.dart';

void main() {
  late AppDatabase db;
  late HabitRepository habits;

  setUp(() {
    db = AppDatabase.memory();
    habits = HabitRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('toggle ticks and unticks the same habit', () async {
    final DateTime day = DateTime(2026, 11, 17, 15, 30);
    expect(await habits.doneHabitIdsOn(day), isEmpty);

    expect(
      await habits.toggle(habitId: 'urge_control_squeeze', day: day),
      isTrue,
    );
    expect(
      await habits.doneHabitIdsOn(day),
      <String>{'urge_control_squeeze'},
    );

    expect(
      await habits.toggle(habitId: 'urge_control_squeeze', day: day),
      isFalse,
    );
    expect(await habits.doneHabitIdsOn(day), isEmpty);
  });
}
