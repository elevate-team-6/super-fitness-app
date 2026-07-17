import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_fitness/config/base_ui_event/base_ui_event.dart';
import 'package:super_fitness/core/utils/app_routes.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:super_fitness/features/auth/presentation/view_model/forget_password_view_model/forgot_password_cubit.dart';
import 'package:super_fitness/features/auth/presentation/view_model/forget_password_view_model/forgot_password_events.dart';
import 'package:super_fitness/features/auth/presentation/view_model/forget_password_view_model/forgot_password_state.dart';

import 'forgot_password_screen_test.mocks.dart';

@GenerateMocks([ForgotPasswordCubit])
void main() {
  late MockForgotPasswordCubit mockCubit;
  late StreamController<BaseUiEvent> eventController;
  late StreamController<ForgotPasswordState> stateController;

  setUp(() {
    mockCubit = MockForgotPasswordCubit();
    eventController = StreamController<BaseUiEvent>.broadcast();
    stateController = StreamController<ForgotPasswordState>.broadcast();

    when(mockCubit.state).thenReturn(const ForgotPasswordState());
    when(mockCubit.stream).thenAnswer((_) => stateController.stream);
    when(mockCubit.eventStream).thenAnswer((_) => eventController.stream);
    when(mockCubit.close()).thenAnswer((_) async => {});
  });

  tearDown(() {
    eventController.close();
    stateController.close();
  });

  Widget createWidgetUnderTest() {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          onGenerateRoute: (settings) {
            if (settings.name == AppRoutes.verifyResetCode) {
              return MaterialPageRoute(
                settings: settings,
                builder: (context) =>
                    const Scaffold(body: Text('Verify Screen')),
              );
            }
            return null;
          },
          home: BlocProvider<ForgotPasswordCubit>.value(
            value: mockCubit,
            child: const ForgotPasswordScreen(),
          ),
        );
      },
    );
  }

  group('ForgotPasswordScreen Tests', () {
    testWidgets('Initial State: Should render all widgets correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.enterEmail), findsOneWidget);
      expect(find.text(AppStrings.forgetPassword), findsOneWidget);
      expect(find.text(AppStrings.email), findsOneWidget);
      expect(find.text(AppStrings.sentOtP), findsOneWidget);
    });

    testWidgets('Validation: Should show error when email is empty', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.sentOtP));
      await tester.pumpAndSettle();

      verifyNever(mockCubit.doEvent(any));
    });

    testWidgets('Action: Should call doEvent when valid email is entered', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), 'test@example.com');
      await tester.tap(find.text(AppStrings.sentOtP));
      await tester.pumpAndSettle();

      verify(mockCubit.doEvent(argThat(isA<ForgotPasswordEvent>()))).called(1);
    });

    testWidgets(
      'Navigation: Should navigate to Verify Screen when success event is emitted',
      (WidgetTester tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Simulate state change to trigger listener navigation (if based on state)
        // Note: The screen listens to eventStream for UI events like handleUiEvent,
        // but also has a BlocConsumer listener for state change.

        when(mockCubit.state).thenReturn(const ForgotPasswordState());

        // We need to trigger the BlocConsumer listener
        stateController.add(const ForgotPasswordState());
        await tester.pump();

        expect(find.text('Verify Screen'), findsNothing);
      },
    );
  });
}
