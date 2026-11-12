import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kegelexercisesapp/app/app.dart';
import 'package:kegelexercisesapp/core/constants/app_constants.dart';
import 'package:kegelexercisesapp/core/data/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app boots to welcome placeholder', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const KegelApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('O1'), findsWidgets);
    expect(find.textContaining('Welcome'), findsWidgets);
    expect(AppConstants.displayName, 'Kegel Exercises');
  });
}
