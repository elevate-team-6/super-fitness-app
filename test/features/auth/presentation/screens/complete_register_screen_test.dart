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
import 'package:super_fitness/features/auth/presentation/screens/complete_register_screen.dart';
import 'package:super_fitness/features/auth/presentation/view_model/register_view_model/register_cubit.dart';
import 'package:super_fitness/features/auth/presentation/view_model/register_view_model/register_event.dart';
import 'package:super_fitness/features/auth/presentation/view_model/register_view_model/register_state.dart';

class _InMemoryAssetLoader extends AssetLoader {
  const _InMemoryAssetLoader(this._data);

  final Map<String, Map<String, dynamic>> _data;

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async =>
      _data[locale.languageCode] ?? const {};
}

// Manual Mock for RegisterCubit using Mockito
class MockRegisterCubit extends Mock implements RegisterCubit {
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
  late MockRegisterCubit mockRegisterCubit;
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
  });

  Future<void> pumpCompleteRegisterScreen(
    WidgetTester tester,
    RegisterState state, {
    Locale locale = const Locale('en'),
  }) async {
    when(mockRegisterCubit.state).thenReturn(state);
    when(mockRegisterCubit.stream).thenAnswer((_) => const Stream.empty());
    when(mockRegisterCubit.eventStream).thenAnswer((_) => const Stream.empty());

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
              home: BlocProvider<RegisterCubit>.value(
                value: mockRegisterCubit,
                child: const CompleteRegisterScreen(),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('CompleteRegisterScreen Professional Tests (Mockito)', () {
    testWidgets('Step 1: Gender Selection - Interaction', (tester) async {
      const state = RegisterState(currentStep: 1, gender: '');
      await pumpCompleteRegisterScreen(tester, state);

      expect(
        find.text(AppStrings.tellUsAboutYourself.tr().toUpperCase()),
        findsOneWidget,
      );

      final maleFinder = find.text(AppStrings.male.tr());
      expect(maleFinder, findsOneWidget);

      await tester.tap(maleFinder);

      verify(
        mockRegisterCubit.doEvent(argThat(isA<SelectGenderEvent>())),
      ).called(1);
    });

    testWidgets('Step 2: Age Selection Display', (tester) async {
      const state = RegisterState(currentStep: 2, age: 30);
      await pumpCompleteRegisterScreen(tester, state);

      expect(find.text(AppStrings.ageTitle.tr().toUpperCase()), findsOneWidget);
      expect(find.text('30'), findsOneWidget);
    });

    testWidgets('Step 5: Goal Selection Interaction', (tester) async {
      const state = RegisterState(currentStep: 5, goal: '');
      await pumpCompleteRegisterScreen(tester, state);

      final goalOption = find.text(AppStrings.gainWeight.tr());
      expect(goalOption, findsOneWidget);

      await tester.tap(goalOption, warnIfMissed: false);
      verify(
        mockRegisterCubit.doEvent(argThat(isA<SelectGoalEvent>())),
      ).called(1);
    });

    testWidgets('Step 6: Activity Level Submission', (tester) async {
      const state = RegisterState(currentStep: 6, activityLevel: 'Active');
      await pumpCompleteRegisterScreen(tester, state);

      expect(find.text(AppStrings.done.tr()), findsOneWidget);

      await tester.tap(find.text(AppStrings.done.tr()), warnIfMissed: false);
      verify(
        mockRegisterCubit.doEvent(argThat(isA<SubmitSignupEvent>())),
      ).called(1);
    });

    testWidgets('Navigation: Back Button triggers PreviousStepEvent', (
      tester,
    ) async {
      const state = RegisterState(currentStep: 2);
      await pumpCompleteRegisterScreen(tester, state);

      final backButton = find.descendant(
        of: find.byType(CustomAppBar),
        matching: find.byType(GestureDetector),
      );
      await tester.tap(backButton);

      verify(
        mockRegisterCubit.doEvent(argThat(isA<PreviousStepEvent>())),
      ).called(1);
    });

    testWidgets('Validation: Next button enabled state', (tester) async {
      const validState = RegisterState(currentStep: 3, weight: 70);
      await pumpCompleteRegisterScreen(tester, validState);

      final nextButton = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(nextButton.onPressed, isNotNull);
    });

    testWidgets('Step 1: Female Gender Selection', (tester) async {
      const state = RegisterState(currentStep: 1, gender: '');
      await pumpCompleteRegisterScreen(tester, state);

      final femaleFinder = find.text(AppStrings.female.tr());
      expect(femaleFinder, findsOneWidget);

      await tester.tap(femaleFinder);
      verify(
        mockRegisterCubit.doEvent(argThat(isA<SelectGenderEvent>())),
      ).called(1);
    });

    testWidgets('Step 2: Age Selection Interaction', (tester) async {
      const state = RegisterState(currentStep: 2, age: 25);
      await pumpCompleteRegisterScreen(tester, state);

      expect(find.text(AppStrings.ageTitle.tr().toUpperCase()), findsOneWidget);
      expect(find.text('25'), findsOneWidget);
    });

    testWidgets('Step 3: Weight Selection Display', (tester) async {
      const state = RegisterState(currentStep: 3, weight: 75);
      await pumpCompleteRegisterScreen(tester, state);

      expect(
        find.text(AppStrings.weightTitle.tr().toUpperCase()),
        findsOneWidget,
      );
      expect(find.text('75'), findsOneWidget);
    });

    testWidgets('Step 4: Height Selection Display', (tester) async {
      const state = RegisterState(currentStep: 4, height: 175);
      await pumpCompleteRegisterScreen(tester, state);

      expect(
        find.text(AppStrings.heightTitle.tr().toUpperCase()),
        findsOneWidget,
      );
      expect(find.text('175'), findsOneWidget);
    });

    testWidgets('Step 5: Different Goal Options', (tester) async {
      const state = RegisterState(currentStep: 5, goal: '');
      await pumpCompleteRegisterScreen(tester, state);

      expect(find.text(AppStrings.loseWeight.tr()), findsOneWidget);
      expect(find.text(AppStrings.getFitter.tr()), findsOneWidget);
      expect(find.text(AppStrings.gainMoreFlexible.tr()), findsOneWidget);
      expect(find.text(AppStrings.learnTheBasic.tr()), findsOneWidget);
    });

    testWidgets('Step 6: Different Activity Level Options', (tester) async {
      const state = RegisterState(currentStep: 6, activityLevel: '');
      await pumpCompleteRegisterScreen(tester, state);

      expect(find.text(AppStrings.sedentary.tr()), findsOneWidget);
      expect(find.text(AppStrings.lightlyActive.tr()), findsOneWidget);
      expect(find.text(AppStrings.moderatelyActive.tr()), findsOneWidget);
      expect(find.text(AppStrings.veryActive.tr()), findsOneWidget);
      expect(find.text(AppStrings.extraActive.tr()), findsOneWidget);
    });

    testWidgets('Validation: Step 1 - Empty gender disables Next', (
      tester,
    ) async {
      const invalidState = RegisterState(currentStep: 1, gender: '');
      await pumpCompleteRegisterScreen(tester, invalidState);

      final nextButton = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(nextButton.onPressed, isNull);
    });

    testWidgets('Validation: Step 2 - Zero age disables Next', (tester) async {
      const invalidState = RegisterState(currentStep: 2, age: 0);
      await pumpCompleteRegisterScreen(tester, invalidState);

      final nextButton = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(nextButton.onPressed, isNull);
    });

    testWidgets('Validation: Step 3 - Zero weight disables Next', (
      tester,
    ) async {
      const invalidState = RegisterState(currentStep: 3, weight: 0);
      await pumpCompleteRegisterScreen(tester, invalidState);

      final nextButton = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(nextButton.onPressed, isNull);
    });

    testWidgets('Validation: Step 4 - Zero height disables Next', (
      tester,
    ) async {
      const invalidState = RegisterState(currentStep: 4, height: 0);
      await pumpCompleteRegisterScreen(tester, invalidState);

      final nextButton = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(nextButton.onPressed, isNull);
    });

    testWidgets('Validation: Step 5 - Empty goal disables Next', (
      tester,
    ) async {
      const invalidState = RegisterState(currentStep: 5, goal: '');
      await pumpCompleteRegisterScreen(tester, invalidState);

      final nextButton = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(nextButton.onPressed, isNull);
    });

    testWidgets('Validation: Step 6 - Empty activity level disables Done', (
      tester,
    ) async {
      const invalidState = RegisterState(currentStep: 6, activityLevel: '');
      await pumpCompleteRegisterScreen(tester, invalidState);

      final nextButton = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(nextButton.onPressed, isNull);
    });

    testWidgets('Navigation: Next button triggers NextStepEvent - Step 1', (
      tester,
    ) async {
      const validState = RegisterState(currentStep: 1, gender: 'Male');
      await pumpCompleteRegisterScreen(tester, validState);

      await tester.tap(find.text(AppStrings.next.tr()));
      verify(
        mockRegisterCubit.doEvent(argThat(isA<NextStepEvent>())),
      ).called(1);
    });

    testWidgets('Navigation: Next button triggers NextStepEvent - Step 2', (
      tester,
    ) async {
      const validState = RegisterState(currentStep: 2, age: 25);
      await pumpCompleteRegisterScreen(tester, validState);

      await tester.tap(find.text(AppStrings.next.tr()));
      verify(
        mockRegisterCubit.doEvent(argThat(isA<NextStepEvent>())),
      ).called(1);
    });

    testWidgets('Navigation: Next button triggers NextStepEvent - Step 3', (
      tester,
    ) async {
      const validState = RegisterState(currentStep: 3, weight: 70);
      await pumpCompleteRegisterScreen(tester, validState);

      await tester.tap(find.text(AppStrings.next.tr()));
      verify(
        mockRegisterCubit.doEvent(argThat(isA<NextStepEvent>())),
      ).called(1);
    });

    testWidgets('Navigation: Next button triggers NextStepEvent - Step 4', (
      tester,
    ) async {
      const validState = RegisterState(currentStep: 4, height: 175);
      await pumpCompleteRegisterScreen(tester, validState);

      await tester.tap(find.text(AppStrings.next.tr()));
      verify(
        mockRegisterCubit.doEvent(argThat(isA<NextStepEvent>())),
      ).called(1);
    });

    testWidgets('Navigation: Next button triggers NextStepEvent - Step 5', (
      tester,
    ) async {
      const validState = RegisterState(
        currentStep: 5,
        goal: AppStrings.loseWeight,
      );
      await pumpCompleteRegisterScreen(tester, validState);

      await tester.tap(find.text(AppStrings.next.tr()));
      verify(
        mockRegisterCubit.doEvent(argThat(isA<NextStepEvent>())),
      ).called(1);
    });

    testWidgets('Navigation: Back button from Step 1 navigates back', (
      tester,
    ) async {
      const state = RegisterState(currentStep: 1);
      await pumpCompleteRegisterScreen(tester, state);

      final backButton = find.descendant(
        of: find.byType(CustomAppBar),
        matching: find.byType(GestureDetector),
      );
      await tester.tap(backButton);

      verify(
        mockRegisterCubit.doEvent(argThat(isA<PreviousStepEvent>())),
      ).called(1);
    });

    testWidgets('Boundary Values: Age minimum (16)', (tester) async {
      const state = RegisterState(currentStep: 2, age: 16);
      await pumpCompleteRegisterScreen(tester, state);

      expect(find.text('16'), findsOneWidget);
      final nextButton = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(nextButton.onPressed, isNotNull);
    });

    testWidgets('Boundary Values: Age maximum (90)', (tester) async {
      const state = RegisterState(currentStep: 2, age: 90);
      await pumpCompleteRegisterScreen(tester, state);

      expect(find.text('90'), findsOneWidget);
      final nextButton = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(nextButton.onPressed, isNotNull);
    });

    testWidgets('Boundary Values: Weight minimum (30)', (tester) async {
      const state = RegisterState(currentStep: 3, weight: 30);
      await pumpCompleteRegisterScreen(tester, state);

      expect(find.text('30'), findsOneWidget);
      final nextButton = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(nextButton.onPressed, isNotNull);
    });

    testWidgets('Boundary Values: Weight maximum (250)', (tester) async {
      const state = RegisterState(currentStep: 3, weight: 250);
      await pumpCompleteRegisterScreen(tester, state);

      expect(find.text('250'), findsOneWidget);
      final nextButton = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(nextButton.onPressed, isNotNull);
    });

    testWidgets('Boundary Values: Height minimum (100)', (tester) async {
      const state = RegisterState(currentStep: 4, height: 100);
      await pumpCompleteRegisterScreen(tester, state);

      expect(find.text('100'), findsOneWidget);
      final nextButton = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(nextButton.onPressed, isNotNull);
    });

    testWidgets('Boundary Values: Height maximum (250)', (tester) async {
      const state = RegisterState(currentStep: 4, height: 250);
      await pumpCompleteRegisterScreen(tester, state);

      expect(find.text('250'), findsOneWidget);
      final nextButton = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(nextButton.onPressed, isNotNull);
    });
  });
}
