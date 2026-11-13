import 'package:flutter_test/flutter_test.dart';
import 'package:kegelexercisesapp/features/session/session_time_format.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('phase remaining formats 0, 9, 59, 60, 114, 120',
      (WidgetTester tester) async {
    const List<(int, String)> cases = <(int, String)>[
      (0, '0'),
      (9, '9'),
      (59, '59'),
      (60, '1:00'),
      (114, '1:54'),
      (120, '2:00'),
    ];

    for (final (int seconds, String expected) in cases) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Text(formatPhaseSecondsRemaining(seconds)),
          ),
        ),
      );
      expect(
        find.text(expected),
        findsOneWidget,
        reason: '$seconds → $expected',
      );
    }
  });
}
