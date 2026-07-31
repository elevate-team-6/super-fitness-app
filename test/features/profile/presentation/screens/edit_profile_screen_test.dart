import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_fitness/config/di/di.dart';
import 'package:super_fitness/core/utils/app_constants.dart';
import 'package:super_fitness/core/utils/app_routes.dart';
import 'package:super_fitness/core/widgets/custom_text_field.dart';
import 'package:super_fitness/features/auth/domain/entities/user_entity.dart';
import 'package:super_fitness/features/profile/domain/entities/complete_register_mode.dart';
import 'package:super_fitness/features/profile/domain/use_cases/edit_profile_use_case.dart';
import 'package:super_fitness/features/profile/domain/use_cases/upload_profile_photo_use_case.dart';
import 'package:super_fitness/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:super_fitness/features/profile/presentation/view_model/edit_profile_view_model/edit_profile_cubit.dart';
import 'package:super_fitness/features/profile/presentation/view_model/edit_profile_view_model/edit_profile_event.dart';
import 'package:super_fitness/features/profile/presentation/widgets/edit_profile_avatar.dart';
import 'package:super_fitness/features/profile/presentation/widgets/tappable_edit_field.dart';

import 'edit_profile_screen_test.mocks.dart';

class _InMemoryAssetLoader extends AssetLoader {
  const _InMemoryAssetLoader(this._data);
  final Map<String, Map<String, dynamic>> _data;

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async =>
      _data[locale.languageCode] ?? const {};
}

