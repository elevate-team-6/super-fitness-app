import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/config/di/di.dart';
import 'package:super_fitness/core/utils/app_constants.dart';
import 'package:super_fitness/core/utils/app_routes.dart';
import 'package:super_fitness/features/auth/domain/entities/user_entity.dart';
import 'package:super_fitness/features/auth/domain/use_cases/logout_use_case.dart';
import 'package:super_fitness/features/profile/domain/use_cases/get_cached_user_use_case.dart';
import 'package:super_fitness/features/profile/presentation/screens/profile_screen.dart';
import 'package:super_fitness/features/profile/presentation/view_model/profile_view_model/profile_cubit.dart';
import 'package:super_fitness/features/profile/presentation/widgets/profile_header.dart';
import 'package:super_fitness/features/profile/presentation/widgets/profile_menu_item.dart';

import 'profile_screen_test.mocks.dart';

class _InMemoryAssetLoader extends AssetLoader {
  const _InMemoryAssetLoader(this._data);
  final Map<String, Map<String, dynamic>> _data;

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async =>
      _data[locale.languageCode] ?? const {};
}

@GenerateMocks([GetCachedUserUseCase, LogoutUseCase])
void main() {
  provideDummy<BaseResponse<void>>(const SuccessBaseResponse(null));
  late MockGetCachedUserUseCase useCase;
  late MockLogoutUseCase logoutUseCase;
  late Map<String, Map<String, dynamic>> translations;

  /// Set by the test navigator so a tap can be checked without building the
  /// real WebViewScreen, which needs a platform webview.
  RouteSettings? pushedRoute;

  const surfaceSize = Size(375, 812);

  const user = UserEntity(
    id: 'user_123',
    firstName: 'Ahmed',
    lastName: 'Emam',
    email: 'ahmed@example.com',
  );

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    // EasyLocalization persists the chosen locale through SharedPreferences,
    // which has no implementation in a widget test.
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();

    translations = {
      for (final code in [AppConstants.englishCode, AppConstants.arabicCode])
        code:
            json.decode(
                  await rootBundle.loadString(
                    '${AppConstants.translationsPath}/$code.json',
                  ),
                )
                as Map<String, dynamic>,
    };
  });

  setUp(() {
    useCase = MockGetCachedUserUseCase();
    logoutUseCase = MockLogoutUseCase();
    pushedRoute = null;

    // The screen pulls its cubit from the container rather than a route, so
    // the test has to stand one up.
    getIt.registerFactory<ProfileCubit>(
      () => ProfileCubit(useCase, logoutUseCase),
    );
  });

  tearDown(() => getIt.reset());

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
          builder: (context, child) => MaterialApp(
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            onGenerateRoute: (settings) {
              pushedRoute = settings;
              return MaterialPageRoute<void>(
                settings: settings,
                builder: (_) => const Scaffold(body: Text('pushed')),
              );
            },
            home: const ProfileScreen(),
          ),
        ),
      ),
    );
  }

  Future<void> pumpProfile(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
  }) async {
    tester.view.physicalSize = surfaceSize;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createWidgetUnderTest(locale: locale));
    await tester.pumpAndSettle();
  }

  ProfileMenuItem itemLabelled(WidgetTester tester, String label) {
    return tester
        .widgetList<ProfileMenuItem>(find.byType(ProfileMenuItem))
        .firstWhere((item) => item.label == label);
  }

  group('ProfileScreen', () {
    testWidgets('lays out all seven menu rows', (tester) async {
      when(useCase()).thenAnswer((_) async => user);

      await pumpProfile(tester);

      final labels = tester
          .widgetList<ProfileMenuItem>(find.byType(ProfileMenuItem))
          .map((item) => item.label)
          .toList();

      expect(labels, [
        'Edit Profile',
        'Change Password',
        'Select Language',
        'Security',
        'Privacy Policy',
        'Help',
        'Logout',
      ]);
    });

    testWidgets('shows the cached user in the header', (tester) async {
      when(useCase()).thenAnswer((_) async => user);

      await pumpProfile(tester);

      final header = tester.widget<ProfileHeader>(find.byType(ProfileHeader));
      expect(header.name, 'Ahmed Emam');
    });

    // Sessions that predate the user cache read back null; the header has to
    // degrade to just the avatar instead of an error or a blank line.
    testWidgets('leaves the name empty when nothing is cached', (tester) async {
      when(useCase()).thenAnswer((_) async => null);

      await pumpProfile(tester);

      final header = tester.widget<ProfileHeader>(find.byType(ProfileHeader));
      expect(header.name, isEmpty);
    });

    testWidgets('marks the language row with the active language', (
      tester,
    ) async {
      when(useCase()).thenAnswer((_) async => null);

      await pumpProfile(tester);

      expect(itemLabelled(tester, 'Select Language').highlight, 'English');
      expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
    });

    testWidgets('starts in Arabic when the app locale is Arabic', (
      tester,
    ) async {
      when(useCase()).thenAnswer((_) async => null);

      await pumpProfile(tester, locale: const Locale('ar'));

      expect(itemLabelled(tester, 'اختيار اللغة').highlight, 'العربية');
      expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
    });

    testWidgets('the switch flips the app language', (tester) async {
      when(useCase()).thenAnswer((_) async => null);

      await pumpProfile(tester);
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(find.text('الملف الشخصي'), findsOneWidget);
      expect(itemLabelled(tester, 'اختيار اللغة').highlight, 'العربية');
    });

    testWidgets('Security opens its page in the web view', (tester) async {
      when(useCase()).thenAnswer((_) async => null);

      await pumpProfile(tester);
      await tester.tap(find.text('Security'));
      await tester.pumpAndSettle();

      expect(pushedRoute?.name, AppRoutes.webView);
      final args = pushedRoute?.arguments as WebViewArgs;
      expect(args.url, AppConstants.securityUrl);
      expect(args.title, 'Security');
    });

    testWidgets('Privacy Policy opens its own page', (tester) async {
      when(useCase()).thenAnswer((_) async => null);

      await pumpProfile(tester);
      await tester.tap(find.text('Privacy Policy'));
      await tester.pumpAndSettle();

      expect(pushedRoute?.name, AppRoutes.webView);
      expect(
        (pushedRoute?.arguments as WebViewArgs).url,
        AppConstants.privacyPolicyUrl,
      );
    });

    testWidgets('Help opens its own page', (tester) async {
      when(useCase()).thenAnswer((_) async => null);

      await pumpProfile(tester);
      await tester.tap(find.text('Help'));
      await tester.pumpAndSettle();

      expect(pushedRoute?.name, AppRoutes.webView);
      expect((pushedRoute?.arguments as WebViewArgs).url, AppConstants.helpUrl);
    });

    testWidgets(
      'Logout shows confirmation dialog and calls cubit when confirmed',
      (tester) async {
        when(useCase()).thenAnswer((_) async => null);
        when(
          logoutUseCase(),
        ).thenAnswer((_) async => const SuccessBaseResponse(null));

        await pumpProfile(tester);

        await tester.tap(find.text('Logout'));
        await tester.pumpAndSettle();

        // Verify dialog is shown
        expect(find.text('Logout'), findsNWidgets(2)); // Title and Menu Item
        expect(find.text('Are you sure you want to log out?'), findsOneWidget);

        // Confirm logout
        await tester.tap(find.text('Yes'));
        await tester.pumpAndSettle();

        verify(logoutUseCase()).called(1);
      },
    );
  });
}
