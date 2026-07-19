import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_fitness/config/cache/secure_cache_helper.dart';
import 'package:super_fitness/config/di/di.dart';
import 'package:super_fitness/config/services/exit_app_dialog.dart';
import 'package:super_fitness/core/utils/app_constants.dart';
import 'package:super_fitness/core/utils/app_keys.dart';
import 'package:super_fitness/core/utils/app_routes.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/features/onboarding/screens/onboarding_screen.dart';
import 'package:super_fitness/features/onboarding/widgets/onboarding_skip_button.dart';

import 'onboarding_screen_test.mocks.dart';

class _InMemoryAssetLoader extends AssetLoader {
  const _InMemoryAssetLoader(this._data);
  final Map<String, Map<String, dynamic>> _data;

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async =>
      _data[locale.languageCode] ?? const {};
}

@GenerateMocks(
  [SecureCacheHelper],
  customMocks: [
    MockSpec<NavigatorObserver>(onMissingStub: OnMissingStub.returnDefault),
  ],
)
void main() {
  late MockSecureCacheHelper mockSecureCacheHelper;
  late MockNavigatorObserver mockNavigatorObserver;
  late Map<String, Map<String, dynamic>> translations;

  const surfaceSize = Size(375, 812);

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();

    translations = {
      AppConstants.englishCode: json.decode(
        await rootBundle.loadString(
          '${AppConstants.translationsPath}/${AppConstants.englishCode}.json',
        ),
      ) as Map<String, dynamic>,
      AppConstants.arabicCode: json.decode(
        await rootBundle.loadString(
          '${AppConstants.translationsPath}/${AppConstants.arabicCode}.json',
        ),
      ) as Map<String, dynamic>,
    };
  });

  setUp(() {
    mockSecureCacheHelper = MockSecureCacheHelper();
    mockNavigatorObserver = MockNavigatorObserver();

    // Register dependencies in GetIt
    if (getIt.isRegistered<SecureCacheHelper>()) {
      getIt.unregister<SecureCacheHelper>();
    }
    getIt.registerLazySingleton<SecureCacheHelper>(() => mockSecureCacheHelper);

    // Stub writeData to avoid null errors
    when(
      mockSecureCacheHelper.writeData(
        key: anyNamed('key'),
        value: anyNamed('value'),
      ),
    ).thenAnswer((_) async => {});
  });

  Widget createWidgetUnderTest({Locale locale = const Locale('en')}) {
    return EasyLocalization(
      key: ValueKey(locale),
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: AppConstants.translationsPath,
      fallbackLocale: const Locale('en'),
      startLocale: locale,
      assetLoader: _InMemoryAssetLoader(translations),
      child: Builder(
        builder: (context) => ScreenUtilInit(
          designSize: surfaceSize,
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return MaterialApp(
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              onGenerateRoute: (settings) {
                if (settings.name == AppRoutes.login) {
                  return MaterialPageRoute(
                    settings: settings,
                    builder: (context) =>
                        const Scaffold(body: Text('Login Screen')),
                  );
                }
                return null;
              },
              navigatorObservers: [mockNavigatorObserver],
              home: const OnboardingScreen(),
            );
          },
        ),
      ),
    );
  }

  Future<void> pumpOnboarding(WidgetTester tester,
      {Locale locale = const Locale('en')}) async {
    tester.view.physicalSize = surfaceSize;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createWidgetUnderTest(locale: locale));
    await tester.pumpAndSettle();
  }

  group('OnboardingScreen Professional Tests', () {
    testWidgets('Initial State: Should render first page correctly', (
      WidgetTester tester,
    ) async {
      await pumpOnboarding(tester);

      // Verify Skip button is visible on first page
      expect(find.byType(OnboardingSkipButton), findsOneWidget);
      expect(find.text(AppStrings.skip.tr()), findsOneWidget);

      // Verify first page content
      expect(find.text(AppStrings.onboardingTitle1.tr()), findsOneWidget);
      expect(find.text(AppStrings.onboardingDesc1.tr()), findsOneWidget);

      // Verify Next button is present and Back button is NOT
      expect(find.text(AppStrings.next.tr()), findsOneWidget);
      expect(find.text(AppStrings.back.tr()), findsNothing);
    });

    testWidgets('Navigation: Should move through pages and update UI', (
      WidgetTester tester,
    ) async {
      await pumpOnboarding(tester);

      // 1. Move to Second Page
      await tester.tap(find.text(AppStrings.next.tr()));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.onboardingTitle2.tr()), findsOneWidget);
      expect(
          find.text(AppStrings.back.tr()), findsOneWidget); // Back should appear
      expect(find.text(AppStrings.next.tr()), findsOneWidget);

      // 2. Move to Third Page (Last Page)
      await tester.tap(find.text(AppStrings.next.tr()));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.onboardingTitle3.tr()), findsOneWidget);
      expect(
        find.text(AppStrings.doIt.tr()),
        findsOneWidget,
      ); // "Do it" should appear
      expect(find.text(AppStrings.skip.tr()), findsNothing); // Skip should disappear

      // 3. Go Back to Second Page
      await tester.tap(find.text(AppStrings.back.tr()));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.onboardingTitle2.tr()), findsOneWidget);
      expect(find.text(AppStrings.next.tr()), findsOneWidget);
    });

    testWidgets('Skip Functionality: Should jump to the last page', (
      WidgetTester tester,
    ) async {
      await pumpOnboarding(tester);

      // Tap Skip
      await tester.tap(find.text(AppStrings.skip.tr()));
      await tester.pumpAndSettle();

      // Should be on the last page
      expect(find.text(AppStrings.onboardingTitle3.tr()), findsOneWidget);
      expect(find.text(AppStrings.doIt.tr()), findsOneWidget);
      expect(find.text(AppStrings.skip.tr()), findsNothing);
    });

    testWidgets(
      'Completion: Should save completion state and navigate to login',
      (WidgetTester tester) async {
        await pumpOnboarding(tester);

        // Go to last page
        await tester.tap(find.text(AppStrings.skip.tr()));
        await tester.pumpAndSettle();

        // Tap "Do it"
        await tester.tap(find.text(AppStrings.doIt.tr()));
        await tester.pumpAndSettle();

        // Verify AuthService.setOnboardingCompleted was called with correct key/value
        verify(
          mockSecureCacheHelper.writeData(
            key: AppKeys.onboardingKey,
            value: 'true',
          ),
        ).called(1);

        // Verify navigation to login
        expect(find.text('Login Screen'), findsOneWidget);
      },
    );

    testWidgets(
      'Back Button Handling: Should show ExitAppDialog on first page',
      (WidgetTester tester) async {
        await pumpOnboarding(tester);

        // Find PopScope and simulate back press
        final Finder popScopeFinder = find.byWidgetPredicate(
          (widget) => widget is PopScope,
        );
        expect(popScopeFinder, findsOneWidget);
        final PopScope popScope = tester.widget<PopScope>(popScopeFinder);

        // Invoke the callback
        popScope.onPopInvokedWithResult!(false, null);
        await tester.pumpAndSettle();

        // Verify ExitAppDialog is shown
        expect(find.byType(ExitAppDialog), findsOneWidget);
        expect(find.text(AppStrings.exitAppTitle.tr()), findsOneWidget);
      },
    );

    testWidgets(
      'Back Button Handling: Should go back one page if not on first page',
      (WidgetTester tester) async {
        await pumpOnboarding(tester);

        // Go to second page
        await tester.tap(find.text(AppStrings.next.tr()));
        await tester.pumpAndSettle();

        expect(find.text(AppStrings.onboardingTitle2.tr()), findsOneWidget);

        // Simulate back press
        final Finder popScopeFinder = find.byWidgetPredicate(
          (widget) => widget is PopScope,
        );
        expect(popScopeFinder, findsOneWidget);
        final PopScope popScope = tester.widget<PopScope>(popScopeFinder);
        popScope.onPopInvokedWithResult!(false, null);
        await tester.pumpAndSettle();

        // Should be back on first page
        expect(find.text(AppStrings.onboardingTitle1.tr()), findsOneWidget);
        // Dialog should NOT be shown
        expect(find.byType(ExitAppDialog), findsNothing);
      },
    );

    testWidgets('Localization: Should switch language correctly',
        (WidgetTester tester) async {
      // 1. Check English
      await pumpOnboarding(tester, locale: const Locale('en'));
      expect(find.text(translations['en']!['next']), findsOneWidget);

      // 2. Check Arabic by re-pumping (Standard practice for EasyLocalization tests)
      await pumpOnboarding(tester, locale: const Locale('ar'));
      expect(find.text(translations['ar']!['next']), findsOneWidget);
    });
  });
}
