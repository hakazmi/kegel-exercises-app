import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kegelexercisesapp/app/app.dart';
import 'package:kegelexercisesapp/core/constants/app_constants.dart';

void main() {
  testWidgets('app boots to welcome placeholder', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: KegelApp()));
    await tester.pumpAndSettle();

    expect(find.textContaining('O1'), findsWidgets);
    expect(find.textContaining('Welcome'), findsWidgets);
    expect(AppConstants.displayName, 'Kegel Exercises');
  });
}
