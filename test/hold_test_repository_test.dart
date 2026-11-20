import 'package:flutter_test/flutter_test.dart';
import 'package:kegelexercisesapp/core/data/repositories/hold_test_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  test('saves results oldest first and reads them back', () async {
    final HoldTestRepository repo =
        HoldTestRepository(await SharedPreferences.getInstance());
    expect(repo.all(), isEmpty);
    await repo.add(HoldTestResult(at: DateTime(2026, 11, 3), seconds: 6.5));
    await repo.add(HoldTestResult(at: DateTime(2026, 11, 1), seconds: 4.2));
    final List<HoldTestResult> all = repo.all();
    expect(all.map((HoldTestResult r) => r.seconds), <double>[4.2, 6.5]);
  });

  test('keeps only the newest results', () async {
    final HoldTestRepository repo =
        HoldTestRepository(await SharedPreferences.getInstance());
    for (int i = 0; i < HoldTestRepository.maxResults + 5; i++) {
      await repo.add(
        HoldTestResult(
          at: DateTime(2026).add(Duration(hours: i)),
          seconds: i.toDouble(),
        ),
      );
    }
    final List<HoldTestResult> all = repo.all();
    expect(all, hasLength(HoldTestRepository.maxResults));
    expect(all.first.seconds, 5);
  });

  test('guide date and clear', () async {
    final HoldTestRepository repo =
        HoldTestRepository(await SharedPreferences.getInstance());
    await repo.markGuideSeen(DateTime(2026, 11, 11, 15, 30));
    expect(repo.guideSeenOn(), DateTime(2026, 11, 11));
    await repo.add(HoldTestResult(at: DateTime(2026, 11, 11), seconds: 3));
    await repo.clear();
    expect(repo.all(), isEmpty);
    expect(repo.guideSeenOn(), isNull);
  });
}
