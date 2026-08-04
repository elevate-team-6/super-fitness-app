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
import 'package:super_fitness/features/auth/domain/entities/user_entity.dart';
import 'package:super_fitness/features/auth/presentation/screens/complete_register_screen.dart';
import 'package:super_fitness/features/auth/presentation/widgets/custom_horizontal_wheel_picker.dart';
import 'package:super_fitness/features/auth/presentation/widgets/gender_selection_view.dart';
import 'package:super_fitness/features/auth/presentation/widgets/selectable_option_list.dart';
import 'package:super_fitness/features/profile/domain/entities/complete_register_mode.dart';
import 'package:super_fitness/features/profile/domain/entities/edit_profile_section.dart';
import 'package:super_fitness/features/profile/domain/use_cases/edit_profile_use_case.dart';
import 'package:super_fitness/features/profile/domain/use_cases/upload_profile_photo_use_case.dart';
import 'package:super_fitness/features/profile/presentation/view_model/edit_profile_view_model/edit_profile_cubit.dart';
import 'package:super_fitness/features/profile/presentation/view_model/edit_profile_view_model/edit_profile_event.dart';

import 'complete_register_edit_mode_test.mocks.dart';

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
  dynamic poppedResult;

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
    poppedResult = null;

    getIt.registerFactory<EditProfileCubit>(
      () => EditProfileCubit(editProfileUseCase, uploadPhotoUseCase),
    );
  });

  tearDown(() => getIt.reset());

  Widget createWidgetUnderTest({
    required EditProfileSection section,
    UserEntity user = testUser,
  }) {
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
            home: Builder(
              builder: (navContext) => ElevatedButton(
                onPressed: () async {
                  poppedResult = await Navigator.push(
                    navContext,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: cubit,
                        child: CompleteRegisterScreen(
                          mode: CompleteRegisterMode.edit,
                          section: section,
                        ),
                      ),
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> pumpScreen(
    WidgetTester tester, {
    required EditProfileSection section,
    UserEntity user = testUser,
  }) async {
    tester.view.physicalSize = surfaceSize;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      createWidgetUnderTest(section: section, user: user),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  group('CompleteRegisterScreen Edit Mode Tests', () {
    testWidgets('EditProfileSection.gender opens Gender selection view', (
      tester,
    ) async {
      await pumpScreen(tester, section: EditProfileSection.gender);

      expect(find.byType(GenderSelectionView), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('EditProfileSection.age opens Age picker view', (tester) async {
      await pumpScreen(tester, section: EditProfileSection.age);

      expect(find.byType(CustomHorizontalWheelPicker), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('EditProfileSection.weight opens Weight picker view', (
      tester,
    ) async {
      await pumpScreen(tester, section: EditProfileSection.weight);

      expect(find.byType(CustomHorizontalWheelPicker), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('EditProfileSection.height opens Height picker view', (
      tester,
    ) async {
      await pumpScreen(tester, section: EditProfileSection.height);

      expect(find.byType(CustomHorizontalWheelPicker), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('EditProfileSection.goal opens Goal selectable option list', (
      tester,
    ) async {
      await pumpScreen(tester, section: EditProfileSection.goal);

      expect(find.byType(SelectableOptionList), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets(
      'EditProfileSection.activity opens Activity selectable option list',
      (tester) async {
        await pumpScreen(tester, section: EditProfileSection.activity);

        expect(find.byType(SelectableOptionList), findsOneWidget);
        expect(find.text('Save'), findsOneWidget);
      },
    );

    testWidgets('Tapping Save pops back returning current section value', (
      tester,
    ) async {
      await pumpScreen(tester, section: EditProfileSection.gender);

      final saveButton = find.widgetWithText(ElevatedButton, 'Save');
      expect(saveButton, findsOneWidget);

      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(poppedResult, equals('male'));
    });
  });
}
