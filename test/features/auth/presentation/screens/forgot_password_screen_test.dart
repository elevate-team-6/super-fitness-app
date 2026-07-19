import 'dart:async';
import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_fitness/config/base_ui_event/base_ui_event.dart';
import 'package:super_fitness/core/utils/app_constants.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/core/widgets/custom_app_bar.dart';
import 'package:super_fitness/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:super_fitness/features/auth/presentation/view_model/forget_password_view_model/forgot_password_cubit.dart';
import 'package:super_fitness/features/auth/presentation/view_model/forget_password_view_model/forgot_password_events.dart';
import 'package:super_fitness/features/auth/presentation/view_model/forget_password_view_model/forgot_password_state.dart';

class _InMemoryAssetLoader extends AssetLoader {
  const _InMemoryAssetLoader(this._data);

  final Map<String, Map<String, dynamic>> _data;

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async =>
      _data[locale.languageCode] ?? const {};
}

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
            returnValueForMissingStub:
                const Stream<ForgotPasswordState>.empty(),
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
    mockForgotPasswordCubit = MockForgotPasswordCubit();
  });

  Future<void> pumpForgotPasswordScreen(
    WidgetTester tester,
    ForgotPasswordState state, {
    Locale locale = const Locale('en'),
  }) async {
    when(mockForgotPasswordCubit.state).thenReturn(state);
    when(
      mockForgotPasswordCubit.stream,
    ).thenAnswer((_) => const Stream.empty());
    when(
      mockForgotPasswordCubit.eventStream,
    ).thenAnswer((_) => const Stream.empty());

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
              home: BlocProvider<ForgotPasswordCubit>.value(
                value: mockForgotPasswordCubit,
                child: const ForgotPasswordScreen(),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('ForgotPasswordScreen Step-based Tests', () {
    testWidgets('Step 0: Email Entry - Interaction', (tester) async {
      const state = ForgotPasswordState(currentStep: 0);
      await pumpForgotPasswordScreen(tester, state);

      expect(find.text(AppStrings.forgetPassword.tr()), findsWidgets);
      expect(find.text(AppStrings.enterEmail.tr()), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'test@test.com');
      await tester.pump();

      final button = find.widgetWithText(
        ElevatedButton,
        AppStrings.sentOtP.tr(),
      );
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
      await pumpForgotPasswordScreen(tester, state);

      expect(find.text(AppStrings.otpCode.tr()), findsOneWidget);
      expect(find.text(AppStrings.enterOtp.tr()), findsOneWidget);
    });

    testWidgets('Step 2: New Password Entry Display', (tester) async {
      const state = ForgotPasswordState(currentStep: 2);
      await pumpForgotPasswordScreen(tester, state);

      expect(find.text(AppStrings.createNewPassword.tr()), findsOneWidget);
      expect(find.text(AppStrings.passwordMoreCharacter.tr()), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));
    });

    testWidgets('Navigation: Back Button triggers UpdateStepEvent', (
      tester,
    ) async {
      const state = ForgotPasswordState(currentStep: 1);
      await pumpForgotPasswordScreen(tester, state);

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
      await pumpForgotPasswordScreen(tester, state);

      await tester.enterText(find.byType(TextField), 'invalid-email');
      await tester.pump();

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });
  });
}
