import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:super_fitness/config/base_ui_event/base_ui_event.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/core/widgets/custom_app_bar.dart';
import 'package:super_fitness/features/auth/presentation/screens/complete_register_screen.dart';
import 'package:super_fitness/features/auth/presentation/view_model/signup_view_model/register_event.dart';
import 'package:super_fitness/features/auth/presentation/view_model/signup_view_model/register_state.dart';
import 'package:super_fitness/features/auth/presentation/view_model/signup_view_model/signup_cubit.dart';

// Manual Mock for SignupCubit using Mockito
class MockSignupCubit extends Mock implements SignupCubit {
  @override
  RegisterState get state =>
      super.noSuchMethod(
            Invocation.getter(#state),
            returnValue: const RegisterState(),
            returnValueForMissingStub: const RegisterState(),
          )
          as RegisterState;

  @override
  Stream<RegisterState> get stream =>
      super.noSuchMethod(
            Invocation.getter(#stream),
            returnValue: const Stream<RegisterState>.empty(),
            returnValueForMissingStub: const Stream<RegisterState>.empty(),
          )
          as Stream<RegisterState>;

  @override
  Stream<BaseUiEvent> get eventStream =>
      super.noSuchMethod(
            Invocation.getter(#eventStream),
            returnValue: const Stream<BaseUiEvent>.empty(),
            returnValueForMissingStub: const Stream<BaseUiEvent>.empty(),
          )
          as Stream<BaseUiEvent>;

  @override
  void doEvent(RegisterEvent? event) =>
      super.noSuchMethod(Invocation.method(#doEvent, [event]));

  @override
  Future<void> close() =>
      super.noSuchMethod(
            Invocation.method(#close, []),
            returnValue: Future<void>.value(),
            returnValueForMissingStub: Future<void>.value(),
          )
          as Future<void>;
}

void main() {
  late MockSignupCubit mockSignupCubit;

  setUp(() {
    mockSignupCubit = MockSignupCubit();
  });

  Widget createWidgetUnderTest(RegisterState state) {
    when(mockSignupCubit.state).thenReturn(state);
    when(mockSignupCubit.stream).thenAnswer((_) => const Stream.empty());
    when(mockSignupCubit.eventStream).thenAnswer((_) => const Stream.empty());

    return ScreenUtilInit(
      designSize: const Size(1000, 2000),
      builder: (_, _) => MaterialApp(
        localizationsDelegates: const [
          DefaultMaterialLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
        ],
        home: BlocProvider<SignupCubit>.value(
          value: mockSignupCubit,
          child: const CompleteRegisterScreen(),
        ),
      ),
    );
  }

  group('CompleteRegisterScreen Professional Tests (Mockito)', () {
    testWidgets('Step 1: Gender Selection - Interaction', (tester) async {
      const state = RegisterState(currentStep: 1, gender: '');
      await tester.pumpWidget(createWidgetUnderTest(state));
      await tester.pumpAndSettle();

      expect(
        find.text(AppStrings.tellUsAboutYourself.toUpperCase()),
        findsOneWidget,
      );

      final maleFinder = find.text(AppStrings.male);
      expect(maleFinder, findsOneWidget);

      await tester.tap(maleFinder);

      verify(
        mockSignupCubit.doEvent(argThat(isA<SelectGenderEvent>())),
      ).called(1);
    });

    testWidgets('Step 2: Age Selection Display', (tester) async {
      const state = RegisterState(currentStep: 2, age: 30);
      await tester.pumpWidget(createWidgetUnderTest(state));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.ageTitle.toUpperCase()), findsOneWidget);
      expect(find.text('30'), findsOneWidget);
    });

    testWidgets('Step 5: Goal Selection Interaction', (tester) async {
      const state = RegisterState(currentStep: 5, goal: '');
      await tester.pumpWidget(createWidgetUnderTest(state));
      await tester.pumpAndSettle();

      final goalOption = find.text(AppStrings.gainWeight);
      expect(goalOption, findsOneWidget);

      await tester.tap(goalOption, warnIfMissed: false);
      verify(
        mockSignupCubit.doEvent(argThat(isA<SelectGoalEvent>())),
      ).called(1);
    });

    testWidgets('Step 6: Activity Level Submission', (tester) async {
      const state = RegisterState(currentStep: 6, activityLevel: 'Active');
      await tester.pumpWidget(createWidgetUnderTest(state));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.done), findsOneWidget);

      await tester.tap(find.text(AppStrings.done), warnIfMissed: false);
      verify(
        mockSignupCubit.doEvent(argThat(isA<SubmitSignupEvent>())),
      ).called(1);
    });

    testWidgets('Navigation: Back Button triggers PreviousStepEvent', (
      tester,
    ) async {
      const state = RegisterState(currentStep: 2);
      await tester.pumpWidget(createWidgetUnderTest(state));
      await tester.pumpAndSettle();

      final backButton = find.descendant(
        of: find.byType(CustomAppBar),
        matching: find.byType(GestureDetector),
      );
      await tester.tap(backButton);

      verify(
        mockSignupCubit.doEvent(argThat(isA<PreviousStepEvent>())),
      ).called(1);
    });

    testWidgets('Validation: Next button enabled state', (tester) async {
      const validState = RegisterState(currentStep: 3, weight: 70);
      await tester.pumpWidget(createWidgetUnderTest(validState));
      await tester.pumpAndSettle();

      final nextButton = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(nextButton.onPressed, isNotNull);
    });

    testWidgets('Step 1: Female Gender Selection', (tester) async {
      const state = RegisterState(currentStep: 1, gender: '');
      await tester.pumpWidget(createWidgetUnderTest(state));
      await tester.pumpAndSettle();

      final femaleFinder = find.text(AppStrings.female);
      expect(femaleFinder, findsOneWidget);

      await tester.tap(femaleFinder);
      verify(
        mockSignupCubit.doEvent(argThat(isA<SelectGenderEvent>())),
      ).called(1);
    });

    testWidgets('Step 2: Age Selection Interaction', (tester) async {
      const state = RegisterState(currentStep: 2, age: 25);
      await tester.pumpWidget(createWidgetUnderTest(state));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.ageTitle.toUpperCase()), findsOneWidget);
      expect(find.text('25'), findsOneWidget);
    });

    testWidgets('Step 3: Weight Selection Display', (tester) async {
      const state = RegisterState(currentStep: 3, weight: 75);
      await tester.pumpWidget(createWidgetUnderTest(state));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.weightTitle.toUpperCase()), findsOneWidget);
      expect(find.text('75'), findsOneWidget);
    });

