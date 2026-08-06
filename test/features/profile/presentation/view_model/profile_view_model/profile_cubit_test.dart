import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/config/base_state/base_state.dart';
import 'package:super_fitness/config/base_ui_event/base_ui_event.dart';
import 'package:super_fitness/core/utils/app_routes.dart';
import 'package:super_fitness/features/auth/domain/entities/user_entity.dart';
import 'package:super_fitness/features/auth/domain/use_cases/logout_use_case.dart';
import 'package:super_fitness/features/profile/domain/use_cases/get_profile_data_use_case.dart';
import 'package:super_fitness/features/profile/presentation/view_model/profile_view_model/profile_cubit.dart';
import 'package:super_fitness/features/profile/presentation/view_model/profile_view_model/profile_event.dart';
import 'package:super_fitness/features/profile/presentation/view_model/profile_view_model/profile_state.dart';

import 'profile_cubit_test.mocks.dart';

@GenerateMocks([GetProfileDataUseCase, LogoutUseCase])
void main() {
  late MockGetProfileDataUseCase getProfileData;
  late MockLogoutUseCase logoutUseCase;

  const user = UserEntity(
    id: 'user_123',
    firstName: 'Ahmed',
    lastName: 'Emam',
    email: 'ahmed@example.com',
    photo: 'https://example.com/ahmed.png',
  );

  const updatedUser = UserEntity(
    id: 'user_123',
    firstName: 'Ahmed',
    lastName: 'Updated',
    email: 'ahmed@example.com',
    photo: 'https://example.com/updated.png',
  );

  setUpAll(() {
    provideDummy<BaseResponse<UserEntity>>(const ErrorBaseResponse('dummy'));
    provideDummy<BaseResponse<void>>(const SuccessBaseResponse(null));
  });

  setUp(() {
    getProfileData = MockGetProfileDataUseCase();
    logoutUseCase = MockLogoutUseCase();
  });

  void stubFetch({
    required bool isFromRemote,
    required BaseResponse<UserEntity> response,
  }) {
    when(getProfileData(isFromRemote)).thenAnswer((_) async => response);
  }

  ProfileCubit buildCubit() {
    return ProfileCubit(getProfileData, logoutUseCase);
  }

  group('ProfileCubit - LoadProfileEvent', () {
    group('Local Load (isFromRemote: false)', () {
      blocTest<ProfileCubit, ProfileState>(
        'emits [loading, success] when local fetch succeeds',
        build: () {
          stubFetch(
            isFromRemote: false,
            response: const SuccessBaseResponse(user),
          );
          return buildCubit();
        },
        act: (cubit) =>
            cubit.doIntent(const LoadProfileEvent(isFromRemote: false)),
        expect: () => const [
          ProfileState(profileState: BaseState(isLoading: true)),
          ProfileState(profileState: BaseState(data: user)),
        ],
        verify: (_) => verify(getProfileData(false)).called(1),
      );

      blocTest<ProfileCubit, ProfileState>(
        'emits [loading, error] when local fetch fails',
        build: () {
          stubFetch(
            isFromRemote: false,
            response: const ErrorBaseResponse('local error'),
          );
          return buildCubit();
        },
        act: (cubit) =>
            cubit.doIntent(const LoadProfileEvent(isFromRemote: false)),
        expect: () => const [
          ProfileState(profileState: BaseState(isLoading: true)),
          ProfileState(profileState: BaseState(errorMessage: 'local error')),
        ],
        verify: (cubit) {
          verify(getProfileData(false)).called(1);
        },
      );

      test('emits DisplayErrorEvent on failure', () async {
        stubFetch(
          isFromRemote: false,
          response: const ErrorBaseResponse('local error'),
        );
        final cubit = buildCubit();

        final expectation = expectLater(
          cubit.eventStream,
          emits(
            isA<DisplayErrorEvent>().having(
              (e) => e.errorMessage,
              'msg',
              'local error',
            ),
          ),
        );

        cubit.doIntent(const LoadProfileEvent(isFromRemote: false));
        await expectation;
      });
    });

    group('Remote Load (isFromRemote: true)', () {
      blocTest<ProfileCubit, ProfileState>(
        'emits success state and triggers global loader via UI events',
        build: () {
          stubFetch(
            isFromRemote: true,
            response: const SuccessBaseResponse(updatedUser),
          );
          return buildCubit();
        },
        seed: () => const ProfileState(profileState: BaseState(data: user)),
        act: (cubit) =>
            cubit.doIntent(const LoadProfileEvent(isFromRemote: true)),
        expect: () => const [
          ProfileState(profileState: BaseState(data: updatedUser)),
        ],
        verify: (cubit) {
          verify(getProfileData(true)).called(1);
        },
      );

      test('emits ShowLoadingEvent and HideLoadingEvent UI events', () async {
        stubFetch(
          isFromRemote: true,
          response: const SuccessBaseResponse(updatedUser),
        );
        final cubit = buildCubit();

        final expectation = expectLater(
          cubit.eventStream,
          emitsInOrder([isA<ShowLoadingEvent>(), isA<HideLoadingEvent>()]),
        );

        cubit.doIntent(const LoadProfileEvent(isFromRemote: true));
        await expectation;
      });

      blocTest<ProfileCubit, ProfileState>(
        'keeps existing data and shows error toast when remote refresh fails',
        build: () {
          stubFetch(
            isFromRemote: true,
            response: const ErrorBaseResponse('network error'),
          );
          return buildCubit();
        },
        seed: () => const ProfileState(profileState: BaseState(data: user)),
        act: (cubit) =>
            cubit.doIntent(const LoadProfileEvent(isFromRemote: true)),
        expect: () => const [
          ProfileState(
            profileState: BaseState(data: user, errorMessage: 'network error'),
          ),
        ],
      );
    });

    blocTest<ProfileCubit, ProfileState>(
      'does not emit new state if data is identical (Equatable test)',
      build: () {
        stubFetch(
          isFromRemote: true,
          response: const SuccessBaseResponse(user),
        );
        return buildCubit();
      },
      seed: () => const ProfileState(profileState: BaseState(data: user)),
      act: (cubit) =>
          cubit.doIntent(const LoadProfileEvent(isFromRemote: true)),
      expect: () => <ProfileState>[],
    );
  });

  group('ProfileCubit - LogoutEvent', () {
    blocTest<ProfileCubit, ProfileState>(
      'calls LogoutUseCase and navigates to login',
      build: () {
        when(
          logoutUseCase(),
        ).thenAnswer((_) async => const SuccessBaseResponse(null));
        return buildCubit();
      },
      act: (cubit) => cubit.doIntent(const LogoutEvent()),
      expect: () => <ProfileState>[],
      verify: (cubit) {
        verify(logoutUseCase()).called(1);
      },
    );

    test('emits loading events and navigation event', () async {
      when(
        logoutUseCase(),
      ).thenAnswer((_) async => const SuccessBaseResponse(null));
      final cubit = buildCubit();

      final expectation = expectLater(
        cubit.eventStream,
        emitsInOrder([
          isA<ShowLoadingEvent>(),
          isA<HideLoadingEvent>(),
          isA<NavigateEvent>().having(
            (e) => e.routeName,
            'route',
            AppRoutes.login,
          ),
        ]),
      );

      cubit.doIntent(const LogoutEvent());
      await expectation;
    });
  });

  group('ProfileState Logic', () {
    test('fullName joins first and last name correctly', () {
      const state = ProfileState(profileState: BaseState(data: user));
      expect(state.fullName, 'Ahmed Emam');
    });

    test('fullName handles missing last name (trims)', () {
      const state = ProfileState(
        profileState: BaseState(data: UserEntity(firstName: 'Ahmed')),
      );
      expect(state.fullName, 'Ahmed');
    });

    test('fullName handles missing first name (trims)', () {
      const state = ProfileState(
        profileState: BaseState(data: UserEntity(lastName: 'Emam')),
      );
      expect(state.fullName, 'Emam');
    });

    test('fullName is empty string when user is null', () {
      const state = ProfileState(profileState: BaseState(data: null));
      expect(state.fullName, '');
    });

    test('photo returns user photo or empty string', () {
      const stateWithPhoto = ProfileState(profileState: BaseState(data: user));
      expect(stateWithPhoto.photo, 'https://example.com/ahmed.png');

      const stateWithoutPhoto = ProfileState(
        profileState: BaseState(data: UserEntity(firstName: 'Ahmed')),
      );
      expect(stateWithoutPhoto.photo, '');
    });

    test('initial state is correct', () {
      const state = ProfileState();
      expect(state.profileState.isLoading, false);
      expect(state.profileState.data, isNull);
      expect(state.profileState.errorMessage, isNull);
    });
  });
}
