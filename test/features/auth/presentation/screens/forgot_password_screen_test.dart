import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:super_fitness/config/base_ui_event/base_ui_event.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/core/widgets/custom_app_bar.dart';
import 'package:super_fitness/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:super_fitness/features/auth/presentation/view_model/forget_password_view_model/forgot_password_cubit.dart';
import 'package:super_fitness/features/auth/presentation/view_model/forget_password_view_model/forgot_password_events.dart';
import 'package:super_fitness/features/auth/presentation/view_model/forget_password_view_model/forgot_password_state.dart';

// Manual Mock for ForgotPasswordCubit using Mockito
class MockForgotPasswordCubit extends Mock implements ForgotPasswordCubit {
  @override
  ForgotPasswordState get state =>
      super.noSuchMethod(
            Invocation.getter(#state),
            returnValue: const ForgotPasswordState(),
            returnValueForMissingStub: const ForgotPasswordState(),
          )
          as ForgotPasswordState;

  @override
  Stream<ForgotPasswordState> get stream =>
      super.noSuchMethod(
            Invocation.getter(#stream),
            returnValue: const Stream<ForgotPasswordState>.empty(),
            returnValueForMissingStub: const Stream<ForgotPasswordState>.empty(),
          )
          as Stream<ForgotPasswordState>;

  @override
  Stream<BaseUiEvent> get eventStream =>
      super.noSuchMethod(
            Invocation.getter(#eventStream),
            returnValue: const Stream<BaseUiEvent>.empty(),
            returnValueForMissingStub: const Stream<BaseUiEvent>.empty(),
          )
          as Stream<BaseUiEvent>;

  @override
  void doEvent(ForgotPasswordEvents? event) =>
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
  late MockForgotPasswordCubit mockForgotPasswordCubit;

  setUp(() {
    mockForgotPasswordCubit = MockForgotPasswordCubit();
  });

  Widget createWidgetUnderTest(ForgotPasswordState state) {
    when(mockForgotPasswordCubit.state).thenReturn(state);
    when(mockForgotPasswordCubit.stream).thenAnswer((_) => const Stream.empty());
    when(mockForgotPasswordCubit.eventStream).thenAnswer(
      (_) => const Stream.empty(),
    );

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, _) => MaterialApp(
        localizationsDelegates: const [
          DefaultMaterialLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
        ],
        home: BlocProvider<ForgotPasswordCubit>.value(
          value: mockForgotPasswordCubit,
          child: const ForgotPasswordScreen(),
        ),
      ),
    );
  }

  group('ForgotPasswordScreen Step-based Tests', () {
    testWidgets('Step 0: Email Entry - Interaction', (tester) async {
      const state = ForgotPasswordState(currentStep: 0);
      await tester.pumpWidget(createWidgetUnderTest(state));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.forgetPassword), findsWidgets);
      expect(find.text(AppStrings.enterEmail), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'test@test.com');
      await tester.pump();

      final button = find.widgetWithText(ElevatedButton, AppStrings.sentOtP);
      expect(button, findsOneWidget);

      await tester.tap(button);
      
      verify(
        mockForgotPasswordCubit.doEvent(
          argThat(isA<UpdateForgotPasswordInfoEvent>()),
        ),
      ).called(1);
      verify(
        mockForgotPasswordCubit.doEvent(argThat(isA<ForgotPasswordEvent>())),
      ).called(1);
    });

    testWidgets('Step 1: OTP Verification Display', (tester) async {
      const state = ForgotPasswordState(currentStep: 1);
      await tester.pumpWidget(createWidgetUnderTest(state));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.otpCode), findsOneWidget);
      expect(find.text(AppStrings.enterOtp), findsOneWidget);
    });

    testWidgets('Step 2: New Password Entry Display', (tester) async {
      const state = ForgotPasswordState(currentStep: 2);
      await tester.pumpWidget(createWidgetUnderTest(state));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.createNewPassword), findsOneWidget);
      expect(find.text(AppStrings.passwordMoreCharacter), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));
    });

    testWidgets('Navigation: Back Button triggers UpdateStepEvent', (
      tester,
    ) async {
      const state = ForgotPasswordState(currentStep: 1);
      await tester.pumpWidget(createWidgetUnderTest(state));
      await tester.pumpAndSettle();

      final backButton = find.descendant(
        of: find.byType(CustomAppBar),
        matching: find.byType(GestureDetector),
      );
      await tester.tap(backButton);

      verify(
        mockForgotPasswordCubit.doEvent(argThat(isA<UpdateStepEvent>())),
      ).called(1);
    });

    testWidgets('Validation: Email Step - Invalid email disables button', (
      tester,
    ) async {
      const state = ForgotPasswordState(currentStep: 0);
      await tester.pumpWidget(createWidgetUnderTest(state));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'invalid-email');
      await tester.pump();

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });
  });
}
