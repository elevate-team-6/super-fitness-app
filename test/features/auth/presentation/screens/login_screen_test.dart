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
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/config/cache/secure_cache_helper.dart';
import 'package:super_fitness/config/services/google_auth_service.dart';
import 'package:super_fitness/core/utils/app_constants.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/features/auth/data/models/request/sign_in_request_model.dart';
import 'package:super_fitness/features/auth/domain/entities/sign_in_entity.dart';
import 'package:super_fitness/features/auth/domain/entities/user_entity.dart';
import 'package:super_fitness/features/auth/domain/use_cases/sign_in_use_case.dart';
import 'package:super_fitness/features/auth/presentation/screens/login_screen.dart';
import 'package:super_fitness/features/auth/presentation/view_model/login_view_model/login_cubit.dart';
import 'package:super_fitness/features/auth/presentation/widgets/login_form.dart';
import 'package:super_fitness/features/auth/presentation/widgets/social_login_button.dart';

import 'login_screen_test.mocks.dart';

class _InMemoryAssetLoader extends AssetLoader {
  const _InMemoryAssetLoader(this._data);

  /// Translations keyed by language code (e.g. `en`, `ar`).
  final Map<String, Map<String, dynamic>> _data;

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async =>
      _data[locale.languageCode] ?? const {};
}

