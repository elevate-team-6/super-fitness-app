import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pinput/pinput.dart';
import 'package:super_fitness/config/base_ui_event/base_ui_event.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/features/auth/presentation/screens/verify_reset_code_screen.dart';
import 'package:super_fitness/features/auth/presentation/view_model/forget_password_view_model/forgot_password_cubit.dart';
import 'package:super_fitness/features/auth/presentation/view_model/forget_password_view_model/forgot_password_events.dart';
import 'package:super_fitness/features/auth/presentation/view_model/forget_password_view_model/forgot_password_state.dart';

import 'verify_reset_code_screen_test.mocks.dart';

@GenerateMocks([ForgotPasswordCubit])
void main() {
  late MockForgotPasswordCubit mockCubit;
  late StreamController<BaseUiEvent> eventController;
  late StreamController<ForgotPasswordState> stateController;

  const email = 'test@test.com';

  setUp(() {
    mockCubit = MockForgotPasswordCubit();

    eventController = StreamController<BaseUiEvent>.broadcast();
    stateController = StreamController<ForgotPasswordState>.broadcast();

    when(mockCubit.state).thenReturn(const ForgotPasswordState());
    when(mockCubit.stream).thenAnswer((_) => stateController.stream);
    when(mockCubit.eventStream).thenAnswer((_) => eventController.stream);
    when(mockCubit.close()).thenAnswer((_) async {});
  });

  tearDown(() async {
    await eventController.close();
    await stateController.close();
  });

  Widget buildWidget() {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, _) {
        return MaterialApp(
          home: BlocProvider<ForgotPasswordCubit>.value(
            value: mockCubit,
            child: const VerifyResetCodeScreen(email: email),
          ),
        );
      },
    );
  }

  group('VerifyResetCodeScreen', () {
    testWidgets('should render screen', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.otpCode), findsOneWidget);
      expect(find.byType(Pinput), findsOneWidget);
      expect(find.text(AppStrings.confirm), findsOneWidget);
      expect(find.text(AppStrings.resendCode), findsOneWidget);
    });

    testWidgets('should verify reset code', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(Pinput), '123456');
      await tester.pump();

      await tester.ensureVisible(find.text(AppStrings.confirm));
      await tester.tap(find.text(AppStrings.confirm));
      await tester.pump();

      verify(
        mockCubit.doEvent(
          argThat(
            isA<VerifyResetCodeEvent>()
                .having((e) => e.email, 'email', email)
                .having((e) => e.resetCode, 'resetCode', '123456'),
          ),
        ),
      ).called(1);
    });

    testWidgets('should resend code', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text(AppStrings.resendCode));
      await tester.tap(find.text(AppStrings.resendCode));
      await tester.pump();

      verify(
        mockCubit.doEvent(
          argThat(
            isA<ForgotPasswordEvent>().having((e) => e.email, 'email', email),
          ),
        ),
      ).called(1);
    });
  });
}
