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
  });
}
