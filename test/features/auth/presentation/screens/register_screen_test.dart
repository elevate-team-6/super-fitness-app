import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_fitness/config/base_ui_event/base_ui_event.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/features/auth/presentation/screens/register_screen.dart';
import 'package:super_fitness/features/auth/presentation/view_model/register_view_model/register_cubit.dart';
import 'package:super_fitness/features/auth/presentation/view_model/register_view_model/register_state.dart';

import 'register_screen_test.mocks.dart';

@GenerateMocks([RegisterCubit])
@GenerateNiceMocks([MockSpec<NavigatorObserver>()])
void main() {
  late MockRegisterCubit mockRegisterCubit;
  late MockNavigatorObserver mockNavigatorObserver;
  late StreamController<BaseUiEvent> uiEventController;

  setUp(() {
    mockRegisterCubit = MockRegisterCubit();
    mockNavigatorObserver = MockNavigatorObserver();
    uiEventController = StreamController<BaseUiEvent>.broadcast();

    // Stubbing RegisterCubit methods
    when(mockRegisterCubit.state).thenReturn(const RegisterState());
    when(mockRegisterCubit.stream).thenAnswer((_) => const Stream.empty());
    when(
      mockRegisterCubit.eventStream,
    ).thenAnswer((_) => uiEventController.stream);
  });

  tearDown(() {
    uiEventController.close();
  });

  Widget createWidgetUnderTest() {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          builder: BotToastInit(),
          navigatorObservers: [
            mockNavigatorObserver,
            BotToastNavigatorObserver(),
          ],
          home: BlocProvider<RegisterCubit>.value(
            value: mockRegisterCubit,
            child: const RegisterScreen(),
          ),
        );
      },
    );
  }

  group('RegisterScreen Rendering Tests', () {
    testWidgets('Should render all headers and labels correctly', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.signupWelcome), findsOneWidget);
      expect(find.text(AppStrings.signupCreateAccount), findsOneWidget);
      expect(
        find.text(AppStrings.register),
        findsNWidgets(2),
      ); // Title and Button
    });

    testWidgets('Should render all text fields with correct hint texts', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.firstName), findsOneWidget);
      expect(find.text(AppStrings.lastName), findsOneWidget);
      expect(find.text(AppStrings.email), findsOneWidget);
      expect(find.text(AppStrings.password), findsOneWidget);
    });
  });

  group('RegisterScreen Validation Tests', () {
    testWidgets('Should show validation errors when fields are empty', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final registerButton = find.widgetWithText(
        ElevatedButton,
        AppStrings.register,
      );
      await tester.ensureVisible(registerButton);
      await tester.tap(registerButton);
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.firstNameRequired), findsOneWidget);
      expect(find.text(AppStrings.lastNameRequired), findsOneWidget);
      expect(find.text(AppStrings.emailRequired), findsOneWidget);
      expect(find.text(AppStrings.passwordRequired), findsOneWidget);
    });

    testWidgets('Should show error for invalid email', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final emailField = find.widgetWithText(TextField, AppStrings.email);
      await tester.ensureVisible(emailField);
      await tester.enterText(emailField, 'invalid-email');

      final registerButton = find.widgetWithText(
        ElevatedButton,
        AppStrings.register,
      );
      await tester.ensureVisible(registerButton);
      await tester.tap(registerButton);
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.invalidEmail), findsOneWidget);
    });

    testWidgets('Should show error for weak password', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final passwordField = find.widgetWithText(TextField, AppStrings.password);
      await tester.ensureVisible(passwordField);
      await tester.enterText(passwordField, '123');

      final registerButton = find.widgetWithText(
        ElevatedButton,
        AppStrings.register,
      );
      await tester.ensureVisible(registerButton);
      await tester.tap(registerButton);
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.passwordTooShort), findsOneWidget);
    });
  });

  group('RegisterScreen Interaction Tests', () {
    testWidgets('Should call cubit events when form is valid', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, AppStrings.firstName),
        'John',
      );
      await tester.enterText(
        find.widgetWithText(TextField, AppStrings.lastName),
        'Doe',
      );
      await tester.enterText(
        find.widgetWithText(TextField, AppStrings.email),
        'john.doe@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextField, AppStrings.password),
        'Password123!',
      );

      final registerButton = find.widgetWithText(
        ElevatedButton,
        AppStrings.register,
      );
      await tester.ensureVisible(registerButton);
      await tester.tap(registerButton);
      await tester.pumpAndSettle();

      verify(mockRegisterCubit.doEvent(any)).called(2);
    });

    testWidgets('Should navigate back when login is pressed', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final loginButton = find.text(AppStrings.login);
      await tester.ensureVisible(loginButton);
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      verify(mockNavigatorObserver.didPop(any, any)).called(1);
    });
  });

  group('RegisterScreen UI Events Tests', () {
    testWidgets('Should show SnackBar when DisplayErrorEvent is emitted', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      const errorMessage = 'Test Error';
      uiEventController.add(DisplayErrorEvent(errorMessage));

      // BotToast might need more time or specific pump
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text(errorMessage), findsOneWidget);
    });
  });
}
