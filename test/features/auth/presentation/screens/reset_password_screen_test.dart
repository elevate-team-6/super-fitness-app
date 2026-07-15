import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_fitness/config/base_ui_event/base_ui_event.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/core/widgets/custom_text_field.dart';
import 'package:super_fitness/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:super_fitness/features/auth/presentation/view_model/forget_password_view_model/forgot_password_cubit.dart';
import 'package:super_fitness/features/auth/presentation/view_model/forget_password_view_model/forgot_password_events.dart';
import 'package:super_fitness/features/auth/presentation/view_model/forget_password_view_model/forgot_password_state.dart';

import 'reset_password_screen_test.mocks.dart';

@GenerateMocks([ForgotPasswordCubit])
void main() {
  late MockForgotPasswordCubit mockCubit;
  late StreamController<BaseUiEvent> eventController;
  late StreamController<ForgotPasswordState> stateController;

  const testEmail = 'test@test.com';

  setUp(() {
    mockCubit = MockForgotPasswordCubit();

    eventController = StreamController.broadcast();
    stateController = StreamController.broadcast();

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
            child: const ResetPasswordScreen(email: testEmail),
          ),
        );
      },
    );
  }

  group('ResetPasswordScreen', () {
    testWidgets('Should render correctly', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.createNewPassword), findsOneWidget);
      expect(find.byType(CustomTextField), findsNWidgets(2));
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('Should call ResetPasswordEvent', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);

      await tester.enterText(fields.at(0), 'Password123!');

      await tester.enterText(fields.at(1), 'Password123!');

      await tester.pumpAndSettle();

      final button = find.byType(ElevatedButton);

      await tester.ensureVisible(button);

      await tester.tap(button);

      await tester.pump();

      final captured =
          verify(mockCubit.doEvent(captureAny)).captured.single
              as ResetPasswordEvent;

      expect(captured.email, testEmail);
      expect(captured.newPassword, 'Password123!');
    });
  });
}
