import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/config/base_ui_event/base_ui_event.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/features/auth/domain/entities/user_entity.dart';
import 'package:super_fitness/features/profile/domain/use_cases/edit_profile_use_case.dart';
import 'package:super_fitness/features/profile/domain/use_cases/upload_profile_photo_use_case.dart';
import 'package:super_fitness/features/profile/presentation/view_model/edit_profile_view_model/edit_profile_cubit.dart';
import 'package:super_fitness/features/profile/presentation/view_model/edit_profile_view_model/edit_profile_event.dart';
import 'package:super_fitness/features/profile/presentation/view_model/edit_profile_view_model/edit_profile_state.dart';

import 'edit_profile_cubit_test.mocks.dart';

@GenerateMocks([EditProfileUseCase, UploadProfilePhotoUseCase])
void main() {
  late MockEditProfileUseCase editProfileUseCase;
  late MockUploadProfilePhotoUseCase uploadPhotoUseCase;

  const initialUser = UserEntity(
    id: 'user_1',
    firstName: 'Ahmed',
    lastName: 'Mohamed',
    email: 'ahmed@example.com',
    gender: 'male',
    age: 25,
    weight: 80,
    height: 180,
    goal: AppStrings.gainWeight,
    activityLevel: 'level1',
    photo: 'https://example.com/photo.png',
  );

  final dummyFile = File('test_path/photo.png');

  setUpAll(() {
    provideDummy<BaseResponse<UserEntity>>(const SuccessBaseResponse(null));
    provideDummy<BaseResponse<String>>(const SuccessBaseResponse(null));
  });

  setUp(() {
    editProfileUseCase = MockEditProfileUseCase();
    uploadPhotoUseCase = MockUploadProfilePhotoUseCase();
  });

  group('EditProfileCubit Initialization & Events', () {
    test('InitializeProfileEvent sets state correctly', () {
      final cubit = EditProfileCubit(editProfileUseCase, uploadPhotoUseCase);

      cubit.doEvent(const InitializeProfileEvent(initialUser));

      final state = cubit.state;
      expect(state.originalUser, equals(initialUser));
      expect(state.firstName, equals('Ahmed'));
      expect(state.lastName, equals('Mohamed'));
      expect(state.email, equals('ahmed@example.com'));
      expect(state.gender, equals('male'));
      expect(state.age, equals(25));
      expect(state.weight, equals(80));
      expect(state.height, equals(180));
      expect(state.goal, equals(AppStrings.gainWeight));
      expect(state.activityLevel, equals(AppStrings.sedentary));
      expect(state.selectedImage, isNull);
      expect(state.hasChanges, isFalse);
      expect(state.isFormValid, isTrue);

      cubit.close();
    });

    blocTest<EditProfileCubit, EditProfileState>(
      'UpdateFirstNameEvent updates only firstName',
      build: () => EditProfileCubit(editProfileUseCase, uploadPhotoUseCase),
      act: (cubit) => cubit.doEvent(const UpdateFirstNameEvent('Ali')),
      expect: () => [const EditProfileState(firstName: 'Ali')],
    );

    blocTest<EditProfileCubit, EditProfileState>(
      'UpdateLastNameEvent updates only lastName',
      build: () => EditProfileCubit(editProfileUseCase, uploadPhotoUseCase),
      act: (cubit) => cubit.doEvent(const UpdateLastNameEvent('Hassan')),
      expect: () => [const EditProfileState(lastName: 'Hassan')],
    );

    blocTest<EditProfileCubit, EditProfileState>(
      'UpdateEmailEvent updates only email',
      build: () => EditProfileCubit(editProfileUseCase, uploadPhotoUseCase),
      act: (cubit) => cubit.doEvent(const UpdateEmailEvent('ali@example.com')),
      expect: () => [const EditProfileState(email: 'ali@example.com')],
    );

    blocTest<EditProfileCubit, EditProfileState>(
      'UpdateGenderEvent updates only gender',
      build: () => EditProfileCubit(editProfileUseCase, uploadPhotoUseCase),
      act: (cubit) => cubit.doEvent(const UpdateGenderEvent('female')),
      expect: () => [const EditProfileState(gender: 'female')],
    );

    blocTest<EditProfileCubit, EditProfileState>(
      'UpdateAgeEvent updates only age',
      build: () => EditProfileCubit(editProfileUseCase, uploadPhotoUseCase),
      act: (cubit) => cubit.doEvent(const UpdateAgeEvent(30)),
      expect: () => [const EditProfileState(age: 30)],
    );

    blocTest<EditProfileCubit, EditProfileState>(
      'UpdateWeightEvent updates only weight',
      build: () => EditProfileCubit(editProfileUseCase, uploadPhotoUseCase),
      act: (cubit) => cubit.doEvent(const UpdateWeightEvent(90)),
      expect: () => [const EditProfileState(weight: 90)],
    );

    blocTest<EditProfileCubit, EditProfileState>(
      'UpdateHeightEvent updates only height',
      build: () => EditProfileCubit(editProfileUseCase, uploadPhotoUseCase),
      act: (cubit) => cubit.doEvent(const UpdateHeightEvent(185)),
      expect: () => [const EditProfileState(height: 185)],
    );

    blocTest<EditProfileCubit, EditProfileState>(
      'UpdateGoalEvent updates only goal',
      build: () => EditProfileCubit(editProfileUseCase, uploadPhotoUseCase),
      act: (cubit) =>
          cubit.doEvent(const UpdateGoalEvent(AppStrings.loseWeight)),
      expect: () => [const EditProfileState(goal: AppStrings.loseWeight)],
    );

    blocTest<EditProfileCubit, EditProfileState>(
      'UpdateActivityEvent updates only activityLevel',
      build: () => EditProfileCubit(editProfileUseCase, uploadPhotoUseCase),
      act: (cubit) =>
          cubit.doEvent(const UpdateActivityEvent(AppStrings.veryActive)),
      expect: () => [
        const EditProfileState(activityLevel: AppStrings.veryActive),
      ],
    );

    blocTest<EditProfileCubit, EditProfileState>(
      'UpdateImageEvent updates only selectedImage',
      build: () => EditProfileCubit(editProfileUseCase, uploadPhotoUseCase),
      act: (cubit) => cubit.doEvent(UpdateImageEvent(dummyFile)),
      expect: () => [EditProfileState(selectedImage: dummyFile)],
    );
  });

  group('EditProfileState Change Detection & Form Validation', () {
    late EditProfileCubit cubit;

    setUp(() {
      cubit = EditProfileCubit(editProfileUseCase, uploadPhotoUseCase);
      cubit.doEvent(const InitializeProfileEvent(initialUser));
    });

    tearDown(() => cubit.close());

    test(
      'hasChanges becomes true for each field modification and reverts when restored',
      () {
        expect(cubit.state.hasChanges, isFalse);

        cubit.doEvent(const UpdateFirstNameEvent('Mahmoud'));
        expect(cubit.state.hasChanges, isTrue);
        cubit.doEvent(const UpdateFirstNameEvent('Ahmed'));
        expect(cubit.state.hasChanges, isFalse);

        cubit.doEvent(const UpdateLastNameEvent('Ibrahim'));
        expect(cubit.state.hasChanges, isTrue);
        cubit.doEvent(const UpdateLastNameEvent('Mohamed'));
        expect(cubit.state.hasChanges, isFalse);

        cubit.doEvent(const UpdateEmailEvent('new@example.com'));
        expect(cubit.state.hasChanges, isTrue);
        cubit.doEvent(const UpdateEmailEvent('ahmed@example.com'));
        expect(cubit.state.hasChanges, isFalse);

        cubit.doEvent(const UpdateGenderEvent('female'));
        expect(cubit.state.hasChanges, isTrue);
        cubit.doEvent(const UpdateGenderEvent('male'));
        expect(cubit.state.hasChanges, isFalse);

        cubit.doEvent(const UpdateAgeEvent(40));
        expect(cubit.state.hasChanges, isTrue);
        cubit.doEvent(const UpdateAgeEvent(25));
        expect(cubit.state.hasChanges, isFalse);

        cubit.doEvent(const UpdateWeightEvent(95));
        expect(cubit.state.hasChanges, isTrue);
        cubit.doEvent(const UpdateWeightEvent(80));
        expect(cubit.state.hasChanges, isFalse);

        cubit.doEvent(const UpdateHeightEvent(190));
        expect(cubit.state.hasChanges, isTrue);
        cubit.doEvent(const UpdateHeightEvent(180));
        expect(cubit.state.hasChanges, isFalse);

        cubit.doEvent(const UpdateGoalEvent(AppStrings.loseWeight));
        expect(cubit.state.hasChanges, isTrue);
        cubit.doEvent(const UpdateGoalEvent(AppStrings.gainWeight));
        expect(cubit.state.hasChanges, isFalse);

        cubit.doEvent(const UpdateActivityEvent(AppStrings.extraActive));
        expect(cubit.state.hasChanges, isTrue);
        cubit.doEvent(const UpdateActivityEvent(AppStrings.sedentary));
        expect(cubit.state.hasChanges, isFalse);

        cubit.doEvent(UpdateImageEvent(dummyFile));
        expect(cubit.state.hasChanges, isTrue);
      },
    );

    test('isFormValid evaluates form validity accurately', () {
      expect(cubit.state.isFormValid, isTrue);

      cubit.doEvent(const UpdateFirstNameEvent(''));
      expect(cubit.state.isFormValid, isFalse);

      cubit.doEvent(const UpdateFirstNameEvent('Ahmed'));
      cubit.doEvent(const UpdateEmailEvent('invalid-email'));
      expect(cubit.state.isFormValid, isFalse);
    });
  });

  group('SaveProfileEvent Execution Cases', () {
    test(
      'Case 0: SaveProfileEvent does nothing when hasChanges is false',
      () async {
        final cubit = EditProfileCubit(editProfileUseCase, uploadPhotoUseCase);
        cubit.doEvent(const InitializeProfileEvent(initialUser));

        cubit.doEvent(const SaveProfileEvent());
        await Future.delayed(Duration.zero);

        verifyZeroInteractions(editProfileUseCase);
        verifyZeroInteractions(uploadPhotoUseCase);
        await cubit.close();
      },
    );

    test(
      'Case 1: Only profile fields changed -> calls EditProfileUseCase only',
      () async {
        final cubit = EditProfileCubit(editProfileUseCase, uploadPhotoUseCase);
        cubit.doEvent(const InitializeProfileEvent(initialUser));
        cubit.doEvent(const UpdateFirstNameEvent('Karem'));

        const updatedUser = UserEntity(
          id: 'user_1',
          firstName: 'Karem',
          lastName: 'Mohamed',
          email: 'ahmed@example.com',
          gender: 'male',
          age: 25,
          weight: 80,
          height: 180,
          goal: AppStrings.gainWeight,
          activityLevel: 'level1',
        );

        when(
          editProfileUseCase(any),
        ).thenAnswer((_) async => const SuccessBaseResponse(updatedUser));

        final events = <BaseUiEvent>[];
        cubit.eventStream.listen(events.add);

        cubit.doEvent(const SaveProfileEvent());
        await Future.delayed(Duration.zero);

        verify(editProfileUseCase(any)).called(1);
        verifyZeroInteractions(uploadPhotoUseCase);

        expect(events, contains(isA<ShowLoadingEvent>()));
        expect(events, contains(isA<HideLoadingEvent>()));
        expect(events, contains(isA<DisplaySuccessEvent>()));
        expect(events, contains(isA<NavigateEvent>()));

        expect(cubit.state.originalUser, equals(updatedUser));
        expect(cubit.state.hasChanges, isFalse);

        await cubit.close();
      },
    );

    test(
      'Case 2: Only image changed -> calls UploadProfilePhotoUseCase only',
      () async {
        final cubit = EditProfileCubit(editProfileUseCase, uploadPhotoUseCase);
        cubit.doEvent(const InitializeProfileEvent(initialUser));
        cubit.doEvent(UpdateImageEvent(dummyFile));

        when(
          uploadPhotoUseCase(dummyFile),
        ).thenAnswer((_) async => const SuccessBaseResponse('success'));

        final events = <BaseUiEvent>[];
        cubit.eventStream.listen(events.add);

        cubit.doEvent(const SaveProfileEvent());
        await Future.delayed(Duration.zero);

        verify(uploadPhotoUseCase(dummyFile)).called(1);
        verifyZeroInteractions(editProfileUseCase);

        expect(events, contains(isA<ShowLoadingEvent>()));
        expect(events, contains(isA<HideLoadingEvent>()));
        expect(events, contains(isA<DisplaySuccessEvent>()));
        expect(events, contains(isA<NavigateEvent>()));

        expect(cubit.state.selectedImage, isNull);
        expect(cubit.state.hasChanges, isFalse);

        await cubit.close();
      },
    );

    test(
      'Case 3: Both image and fields changed -> upload photo first, then edit profile',
      () async {
        final cubit = EditProfileCubit(editProfileUseCase, uploadPhotoUseCase);
        cubit.doEvent(const InitializeProfileEvent(initialUser));
        cubit.doEvent(UpdateImageEvent(dummyFile));
        cubit.doEvent(const UpdateLastNameEvent('Fawzy'));

        const updatedUser = UserEntity(
          id: 'user_1',
          firstName: 'Ahmed',
          lastName: 'Fawzy',
          email: 'ahmed@example.com',
          gender: 'male',
          age: 25,
          weight: 80,
          height: 180,
          goal: AppStrings.gainWeight,
          activityLevel: 'level1',
        );

        when(
          uploadPhotoUseCase(dummyFile),
        ).thenAnswer((_) async => const SuccessBaseResponse('success'));
        when(
          editProfileUseCase(any),
        ).thenAnswer((_) async => const SuccessBaseResponse(updatedUser));

        final events = <BaseUiEvent>[];
        cubit.eventStream.listen(events.add);

        cubit.doEvent(const SaveProfileEvent());
        await Future.delayed(Duration.zero);

        verifyInOrder([uploadPhotoUseCase(dummyFile), editProfileUseCase(any)]);

        expect(events, contains(isA<DisplaySuccessEvent>()));
        expect(cubit.state.selectedImage, isNull);
        expect(cubit.state.originalUser, equals(updatedUser));
        expect(cubit.state.hasChanges, isFalse);

        await cubit.close();
      },
    );

    test(
      'Case 3 Failure: If upload photo fails, edit profile is NOT called',
      () async {
        final cubit = EditProfileCubit(editProfileUseCase, uploadPhotoUseCase);
        cubit.doEvent(const InitializeProfileEvent(initialUser));
        cubit.doEvent(UpdateImageEvent(dummyFile));
        cubit.doEvent(const UpdateLastNameEvent('Fawzy'));

        when(
          uploadPhotoUseCase(dummyFile),
        ).thenAnswer((_) async => const ErrorBaseResponse('Network error'));

        final events = <BaseUiEvent>[];
        cubit.eventStream.listen(events.add);

        cubit.doEvent(const SaveProfileEvent());
        await Future.delayed(Duration.zero);

        verify(uploadPhotoUseCase(dummyFile)).called(1);
        verifyZeroInteractions(editProfileUseCase);

        expect(events, contains(isA<DisplayErrorEvent>()));
        expect(
          cubit.state.updateProfileState.errorMessage,
          equals('Network error'),
        );

        await cubit.close();
      },
    );
  });
}