    testWidgets('Step 4: Height Selection Display', (tester) async {
      const state = RegisterState(currentStep: 4, height: 175);
      await tester.pumpWidget(createWidgetUnderTest(state));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.heightTitle.toUpperCase()), findsOneWidget);
      expect(find.text('175'), findsOneWidget);
    });

    testWidgets('Step 5: Different Goal Options', (tester) async {
      const state = RegisterState(currentStep: 5, goal: '');
      await tester.pumpWidget(createWidgetUnderTest(state));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.loseWeight), findsOneWidget);
      expect(find.text(AppStrings.getFitter), findsOneWidget);
      expect(find.text(AppStrings.gainMoreFlexible), findsOneWidget);
      expect(find.text(AppStrings.learnTheBasic), findsOneWidget);
    });

    testWidgets('Step 6: Different Activity Level Options', (tester) async {
      const state = RegisterState(currentStep: 6, activityLevel: '');
      await tester.pumpWidget(createWidgetUnderTest(state));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.sedentary), findsOneWidget);
      expect(find.text(AppStrings.lightlyActive), findsOneWidget);
      expect(find.text(AppStrings.moderatelyActive), findsOneWidget);
      expect(find.text(AppStrings.veryActive), findsOneWidget);
      expect(find.text(AppStrings.extraActive), findsOneWidget);
    });

    testWidgets('Validation: Step 1 - Empty gender disables Next', (
      tester,
    ) async {
      const invalidState = RegisterState(currentStep: 1, gender: '');
      await tester.pumpWidget(createWidgetUnderTest(invalidState));
      await tester.pumpAndSettle();

      final nextButton = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(nextButton.onPressed, isNull);
    });

    testWidgets('Validation: Step 2 - Zero age disables Next', (tester) async {
      const invalidState = RegisterState(currentStep: 2, age: 0);
      await tester.pumpWidget(createWidgetUnderTest(invalidState));
      await tester.pumpAndSettle();

      final nextButton = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(nextButton.onPressed, isNull);
    });

    testWidgets('Validation: Step 3 - Zero weight disables Next', (
      tester,
    ) async {
      const invalidState = RegisterState(currentStep: 3, weight: 0);
      await tester.pumpWidget(createWidgetUnderTest(invalidState));
      await tester.pumpAndSettle();

      final nextButton = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(nextButton.onPressed, isNull);
    });

    testWidgets('Validation: Step 4 - Zero height disables Next', (
      tester,
    ) async {
      const invalidState = RegisterState(currentStep: 4, height: 0);
      await tester.pumpWidget(createWidgetUnderTest(invalidState));
      await tester.pumpAndSettle();

      final nextButton = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(nextButton.onPressed, isNull);
    });

    testWidgets('Validation: Step 5 - Empty goal disables Next', (
      tester,
    ) async {
      const invalidState = RegisterState(currentStep: 5, goal: '');
      await tester.pumpWidget(createWidgetUnderTest(invalidState));
      await tester.pumpAndSettle();

      final nextButton = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(nextButton.onPressed, isNull);
    });

    testWidgets('Validation: Step 6 - Empty activity level disables Done', (
      tester,
    ) async {
      const invalidState = RegisterState(currentStep: 6, activityLevel: '');
      await tester.pumpWidget(createWidgetUnderTest(invalidState));
      await tester.pumpAndSettle();

      final nextButton = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(nextButton.onPressed, isNull);
    });

    testWidgets('Navigation: Next button triggers NextStepEvent - Step 1', (
      tester,
    ) async {
      const validState = RegisterState(currentStep: 1, gender: 'Male');
      await tester.pumpWidget(createWidgetUnderTest(validState));
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.next));
      verify(mockSignupCubit.doEvent(argThat(isA<NextStepEvent>()))).called(1);
    });

    testWidgets('Navigation: Next button triggers NextStepEvent - Step 2', (
      tester,
    ) async {
      const validState = RegisterState(currentStep: 2, age: 25);
      await tester.pumpWidget(createWidgetUnderTest(validState));
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.next));
      verify(mockSignupCubit.doEvent(argThat(isA<NextStepEvent>()))).called(1);
    });

    testWidgets('Navigation: Next button triggers NextStepEvent - Step 3', (
      tester,
    ) async {
      const validState = RegisterState(currentStep: 3, weight: 70);
      await tester.pumpWidget(createWidgetUnderTest(validState));
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.next));
      verify(mockSignupCubit.doEvent(argThat(isA<NextStepEvent>()))).called(1);
    });

    testWidgets('Navigation: Next button triggers NextStepEvent - Step 4', (
      tester,
    ) async {
      const validState = RegisterState(currentStep: 4, height: 175);
      await tester.pumpWidget(createWidgetUnderTest(validState));
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.next));
      verify(mockSignupCubit.doEvent(argThat(isA<NextStepEvent>()))).called(1);
    });

    testWidgets('Navigation: Next button triggers NextStepEvent - Step 5', (
      tester,
    ) async {
      const validState = RegisterState(
        currentStep: 5,
        goal: AppStrings.loseWeight,
      );
      await tester.pumpWidget(createWidgetUnderTest(validState));
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.next));
      verify(mockSignupCubit.doEvent(argThat(isA<NextStepEvent>()))).called(1);
    });

    testWidgets('Navigation: Back button from Step 1 navigates back', (
      tester,
    ) async {
      const state = RegisterState(currentStep: 1);
      await tester.pumpWidget(createWidgetUnderTest(state));
      await tester.pumpAndSettle();

      final backButton = find.descendant(
        of: find.byType(CustomAppBar),
        matching: find.byType(GestureDetector),
      );
      await tester.tap(backButton);

      verify(
        mockSignupCubit.doEvent(argThat(isA<PreviousStepEvent>())),
      ).called(1);
    });

    testWidgets('Boundary Values: Age minimum (16)', (tester) async {
      const state = RegisterState(currentStep: 2, age: 16);
      await tester.pumpWidget(createWidgetUnderTest(state));
      await tester.pumpAndSettle();

      expect(find.text('16'), findsOneWidget);
      final nextButton = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(nextButton.onPressed, isNotNull);
    });

    testWidgets('Boundary Values: Age maximum (90)', (tester) async {
      const state = RegisterState(currentStep: 2, age: 90);
      await tester.pumpWidget(createWidgetUnderTest(state));
      await tester.pumpAndSettle();

      expect(find.text('90'), findsOneWidget);
      final nextButton = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(nextButton.onPressed, isNotNull);
    });

    testWidgets('Boundary Values: Weight minimum (30)', (tester) async {
      const state = RegisterState(currentStep: 3, weight: 30);
      await tester.pumpWidget(createWidgetUnderTest(state));
      await tester.pumpAndSettle();

      expect(find.text('30'), findsOneWidget);
      final nextButton = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(nextButton.onPressed, isNotNull);
    });

    testWidgets('Boundary Values: Weight maximum (250)', (tester) async {
      const state = RegisterState(currentStep: 3, weight: 250);
      await tester.pumpWidget(createWidgetUnderTest(state));
      await tester.pumpAndSettle();

      expect(find.text('250'), findsOneWidget);
      final nextButton = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(nextButton.onPressed, isNotNull);
    });

    testWidgets('Boundary Values: Height minimum (100)', (tester) async {
      const state = RegisterState(currentStep: 4, height: 100);
      await tester.pumpWidget(createWidgetUnderTest(state));
      await tester.pumpAndSettle();

      expect(find.text('100'), findsOneWidget);
      final nextButton = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(nextButton.onPressed, isNotNull);
    });

    testWidgets('Boundary Values: Height maximum (250)', (tester) async {
      const state = RegisterState(currentStep: 4, height: 250);
      await tester.pumpWidget(createWidgetUnderTest(state));
      await tester.pumpAndSettle();

      expect(find.text('250'), findsOneWidget);
      final nextButton = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(nextButton.onPressed, isNotNull);
    });
  });
}
