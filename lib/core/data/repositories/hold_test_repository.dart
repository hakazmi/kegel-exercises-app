import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// One saved pelvic floor hold test: how long the squeeze was held.
class HoldTestResult {
  const HoldTestResult({
    required this.at,
    required this.seconds,
    this.syncId,
  });

  final DateTime at;

  /// Hold length in seconds (one decimal).
  final double seconds;

  /// Permanent cloud id (UUID).
  final String? syncId;

  Map<String, Object> toJson() => <String, Object>{
    'at': at.toIso8601String(),
    's': seconds,
    if (syncId != null && syncId!.isNotEmpty) 'syncId': syncId!,
  };

  static HoldTestResult? fromJson(Object? raw) {
    if (raw is! Map) {
      return null;
    }
    final Map<String, dynamic> map = Map<String, dynamic>.from(raw);
    final DateTime? at = DateTime.tryParse('${map['at']}');
    final Object? s = map['s'];
    if (at == null || s is! num) {
      return null;
    }
    final String? syncId = map['syncId'] as String?;
    return HoldTestResult(
      at: at,
      seconds: s.toDouble(),
      syncId: syncId,
    );
  }
}

/// Saved hold tests and the "technique guide seen" date.
class HoldTestRepository {
  HoldTestRepository(this._prefs);

  static const String _resultsKey = 'hold_tests_v1';
  static const String _guideKey = 'kegel_guide_seen_on_v1';
  static const Uuid _uuid = Uuid();

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

  Future<HoldTestResult> add(HoldTestResult result) async {
    final HoldTestResult withId = result.syncId == null || result.syncId!.isEmpty
        ? HoldTestResult(
            at: result.at,
            seconds: result.seconds,
            syncId: _uuid.v4(),
          )
        : result;
    final List<HoldTestResult> list = <HoldTestResult>[...all(), withId];
    final List<HoldTestResult> kept = list.length > maxResults
        ? list.sublist(list.length - maxResults)
        : list;
    await _prefs.setString(
      _resultsKey,
      jsonEncode(<Map<String, Object>>[for (final r in kept) r.toJson()]),
    );
    return withId;
  }

  /// Ensures every stored result has a syncId (one-time backfill).
  Future<List<String>> ensureSyncIds() async {
    final List<HoldTestResult> list = all();
    final List<String> newIds = <String>[];
    bool changed = false;
    final List<HoldTestResult> next = <HoldTestResult>[];
    for (final HoldTestResult r in list) {
      if (r.syncId == null || r.syncId!.isEmpty) {
        final String id = _uuid.v4();
        next.add(HoldTestResult(at: r.at, seconds: r.seconds, syncId: id));
        newIds.add(id);
        changed = true;
      } else {
        next.add(r);
      }
    }
    if (changed) {
      await _prefs.setString(
        _resultsKey,
        jsonEncode(<Map<String, Object>>[for (final r in next) r.toJson()]),
      );
    }
    return newIds;
  }

  /// When the technique guide was last finished, if ever.
  DateTime? guideSeenOn() {
    final String? raw = _prefs.getString(_guideKey);
    return raw == null ? null : DateTime.tryParse(raw);
  }

  /// Stores the exact time the guide was finished.
  Future<void> markGuideSeen(DateTime at) =>
      _prefs.setString(_guideKey, at.toIso8601String());

  Future<void> clear() async {
    await _prefs.remove(_resultsKey);
    await _prefs.remove(_guideKey);
  }

  Future<void> replaceAll(List<HoldTestResult> results) async {
    await _prefs.setString(
      _resultsKey,
      jsonEncode(<Map<String, Object>>[for (final r in results) r.toJson()]),
    );
  }
}
