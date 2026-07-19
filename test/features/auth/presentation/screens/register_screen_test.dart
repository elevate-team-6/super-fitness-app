import 'dart:async';
import 'dart:convert';

import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_fitness/config/base_ui_event/base_ui_event.dart';
import 'package:super_fitness/core/utils/app_constants.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/features/auth/presentation/screens/register_screen.dart';
import 'package:super_fitness/features/auth/presentation/view_model/register_view_model/register_cubit.dart';
import 'package:super_fitness/features/auth/presentation/view_model/register_view_model/register_state.dart';

import 'register_screen_test.mocks.dart';

class _InMemoryAssetLoader extends AssetLoader {
  const _InMemoryAssetLoader(this._data);

  final Map<String, Map<String, dynamic>> _data;

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async =>
      _data[locale.languageCode] ?? const {};
}

@GenerateMocks([RegisterCubit])
@GenerateNiceMocks([MockSpec<NavigatorObserver>()])
void main() {
  late MockRegisterCubit mockRegisterCubit;
  late MockNavigatorObserver mockNavigatorObserver;
  late StreamController<BaseUiEvent> uiEventController;
  late Map<String, Map<String, dynamic>> translations;

  const surface = Size(700, 1400);

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();

    translations = {
      AppConstants.englishCode:
          json.decode(
                await rootBundle.loadString(
                  '${AppConstants.translationsPath}/${AppConstants.englishCode}.json',
                ),
              )
              as Map<String, dynamic>,
      AppConstants.arabicCode:
          json.decode(
                await rootBundle.loadString(
                  '${AppConstants.translationsPath}/${AppConstants.arabicCode}.json',
                ),
              )
              as Map<String, dynamic>,
    };
  });

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

  Future<void> pumpRegisterScreen(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
  }) async {
    tester.view.physicalSize = surface;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      EasyLocalization(
        key: ValueKey(locale),
        supportedLocales: const [Locale('en'), Locale('ar')],
        path: AppConstants.translationsPath,
        fallbackLocale: const Locale('en'),
        startLocale: locale,
        assetLoader: _InMemoryAssetLoader(translations),
        child: Builder(
          builder: (context) => ScreenUtilInit(
            designSize: surface,
            builder: (_, _) => MaterialApp(
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              debugShowCheckedModeBanner: false,
              builder: BotToastInit(),
              navigatorObservers: [
                mockNavigatorObserver,
                BotToastNavigatorObserver(),
              ],
              home: BlocProvider<RegisterCubit>.value(
                value: mockRegisterCubit,
                child: const RegisterScreen(),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('RegisterScreen Rendering Tests', () {
    testWidgets('Should render all headers and labels correctly', (
      tester,
    ) async {
      await pumpRegisterScreen(tester);

      expect(find.text(AppStrings.signupWelcome.tr()), findsOneWidget);
      expect(find.text(AppStrings.signupCreateAccount.tr()), findsOneWidget);
      expect(find.text(AppStrings.register.tr()), findsAtLeast(1));
    });

    testWidgets('Should render all text fields with correct hint texts', (
      tester,
    ) async {
      await pumpRegisterScreen(tester);

      expect(find.text(AppStrings.firstName.tr()), findsOneWidget);
      expect(find.text(AppStrings.lastName.tr()), findsOneWidget);
      expect(find.text(AppStrings.email.tr()), findsOneWidget);
      expect(find.text(AppStrings.password.tr()), findsOneWidget);
    });
  });

  group('RegisterScreen Validation Tests', () {
    testWidgets('Button should be disabled when fields are empty', (
      tester,
    ) async {
      await pumpRegisterScreen(tester);

      final registerButton = find.widgetWithText(
        ElevatedButton,
        AppStrings.register.tr(),
      );
      final button = tester.widget<ElevatedButton>(registerButton);
      expect(button.onPressed, isNull);
    });

    testWidgets(
      'Should show validation error when field is cleared after interaction',
      (tester) async {
        await pumpRegisterScreen(tester);

        final firstNameField = find.widgetWithText(
          TextField,
          AppStrings.firstName.tr(),
        );
        await tester.enterText(firstNameField, 'A'); // Too short
        await tester.pump();
        expect(find.text(AppStrings.nameTooShort.tr()), findsOneWidget);

        await tester.enterText(firstNameField, ''); // Empty
        await tester.pump();
        expect(find.text(AppStrings.firstNameRequired.tr()), findsOneWidget);
      },
    );

    testWidgets('Should show error for invalid email on interaction', (
      tester,
    ) async {
      await pumpRegisterScreen(tester);

      final emailField = find.widgetWithText(TextField, AppStrings.email.tr());
      await tester.enterText(emailField, 'invalid-email');
      await tester.pump();

      expect(find.text(AppStrings.invalidEmail.tr()), findsOneWidget);
    });
  });

  group('RegisterScreen Interaction Tests', () {
    testWidgets('Should call cubit events when form is valid', (tester) async {
      await pumpRegisterScreen(tester);

      await tester.enterText(
        find.widgetWithText(TextField, AppStrings.firstName.tr()),
        'John',
      );
      await tester.pump();
      await tester.enterText(
        find.widgetWithText(TextField, AppStrings.lastName.tr()),
        'Doe',
      );
      await tester.pump();
      await tester.enterText(
        find.widgetWithText(TextField, AppStrings.email.tr()),
        'john.doe@example.com',
      );
      await tester.pump();
      await tester.enterText(
        find.widgetWithText(TextField, AppStrings.password.tr()),
        'Password123!',
      );
      await tester.pumpAndSettle();

      final registerButton = find.widgetWithText(
        ElevatedButton,
        AppStrings.register.tr(),
      );

      // Ensure the button is now enabled
      final button = tester.widget<ElevatedButton>(registerButton);
      expect(
        button.onPressed,
        isNotNull,
        reason: 'Button should be enabled when form is valid',
      );

      await tester.ensureVisible(registerButton);
      await tester.tap(registerButton);
      await tester.pumpAndSettle();

      verify(mockRegisterCubit.doEvent(any)).called(greaterThanOrEqualTo(1));
    });

    testWidgets('Should navigate back when login is pressed', (tester) async {
      await pumpRegisterScreen(tester);

      final loginButton = find.text(AppStrings.login.tr());
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
      await pumpRegisterScreen(tester);

      const errorMessage = 'Test Error';
      uiEventController.add(DisplayErrorEvent(errorMessage));

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text(errorMessage), findsOneWidget);
    });
  });
}
