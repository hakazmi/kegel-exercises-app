import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// One saved pelvic floor hold test: how long the squeeze was held.
class HoldTestResult {
  const HoldTestResult({required this.at, required this.seconds});

  final DateTime at;

  /// Hold length in seconds (one decimal).
  final double seconds;

  Map<String, Object> toJson() => <String, Object>{
        'at': at.toIso8601String(),
        's': seconds,
      };

  static HoldTestResult? fromJson(Object? raw) {
    if (raw is! Map<String, dynamic>) {
      return null;
    }
    final DateTime? at = DateTime.tryParse('${raw['at']}');
    final Object? s = raw['s'];
    if (at == null || s is! num) {
      return null;
    }
    return HoldTestResult(at: at, seconds: s.toDouble());
  }
}

/// Saved hold tests and the "technique guide seen" date. On-device only
/// (SharedPreferences); never sent to analytics.
class HoldTestRepository {
  HoldTestRepository(this._prefs);

  static const String _resultsKey = 'hold_tests_v1';
  static const String _guideKey = 'kegel_guide_seen_on_v1';

  /// Older results beyond this are dropped to keep storage small.
  static const int maxResults = 200;

  final SharedPreferences _prefs;

  List<HoldTestResult> all() {
    final String? raw = _prefs.getString(_resultsKey);
    if (raw == null || raw.isEmpty) {
      return const <HoldTestResult>[];
    }
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! List) {
        return const <HoldTestResult>[];
      }
      return <HoldTestResult>[
        for (final Object? e in decoded) ?HoldTestResult.fromJson(e),
      ]..sort((HoldTestResult a, HoldTestResult b) => a.at.compareTo(b.at));
    } on FormatException {
      return const <HoldTestResult>[];
    }
  }

  Future<void> add(HoldTestResult result) async {
    final List<HoldTestResult> list = <HoldTestResult>[...all(), result];
    final List<HoldTestResult> kept = list.length > maxResults
        ? list.sublist(list.length - maxResults)
        : list;
    await _prefs.setString(
      _resultsKey,
      jsonEncode(<Map<String, Object>>[for (final r in kept) r.toJson()]),
    );
  }

  /// Day the technique guide was last finished (date only), if ever.
  DateTime? guideSeenOn() {
    final String? raw = _prefs.getString(_guideKey);
    return raw == null ? null : DateTime.tryParse(raw);
  }

  Future<void> markGuideSeen(DateTime day) =>
      _prefs.setString(_guideKey, DateTime(day.year, day.month, day.day)
          .toIso8601String());

  Future<void> clear() async {
    await _prefs.remove(_resultsKey);
    await _prefs.remove(_guideKey);
  }
}