@GenerateMocks([SignInUseCase, SecureCacheHelper, GoogleAuthService])
void main() {
  late MockSignInUseCase mockUseCase;
  late MockSecureCacheHelper mockCache;
  late MockGoogleAuthService mockGoogleAuthService;
  late LoginCubit cubit;
  late Map<String, Map<String, dynamic>> translations;

  const validEmail = 'test@test.com';
  // Satisfies the project's password policy: 8+ chars, lower, upper, digit and
  // a special character.
  const validPassword = 'Ahmed@123';

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
    mockUseCase = MockSignInUseCase();
    mockCache = MockSecureCacheHelper();
    mockGoogleAuthService = MockGoogleAuthService();
    when(
      mockCache.writeData(key: anyNamed('key'), value: anyNamed('value')),
    ).thenAnswer((_) async {});

    cubit = LoginCubit(mockUseCase, mockCache, mockGoogleAuthService);

    provideDummy<BaseResponse<SignInEntity>>(ErrorBaseResponse('dummy'));
  });

  tearDown(() async {
    if (!cubit.isClosed) await cubit.close();
  });

  Future<void> pumpLoginScreen(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    LoginCubit? loginCubit,
  }) async {
    final activeCubit = loginCubit ?? cubit;
    tester.view.physicalSize = surface;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      EasyLocalization(
        // Keyed by locale so re-pumping rebuilds with a fresh controller
        // instead of reusing the previous locale's state.
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
              onGenerateRoute: (_) => MaterialPageRoute<void>(
                builder: (_) => const SizedBox.shrink(),
              ),
              home: BlocProvider<LoginCubit>.value(
                value: activeCubit,
                child: const LoginScreen(),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  // "Login" renders twice (card title + submit button), so the button is
  // matched by type to stay unambiguous.
  Finder loginButton() =>
      find.widgetWithText(ElevatedButton, AppStrings.login.tr());

  Future<void> enterCredentials(
    WidgetTester tester, {
    required String email,
    required String password,
  }) async {
    await tester.enterText(find.byKey(LoginForm.emailFieldKey), email);
    await tester.enterText(find.byKey(LoginForm.passwordFieldKey), password);
    // Let the AnimatedBuilder rebuild so the button reflects the new validity.
    await tester.pumpAndSettle();
  }

  group('Rendering', () {
    testWidgets('renders all core elements', (tester) async {
      await pumpLoginScreen(tester);

      expect(find.byType(LoginForm), findsOneWidget);
      expect(find.byKey(LoginForm.emailFieldKey), findsOneWidget);
      expect(find.byKey(LoginForm.passwordFieldKey), findsOneWidget);
      expect(loginButton(), findsOneWidget);

      expect(find.text(AppStrings.welcomeBack.tr()), findsOneWidget);
      expect(find.text(AppStrings.forgetPassword.tr()), findsOneWidget);
      expect(find.text(AppStrings.dontHaveAccount.tr()), findsOneWidget);

      // Email + password text fields.
      expect(find.byType(TextField), findsNWidgets(2));
    });

    testWidgets('renders the three social buttons', (tester) async {
      await pumpLoginScreen(tester);

      expect(find.byType(SocialLoginButton), findsNWidgets(3));
    });
  });

  group('Validation', () {
    testWidgets('an invalid email shows an error message', (tester) async {
      await pumpLoginScreen(tester);

      await enterCredentials(
        tester,
        email: 'not-an-email',
        password: validPassword,
      );

      expect(find.text(AppStrings.invalidEmail.tr()), findsOneWidget);
    });

    testWidgets('a too-short password shows an error message', (tester) async {
      await pumpLoginScreen(tester);

      await enterCredentials(tester, email: validEmail, password: 'Ab1@');

      expect(find.text(AppStrings.passwordTooShort.tr()), findsOneWidget);
    });

    testWidgets('a password without an uppercase letter shows an error', (
      tester,
    ) async {
      await pumpLoginScreen(tester);

      await enterCredentials(tester, email: validEmail, password: 'ahmed@123');

      expect(find.text(AppStrings.passwordUppercase.tr()), findsOneWidget);
    });

    testWidgets('a password without a number shows an error', (tester) async {
      await pumpLoginScreen(tester);

      await enterCredentials(tester, email: validEmail, password: 'Ahmed@abc');

      expect(find.text(AppStrings.passwordNumber.tr()), findsOneWidget);
    });

    testWidgets('valid credentials show no validation errors', (tester) async {
      await pumpLoginScreen(tester);

      await enterCredentials(
        tester,
        email: validEmail,
        password: validPassword,
      );

      expect(find.text(AppStrings.invalidEmail.tr()), findsNothing);
      expect(find.text(AppStrings.passwordTooShort.tr()), findsNothing);
    });
  });

  group('Password visibility toggle', () {
    testWidgets('starts obscured and toggles when the eye icon is tapped', (
      tester,
    ) async {
      await pumpLoginScreen(tester);

      expect(cubit.state.obscurePassword, isTrue);
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
      expect(find.byIcon(Icons.visibility_outlined), findsNothing);

      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pump();

      expect(cubit.state.obscurePassword, isFalse);
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off_outlined), findsNothing);
    });
  });

  group('Submit button state', () {
    testWidgets('is disabled and never signs in while the fields are empty', (
      tester,
    ) async {
      await pumpLoginScreen(tester);

      // The button stays disabled until both fields are valid, so the empty
      // form can never trigger a sign-in.
      final button = tester.widget<ElevatedButton>(loginButton());
      expect(button.onPressed, isNull);

      await tester.tap(loginButton());
      await tester.pump();

      verifyNever(mockUseCase(any));
    });

    testWidgets('is disabled while the credentials are invalid', (
      tester,
    ) async {
      await pumpLoginScreen(tester);

      await enterCredentials(tester, email: 'bad', password: '123');

      final button = tester.widget<ElevatedButton>(loginButton());
      expect(button.onPressed, isNull);
    });

    testWidgets('is enabled once the credentials are valid', (tester) async {
      await pumpLoginScreen(tester);

      await enterCredentials(
        tester,
        email: validEmail,
        password: validPassword,
      );

      final button = tester.widget<ElevatedButton>(loginButton());
      expect(button.onPressed, isNotNull);
    });
  });

  group('Signing in', () {
    testWidgets('calls the use case with the entered credentials', (
      tester,
    ) async {
      // Left pending so the sign-in never completes: this test only asserts
      // what was sent, not the caching/navigation that follows.
      when(
        mockUseCase(any),
      ).thenAnswer((_) => Completer<BaseResponse<SignInEntity>>().future);

      await pumpLoginScreen(tester);
      await enterCredentials(
        tester,
        email: validEmail,
        password: validPassword,
      );

      await tester.tap(loginButton());
      await tester.pump();

      final captured =
          verify(mockUseCase(captureAny)).captured.single as SignInRequestModel;
      expect(captured.email, validEmail);
      expect(captured.password, validPassword);
    });

    testWidgets('a successful sign-in caches the token and the user data', (
      tester,
    ) async {
      when(mockUseCase(any)).thenAnswer(
        (_) async => SuccessBaseResponse(
          const SignInEntity(
            message: 'success',
            token: 'token-123',
            user: UserEntity(id: 'u1', firstName: 'Ahmed'),
          ),
        ),
      );

      await pumpLoginScreen(tester);
      await enterCredentials(
        tester,
        email: validEmail,
        password: validPassword,
      );

      await tester.tap(loginButton());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Token + full user data are persisted (per the acceptance criteria).
      verify(
        mockCache.writeData(key: anyNamed('key'), value: 'token-123'),
      ).called(1);
      verify(
        mockCache.writeData(
          key: anyNamed('key'),
          value: argThat(contains('Ahmed'), named: 'value'),
        ),
      ).called(1);

      // The success toast is shown too; drop it so its timers don't outlive
      // the test.
      BotToast.cleanAll();
      await tester.pump();
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('a server error surfaces the message and caches nothing', (
      tester,
    ) async {
      const errorMessage = 'Invalid email or password';
      when(
        mockUseCase(any),
      ).thenAnswer((_) async => ErrorBaseResponse<SignInEntity>(errorMessage));

      await pumpLoginScreen(tester);
      await enterCredentials(
        tester,
        email: validEmail,
        password: validPassword,
      );

      await tester.tap(loginButton());
      // Drain the async sign-in flow, then let BotToast insert and animate its
      // notification in before asserting on the message.
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      verify(mockUseCase(any)).called(1);
      expect(find.text(errorMessage), findsOneWidget);
      // No session is cached on failure.
      verifyNever(
        mockCache.writeData(key: anyNamed('key'), value: anyNamed('value')),
      );

      // Remove the toast, then advance past its 4s auto-dismiss so no timers
      // are left pending at teardown.
      BotToast.cleanAll();
      await tester.pump();
      await tester.pump(const Duration(seconds: 5));
    });
  });

  group('Localization', () {
    testWidgets('shows Arabic text when the locale changes to Arabic', (
      tester,
    ) async {
      final en = translations[AppConstants.englishCode]!;
      final ar = translations[AppConstants.arabicCode]!;

      await pumpLoginScreen(tester);
      expect(find.text(en['login'] as String), findsWidgets);

      // Re-render with the Arabic locale. A fresh cubit is used because the
      // event stream is single-subscription and the first screen already
      // listened to the shared one.
      final arabicCubit = LoginCubit(
        mockUseCase,
        mockCache,
        mockGoogleAuthService,
      );
      addTearDown(() async {
        if (!arabicCubit.isClosed) await arabicCubit.close();
      });
      await pumpLoginScreen(
        tester,
        locale: const Locale('ar'),
        loginCubit: arabicCubit,
      );

      expect(find.text(en['login'] as String), findsNothing);
      expect(find.text(ar['login'] as String), findsWidgets);
      expect(find.text(ar['email'] as String), findsOneWidget);
      expect(find.text(ar['password'] as String), findsOneWidget);
    });
  });
}
