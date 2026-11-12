import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kegelexercisesapp/app/app.dart';
import 'package:kegelexercisesapp/app/router.dart';
import 'package:kegelexercisesapp/core/data/providers.dart';
import 'package:kegelexercisesapp/core/domain/enums.dart';
import 'package:kegelexercisesapp/core/domain/user_profile.dart';
import 'package:kegelexercisesapp/features/onboarding/o3_safety_screen.dart';
import 'package:kegelexercisesapp/features/onboarding/onboarding_controller.dart';
import 'package:kegelexercisesapp/features/onboarding/onboarding_state.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> _container() async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
  );
}

Future<void> _pumpApp(WidgetTester tester, ProviderContainer container) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const KegelApp(),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    80,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('O1 Get started stays disabled until 18+ is ticked',
      (WidgetTester tester) async {
    final ProviderContainer container = await _container();
    addTearDown(container.dispose);
    await _pumpApp(tester, container);

    expect(find.text('Get started'), findsOneWidget);
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();
    expect(find.text('What do you want to work on?'), findsNothing);

    container.read(onboardingControllerProvider.notifier).setAcceptedAge(true);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();
    expect(find.text('What do you want to work on?'), findsOneWidget);
  });

  test('O3 none is a valid safety selection', () {
    final OnboardingDraft draft = const OnboardingDraft().copyWith(
      noneOfThese: true,
    );
    expect(draft.safetySelectionValid, isTrue);
    expect(draft.resolveTrack(), TrackId.generalBladder);
  });

  test('O3 pain sets relaxation-first track', () {
    final OnboardingDraft draft = const OnboardingDraft().copyWith(
      goal: Goal.bladderControl,
      pain: true,
    );
    expect(draft.hasPain, isTrue);
    expect(draft.resolveTrack(), TrackId.relaxationFirst);
  });

  test('O3 surgery requires confirm before continuing', () {
    final OnboardingDraft unconfirmed = const OnboardingDraft().copyWith(
      recentSurgery: true,
      surgeryConfirmed: false,
    );
    expect(unconfirmed.safetySelectionValid, isTrue);
    expect(unconfirmed.surgeryConfirmed, isFalse);

    final OnboardingDraft confirmed = unconfirmed.copyWith(
      surgeryConfirmed: true,
    );
    expect(confirmed.surgeryConfirmed, isTrue);
  });

  Future<void> openSafety(
    WidgetTester tester,
    ProviderContainer container,
  ) async {
    final OnboardingController controller =
        container.read(onboardingControllerProvider.notifier);
    controller.setAcceptedAge(true);
    controller.setGoal(Goal.bladderControl);
    container.read(routerProvider).go(AppRoutes.safety);
    await tester.pumpAndSettle();
  }

  const String painMessage =
      'Squeezing exercises can make pain worse. We will start you with relaxation only. Please see a doctor or pelvic floor physiotherapist.';
  const String catheterMessage =
      'Do not do these exercises with a catheter in place. Come back when it is removed and your care team says you can start.';
  const String surgeryMessage =
      'Check with your surgeon or physiotherapist before starting.';

  testWidgets('O3 none continues to experience via UI',
      (WidgetTester tester) async {
    final ProviderContainer container = await _container();
    addTearDown(container.dispose);
    await _pumpApp(tester, container);
    await openSafety(tester, container);

    await _tapVisible(tester, find.text('None of these'));
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Have you done Kegel exercises before?'), findsOneWidget);
  });

  testWidgets(
      'O3 pelvic pain shows pinned message that clears when unticked',
      (WidgetTester tester) async {
    final ProviderContainer container = await _container();
    addTearDown(container.dispose);
    await _pumpApp(tester, container);
    await openSafety(tester, container);

    await _tapVisible(tester, find.text('Pelvic, groin or genital pain'));
    expect(find.text(painMessage).hitTestable(), findsOneWidget);
    expect(
      container.read(onboardingControllerProvider).resolveTrack(),
      TrackId.relaxationFirst,
    );

    await _tapVisible(tester, find.text('Pelvic, groin or genital pain'));
    expect(find.text(painMessage), findsNothing);

    await _tapVisible(tester, find.text('Pelvic, groin or genital pain'));
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Have you done Kegel exercises before?'), findsOneWidget);
  });

  testWidgets(
      'O3 sexual pain shows pinned message that clears when unticked',
      (WidgetTester tester) async {
    final ProviderContainer container = await _container();
    addTearDown(container.dispose);
    await _pumpApp(tester, container);
    await openSafety(tester, container);

    await _tapVisible(tester, find.text('Pain with erection or ejaculation'));
    expect(find.text(painMessage).hitTestable(), findsOneWidget);
    expect(
      container.read(onboardingControllerProvider).resolveTrack(),
      TrackId.relaxationFirst,
    );

    await _tapVisible(tester, find.text('Pain with erection or ejaculation'));
    expect(find.text(painMessage), findsNothing);
  });

  testWidgets(
      'O3 catheter shows pinned message that clears when unticked',
      (WidgetTester tester) async {
    final ProviderContainer container = await _container();
    addTearDown(container.dispose);
    await _pumpApp(tester, container);
    await openSafety(tester, container);

    await _tapVisible(
      tester,
      find.text('A urinary catheter in place right now'),
    );
    expect(find.text(catheterMessage).hitTestable(), findsOneWidget);
    expect(find.text('Continue to Today'), findsOneWidget);

    await _tapVisible(
      tester,
      find.text('A urinary catheter in place right now'),
    );
    expect(find.text(catheterMessage), findsNothing);
    expect(find.text('Next'), findsOneWidget);

    await _tapVisible(
      tester,
      find.text('A urinary catheter in place right now'),
    );
    await tester.tap(find.text('Continue to Today'));
    await tester.pumpAndSettle();

    final UserProfile profile = container.read(userProfileProvider);
    expect(profile.onboardingDone, isTrue);
    expect(profile.safetyFlags.catheter, isTrue);
    expect(find.textContaining('H1'), findsWidgets);

    final GoRouter router = container.read(routerProvider);
    router.go(AppRoutes.welcome);
    await tester.pumpAndSettle();
    expect(find.textContaining('H1'), findsWidgets);
  });

  testWidgets(
      'O3 surgery shows pinned message and Next needs I understand',
      (WidgetTester tester) async {
    final ProviderContainer container = await _container();
    addTearDown(container.dispose);
    await _pumpApp(tester, container);
    await openSafety(tester, container);

    await _tapVisible(tester, find.text('Surgery in the last 3 months'));
    expect(find.text(surgeryMessage).hitTestable(), findsOneWidget);
    expect(find.text('I understand'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Do any of these apply to you?'), findsOneWidget);

    await tester.tap(find.text('I understand'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Have you done Kegel exercises before?'), findsOneWidget);
  });

  testWidgets('O3 surgery message clears and confirm resets when unticked',
      (WidgetTester tester) async {
    final ProviderContainer container = await _container();
    addTearDown(container.dispose);
    await _pumpApp(tester, container);
    await openSafety(tester, container);

    await _tapVisible(tester, find.text('Surgery in the last 3 months'));
    await tester.tap(find.text('I understand'));
    await tester.pumpAndSettle();
    expect(container.read(onboardingControllerProvider).surgeryConfirmed, isTrue);

    await _tapVisible(tester, find.text('Surgery in the last 3 months'));
    expect(find.text(surgeryMessage), findsNothing);
    expect(find.text('I understand'), findsNothing);
    expect(
      container.read(onboardingControllerProvider).surgeryConfirmed,
      isFalse,
    );
  });

  testWidgets(
      'O3 catheter overrides pain and surgery messages with enabled button',
      (WidgetTester tester) async {
    final ProviderContainer container = await _container();
    addTearDown(container.dispose);
    await _pumpApp(tester, container);
    await openSafety(tester, container);

    final OnboardingController controller =
        container.read(onboardingControllerProvider.notifier);
    controller.toggleSafety(pain: true);
    controller.toggleSafety(recentSurgery: true);
    controller.toggleSafety(catheter: true);
    await tester.pumpAndSettle();

    expect(find.text(catheterMessage).hitTestable(), findsOneWidget);
    expect(find.text(painMessage), findsNothing);
    expect(find.text(surgeryMessage), findsNothing);
    expect(find.text('I understand'), findsNothing);
    expect(find.text('Continue to Today'), findsOneWidget);

    await tester.tap(find.text('Continue to Today'));
    await tester.pumpAndSettle();
    final UserProfile profile = container.read(userProfileProvider);
    expect(profile.safetyFlags.catheter, isTrue);
    expect(profile.safetyFlags.pain, isTrue);
    expect(profile.safetyFlags.recentSurgery, isTrue);
  });

  testWidgets(
      'O3 pain plus surgery shows both messages and fixed confirm row',
      (WidgetTester tester) async {
    final ProviderContainer container = await _container();
    addTearDown(container.dispose);
    await _pumpApp(tester, container);
    await openSafety(tester, container);

    final OnboardingController controller =
        container.read(onboardingControllerProvider.notifier);
    controller.toggleSafety(pain: true);
    controller.toggleSafety(recentSurgery: true);
    await tester.pumpAndSettle();

    expect(find.text(painMessage), findsOneWidget);
    expect(find.text(surgeryMessage), findsOneWidget);
    expect(find.text('I understand').hitTestable(), findsOneWidget);

    // Panel may scroll when both messages are tall; bring surgery into view.
    final Finder panelScrollables = find.byType(Scrollable);
    if (find.text(surgeryMessage).hitTestable().evaluate().isEmpty &&
        panelScrollables.evaluate().length > 1) {
      await tester.scrollUntilVisible(
        find.text(surgeryMessage),
        40,
        scrollable: panelScrollables.at(1),
      );
      await tester.pumpAndSettle();
    }
    expect(find.text(surgeryMessage).hitTestable(), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Do any of these apply to you?'), findsOneWidget);

    await tester.tap(find.text('I understand'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Have you done Kegel exercises before?'), findsOneWidget);
  });

  testWidgets('O3 keeps at least three option rows visible at 360x640',
      (WidgetTester tester) async {
    final ProviderContainer container = await _container();
    addTearDown(container.dispose);

    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _pumpApp(tester, container);
    await openSafety(tester, container);

    final OnboardingController controller =
        container.read(onboardingControllerProvider.notifier);
    controller.toggleSafety(pain: true);
    controller.toggleSafety(recentSurgery: true);
    await tester.pumpAndSettle();

    final Finder listFinder = find.byType(ListView);
    final RenderBox listBox = tester.renderObject(listFinder) as RenderBox;
    expect(
      listBox.size.height,
      greaterThanOrEqualTo(O3SafetyScreen.minOptionsListExtent),
    );

    final Finder firstOption = find.text('Pelvic, groin or genital pain');
    await tester.scrollUntilVisible(
      firstOption,
      40,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    final double listTop = tester.getTopLeft(listFinder).dy;
    final double optionTop = tester.getTopLeft(firstOption).dy;
    final double delta = listTop + 4 - optionTop;
    if (delta.abs() > 1) {
      await tester.drag(listFinder, Offset(0, delta));
      await tester.pumpAndSettle();
    }

    final Rect listRect = tester.getRect(listFinder);
    bool rowVisible(String label) {
      final Rect rect = tester.getRect(find.text(label));
      return rect.center.dy >= listRect.top && rect.center.dy <= listRect.bottom;
    }

    expect(rowVisible('Pelvic, groin or genital pain'), isTrue);
    expect(rowVisible('Pain with erection or ejaculation'), isTrue);
    expect(rowVisible('Surgery in the last 3 months'), isTrue);
  });

  testWidgets(
      'O6 relaxation-first plan avoids holds, Level card title, and results',
      (WidgetTester tester) async {
    final ProviderContainer container = await _container();
    addTearDown(container.dispose);
    await _pumpApp(tester, container);

    final OnboardingController controller =
        container.read(onboardingControllerProvider.notifier);
    controller.setAcceptedAge(true);
    controller.setGoal(Goal.bladderControl);
    controller.toggleSafety(pain: true);
    controller.setExperience(Experience.none);
    container.read(routerProvider).go(AppRoutes.plan);
    await tester.pumpAndSettle();

    expect(find.text('RELAXATION FIRST PLAN'), findsOneWidget);
    expect(find.text('Relaxation · Weeks 1 to 2'), findsOneWidget);
    expect(find.text('Level 1 · Start'), findsNothing);
    expect(find.textContaining('Holds get easier'), findsNothing);
    expect(find.textContaining('Results vary'), findsNothing);

    final StringBuffer visible = StringBuffer();
    for (final Text text in tester.widgetList<Text>(find.byType(Text))) {
      final String? data = text.data;
      if (data != null) {
        visible.writeln(data);
      }
    }
    final String scrubbed = visible
        .toString()
        .replaceAll(
          'If the pain has settled and a clinician agrees, you can start Level 1.',
          '',
        )
        .toLowerCase();
    expect(scrubbed.contains('holds'), isFalse);
    expect(scrubbed.contains('level'), isFalse);
    expect(scrubbed.contains('results'), isFalse);
  });

  testWidgets(
      'O6 None of these keeps the goal track name General and bladder',
      (WidgetTester tester) async {
    final ProviderContainer container = await _container();
    addTearDown(container.dispose);
    await _pumpApp(tester, container);

    final OnboardingController controller =
        container.read(onboardingControllerProvider.notifier);
    controller.setAcceptedAge(true);
    controller.setGoal(Goal.generalPelvicHealth);
    controller.toggleSafety(noneOfThese: true);
    controller.setExperience(Experience.confident);
    container.read(routerProvider).go(AppRoutes.plan);
    await tester.pumpAndSettle();

    expect(
      container.read(onboardingControllerProvider).resolveTrack(),
      TrackId.generalBladder,
    );
    expect(find.text('GENERAL AND BLADDER PLAN'), findsOneWidget);
    expect(find.text('Level 1 · Start'), findsOneWidget);
  });
}
