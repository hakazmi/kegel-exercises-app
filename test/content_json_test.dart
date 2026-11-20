import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('content JSON has reviewedByPhysio false and expected counts', () {
    final Map<String, dynamic> exercises = jsonDecode(
      File('assets/content/exercises.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final Map<String, dynamic> levels = jsonDecode(
      File('assets/content/levels.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final Map<String, dynamic> tracks = jsonDecode(
      File('assets/content/tracks.json').readAsStringSync(),
    ) as Map<String, dynamic>;

    expect(exercises['reviewedByPhysio'], isFalse);
    expect(levels['reviewedByPhysio'], isFalse);
    expect(tracks['reviewedByPhysio'], isFalse);

    expect((exercises['exercises'] as List<dynamic>).length, 17);
    expect((levels['levels'] as List<dynamic>).length, 5);
    expect((tracks['tracks'] as List<dynamic>).length, 5);

    for (final dynamic level in levels['levels'] as List<dynamic>) {
      expect((level as Map<String, dynamic>)['dailyBreathingSec'], 120);
    }
  });
}
