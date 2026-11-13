/// Injectable clock for plan rules and tests.
abstract class AppClock {
  DateTime now();
}

/// System wall clock.
class SystemClock implements AppClock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();
}

/// Mutable fake clock for unit tests.
class FakeClock implements AppClock {
  FakeClock(DateTime initial) : _now = initial;

  DateTime _now;

  @override
  DateTime now() => _now;

  void set(DateTime value) => _now = value;

  void add(Duration duration) => _now = _now.add(duration);
}

/// System clock shifted by a fixed [offset] (debug day controls).
class OffsetClock implements AppClock {
  const OffsetClock(this.offset);

  final Duration offset;

  @override
  DateTime now() => DateTime.now().add(offset);
}

/// Calendar date helpers (local, date-only).
DateTime dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
