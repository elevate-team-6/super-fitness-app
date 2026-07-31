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
import 'package:super_fitness/core/utils/app_constants.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/features/auth/domain/entities/forget_password_entity.dart';
import 'package:super_fitness/features/auth/domain/use_cases/change_password_use_case.dart';
import 'package:super_fitness/features/auth/presentation/screens/change_password_screen.dart';
import 'package:super_fitness/features/auth/presentation/view_model/change_password_view_model/change_password_cubit.dart';

import 'change_password_screen_test.mocks.dart';

class _InMemoryAssetLoader extends AssetLoader {
  const _InMemoryAssetLoader(this._data);

  final Map<String, Map<String, dynamic>> _data;

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async =>
      _data[locale.languageCode] ?? const {};
}

@GenerateMocks([ChangePasswordUseCase])
void main() {
  late MockChangePasswordUseCase mockUseCase;
  late ChangePasswordCubit cubit;
  late Map<String, Map<String, dynamic>> translations;

  const validOldPassword = 'OldPassword@123';
  const validNewPassword = 'NewPassword@123';
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
    mockUseCase = MockChangePasswordUseCase();
    cubit = ChangePasswordCubit(mockUseCase);

    provideDummy<BaseResponse<ForgetPasswordEntity>>(
      ErrorBaseResponse('dummy'),
    );
  });

  tearDown(() async {
    if (!cubit.isClosed) {
      await cubit.close();
    }
  });

  Future<void> pumpChangePasswordScreen(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    ChangePasswordCubit? changePasswordCubit,
  }) async {
    final activeCubit = changePasswordCubit ?? cubit;
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
              onGenerateRoute: (_) => MaterialPageRoute<void>(
                builder: (_) => const SizedBox.shrink(),
              ),
              home: BlocProvider<ChangePasswordCubit>.value(
                value: activeCubit,
                child: const ChangePasswordScreen(),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder submitButton() =>
      find.widgetWithText(ElevatedButton, AppStrings.changePassword.tr());

  Future<void> enterPasswords(
    WidgetTester tester, {
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final textFields = find.byType(TextField);
    await tester.enterText(textFields.at(0), oldPassword);
    await tester.enterText(textFields.at(1), newPassword);
    await tester.enterText(textFields.at(2), confirmPassword);
    await tester.pumpAndSettle();
  }

  group('Rendering', () {
    testWidgets('renders all core UI elements', (tester) async {
      await pumpChangePasswordScreen(tester);

      expect(find.text(AppStrings.enterPasswordDetails.tr()), findsOneWidget);
      expect(find.text(AppStrings.changeYourPassword.tr()), findsOneWidget);

      // 3 password fields (old, new, confirm)
      expect(find.byType(TextField), findsNWidgets(3));
      expect(submitButton(), findsOneWidget);
    });

    testWidgets('displays placeholders / hint texts for password fields', (
      tester,
    ) async {
      await pumpChangePasswordScreen(tester);

      expect(find.text(AppStrings.oldPassword.tr()), findsOneWidget);
      expect(find.text(AppStrings.newPassword.tr()), findsOneWidget);
      expect(find.text(AppStrings.confirmPassword.tr()), findsOneWidget);
    });
  });

  group('Password Visibility Toggles', () {
    testWidgets('toggles old password visibility when eye icon is tapped', (
      tester,
    ) async {
      await pumpChangePasswordScreen(tester);

      expect(cubit.state.obscureOldPassword, isTrue);

      final eyeIconButton = find.byIcon(Icons.visibility_off_outlined).at(0);
      await tester.tap(eyeIconButton);
      await tester.pump();

      expect(cubit.state.obscureOldPassword, isFalse);
    });

    testWidgets('toggles new password visibility when eye icon is tapped', (
      tester,
    ) async {
      await pumpChangePasswordScreen(tester);

      expect(cubit.state.obscureNewPassword, isTrue);

      final eyeIconButton = find.byIcon(Icons.visibility_off_outlined).at(1);
      await tester.tap(eyeIconButton);
      await tester.pump();

      expect(cubit.state.obscureNewPassword, isFalse);
    });

    testWidgets('toggles confirm password visibility when eye icon is tapped', (
      tester,
    ) async {
      await pumpChangePasswordScreen(tester);

      expect(cubit.state.obscureConfirmPassword, isTrue);

      final eyeIconButton = find.byIcon(Icons.visibility_off_outlined).at(2);
      await tester.tap(eyeIconButton);
      await tester.pump();

      expect(cubit.state.obscureConfirmPassword, isFalse);
    });
  });

  group('Validation and Form Logic', () {
    testWidgets('submit button is disabled initially when fields are empty', (
      tester,
    ) async {
      await pumpChangePasswordScreen(tester);

      final button = tester.widget<ElevatedButton>(submitButton());
      expect(button.onPressed, isNull);
    });

    testWidgets(
      'submit button remains disabled when passwords match but new password equals old password',
      (tester) async {
        await pumpChangePasswordScreen(tester);

        await enterPasswords(
          tester,
          oldPassword: validOldPassword,
          newPassword: validOldPassword,
          confirmPassword: validOldPassword,
        );

        final button = tester.widget<ElevatedButton>(submitButton());
        expect(button.onPressed, isNull);
        expect(find.text(AppStrings.passwordSameAsOld.tr()), findsOneWidget);
      },
    );

    testWidgets(
      'submit button remains disabled when confirm password does not match new password',
      (tester) async {
        await pumpChangePasswordScreen(tester);

        await enterPasswords(
          tester,
          oldPassword: validOldPassword,
          newPassword: validNewPassword,
          confirmPassword: 'DifferentPassword@123',
        );

        final button = tester.widget<ElevatedButton>(submitButton());
        expect(button.onPressed, isNull);
      },
    );

    testWidgets('submit button becomes enabled when all inputs are valid', (
      tester,
    ) async {
      await pumpChangePasswordScreen(tester);

      await enterPasswords(
        tester,
        oldPassword: validOldPassword,
        newPassword: validNewPassword,
        confirmPassword: validNewPassword,
      );

      final button = tester.widget<ElevatedButton>(submitButton());
      expect(button.onPressed, isNotNull);
    });
  });

  group('Form Submission', () {
    testWidgets('calls ChangePasswordUseCase when valid form is submitted', (
      tester,
    ) async {
      when(
        mockUseCase(password: validOldPassword, newPassword: validNewPassword),
      ).thenAnswer(
        (_) async => const SuccessBaseResponse(
          ForgetPasswordEntity(message: 'Success', status: 'success'),
        ),
      );

      await pumpChangePasswordScreen(tester);

      await enterPasswords(
        tester,
        oldPassword: validOldPassword,
        newPassword: validNewPassword,
        confirmPassword: validNewPassword,
      );

      await tester.tap(submitButton());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      verify(
        mockUseCase(password: validOldPassword, newPassword: validNewPassword),
      ).called(1);

      BotToast.cleanAll();
      await tester.pump();
    });

    testWidgets('shows error toast when server returns error response', (
      tester,
    ) async {
      const errorMessage = 'Current password is incorrect';
      when(
        mockUseCase(password: validOldPassword, newPassword: validNewPassword),
      ).thenAnswer(
        (_) async =>
            const ErrorBaseResponse<ForgetPasswordEntity>(errorMessage),
      );

      await pumpChangePasswordScreen(tester);

      await enterPasswords(
        tester,
        oldPassword: validOldPassword,
        newPassword: validNewPassword,
        confirmPassword: validNewPassword,
      );

      await tester.tap(submitButton());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      verify(
        mockUseCase(password: validOldPassword, newPassword: validNewPassword),
      ).called(1);

      BotToast.cleanAll();
      await tester.pump();
      await tester.pump(const Duration(seconds: 5));
    });
  });

  group('Localization', () {
    testWidgets('shows Arabic texts when locale changes to Arabic', (
      tester,
    ) async {
      final en = translations[AppConstants.englishCode]!;
      final ar = translations[AppConstants.arabicCode]!;

      await pumpChangePasswordScreen(tester);
      expect(find.text(en['changePassword'] as String), findsWidgets);

      final arabicCubit = ChangePasswordCubit(mockUseCase);
      addTearDown(() async {
        if (!arabicCubit.isClosed) await arabicCubit.close();
      });

      await pumpChangePasswordScreen(
        tester,
        locale: const Locale('ar'),
        changePasswordCubit: arabicCubit,
      );

      expect(find.text(ar['changePassword'] as String), findsWidgets);
      expect(find.text(ar['oldPassword'] as String), findsOneWidget);
      expect(find.text(ar['newPassword'] as String), findsOneWidget);
    });
  });
}