@GenerateMocks([EditProfileUseCase, UploadProfilePhotoUseCase])
void main() {
  late MockEditProfileUseCase editProfileUseCase;
  late MockUploadProfilePhotoUseCase uploadPhotoUseCase;
  late Map<String, Map<String, dynamic>> translations;
  RouteSettings? pushedRoute;

  const surfaceSize = Size(375, 812);

  const testUser = UserEntity(
    id: '123',
    firstName: 'Ahmed',
    lastName: 'Mohamed',
    email: 'ahmed@example.com',
    gender: 'male',
    age: 25,
    weight: 80,
    height: 180,
    goal: 'gainWeight',
    activityLevel: 'level1',
  );

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
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
    editProfileUseCase = MockEditProfileUseCase();
    uploadPhotoUseCase = MockUploadProfilePhotoUseCase();
    pushedRoute = null;

    getIt.registerFactory<EditProfileCubit>(
      () => EditProfileCubit(editProfileUseCase, uploadPhotoUseCase),
    );
  });

  tearDown(() => getIt.reset());

  Widget createWidgetUnderTest({UserEntity user = testUser}) {
    final cubit = getIt<EditProfileCubit>()
      ..doEvent(InitializeProfileEvent(user));

    return EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: AppConstants.translationsPath,
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('en'),
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
            home: BlocProvider.value(
              value: cubit,
              child: EditProfileScreen(user: user),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> pumpScreen(
    WidgetTester tester, {
    UserEntity user = testUser,
  }) async {
    tester.view.physicalSize = surfaceSize;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createWidgetUnderTest(user: user));
    await tester.pumpAndSettle();
  }

  group('EditProfileScreen UI & Form Initial Values', () {
    testWidgets('renders all core UI elements and displays user information', (
      tester,
    ) async {
      await pumpScreen(tester);

      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.byType(EditProfileAvatar), findsOneWidget);
      expect(find.text('Ahmed Mohamed'), findsOneWidget);

      expect(find.byType(CustomTextField), findsNWidgets(3));
      expect(find.byType(TappableEditField), findsNWidgets(6));
    });

    testWidgets('initializes text fields with user data', (tester) async {
      await pumpScreen(tester);

      expect(find.text('Ahmed'), findsOneWidget);
      expect(find.text('Mohamed'), findsOneWidget);
      expect(find.text('ahmed@example.com'), findsOneWidget);
    });

    testWidgets('Update button is initially disabled', (tester) async {
      await pumpScreen(tester);

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets(
      'Update button enables when First Name changes and disables when reverted',
      (tester) async {
        await pumpScreen(tester);

        final firstNameField = find.byType(CustomTextField).at(0);
        await tester.enterText(firstNameField, 'Mustafa');
        await tester.pumpAndSettle();

        ElevatedButton button = tester.widget<ElevatedButton>(
          find.byType(ElevatedButton),
        );
        expect(button.onPressed, isNotNull);

        await tester.enterText(firstNameField, 'Ahmed');
        await tester.pumpAndSettle();

        button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(button.onPressed, isNull);
      },
    );

    testWidgets(
      'Update button enables when Last Name changes and disables when reverted',
      (tester) async {
        await pumpScreen(tester);

        final lastNameField = find.byType(CustomTextField).at(1);
        await tester.enterText(lastNameField, 'Ibrahim');
        await tester.pumpAndSettle();

        ElevatedButton button = tester.widget<ElevatedButton>(
          find.byType(ElevatedButton),
        );
        expect(button.onPressed, isNotNull);

        await tester.enterText(lastNameField, 'Mohamed');
        await tester.pumpAndSettle();

        button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(button.onPressed, isNull);
      },
    );

    testWidgets(
      'Update button enables when Email changes and disables when reverted',
      (tester) async {
        await pumpScreen(tester);

        final emailField = find.byType(CustomTextField).at(2);
        await tester.enterText(emailField, 'new@example.com');
        await tester.pumpAndSettle();

        ElevatedButton button = tester.widget<ElevatedButton>(
          find.byType(ElevatedButton),
        );
        expect(button.onPressed, isNotNull);

        await tester.enterText(emailField, 'ahmed@example.com');
        await tester.pumpAndSettle();

        button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(button.onPressed, isNull);
      },
    );
  });

  group('EditProfileScreen Tappable Read-Only Rows Navigation', () {
    testWidgets('tapping Weight field navigates to completeRegister', (
      tester,
    ) async {
      await pumpScreen(tester);

      final weightTile = find.byType(TappableEditField).at(0);
      expect(weightTile, findsOneWidget);

      await tester.ensureVisible(weightTile);
      await tester.tap(weightTile);
      await tester.pumpAndSettle();

      expect(pushedRoute, isNotNull);
      expect(pushedRoute!.name, equals(AppRoutes.completeRegister));
      final args = pushedRoute!.arguments as CompleteRegisterArgs;
      expect(args.mode, equals(CompleteRegisterMode.edit));
    });

    testWidgets('tapping Goal field navigates to completeRegister', (
      tester,
    ) async {
      await pumpScreen(tester);

      final goalTile = find.byType(TappableEditField).at(1);
      expect(goalTile, findsOneWidget);

      await tester.ensureVisible(goalTile);
      await tester.tap(goalTile);
      await tester.pumpAndSettle();

      expect(pushedRoute, isNotNull);
      expect(pushedRoute!.name, equals(AppRoutes.completeRegister));
    });

    testWidgets('tapping Activity Level field navigates to completeRegister', (
      tester,
    ) async {
      await pumpScreen(tester);

      final activityTile = find.byType(TappableEditField).at(2);
      expect(activityTile, findsOneWidget);

      await tester.ensureVisible(activityTile);
      await tester.tap(activityTile);
      await tester.pumpAndSettle();

      expect(pushedRoute, isNotNull);
      expect(pushedRoute!.name, equals(AppRoutes.completeRegister));
    });

    testWidgets('tapping Gender field navigates to completeRegister', (
      tester,
    ) async {
      await pumpScreen(tester);

      final genderTile = find.byType(TappableEditField).at(3);
      expect(genderTile, findsOneWidget);

      await tester.ensureVisible(genderTile);
      await tester.tap(genderTile);
      await tester.pumpAndSettle();

      expect(pushedRoute, isNotNull);
      expect(pushedRoute!.name, equals(AppRoutes.completeRegister));
    });

    testWidgets('tapping Age field navigates to completeRegister', (
      tester,
    ) async {
      await pumpScreen(tester);

      final ageTile = find.byType(TappableEditField).at(4);
      expect(ageTile, findsOneWidget);

      await tester.ensureVisible(ageTile);
      await tester.tap(ageTile);
      await tester.pumpAndSettle();

      expect(pushedRoute, isNotNull);
      expect(pushedRoute!.name, equals(AppRoutes.completeRegister));
    });

    testWidgets('tapping Height field navigates to completeRegister', (
      tester,
    ) async {
      await pumpScreen(tester);

      final heightTile = find.byType(TappableEditField).at(5);
      expect(heightTile, findsOneWidget);

      await tester.ensureVisible(heightTile);
      await tester.tap(heightTile);
      await tester.pumpAndSettle();

      expect(pushedRoute, isNotNull);
      expect(pushedRoute!.name, equals(AppRoutes.completeRegister));
    });
  });
}
