import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/config/base_state/base_state.dart';
import 'package:super_fitness/config/base_ui_event/base_ui_event.dart';
import 'package:super_fitness/features/auth/domain/entities/user_entity.dart';
import 'package:super_fitness/features/auth/domain/use_cases/logout_use_case.dart';
import 'package:super_fitness/features/profile/domain/use_cases/get_cached_user_use_case.dart';
import 'package:super_fitness/features/profile/domain/use_cases/get_profile_data_use_case.dart';
import 'package:super_fitness/features/profile/presentation/view_model/profile_view_model/profile_cubit.dart';
import 'package:super_fitness/features/profile/presentation/view_model/profile_view_model/profile_event.dart';
import 'package:super_fitness/features/profile/presentation/view_model/profile_view_model/profile_state.dart';

import 'profile_cubit_test.mocks.dart';

@GenerateMocks([
  GetCachedUserUseCase,
  GetProfileDataUseCase,
  LogoutUseCase,
])
void main() {
  late MockGetCachedUserUseCase getCachedUser;
  late MockGetProfileDataUseCase getProfileData;
  late MockLogoutUseCase logoutUseCase;

  const user = UserEntity(
    id: 'user_123',
    firstName: 'Ahmed',
    lastName: 'Emam',
    email: 'ahmed@example.com',
    photo: 'https://example.com/ahmed.png',
  );
  const cachedUser = UserEntity(id: 'user_123', firstName: 'Cached');

  setUpAll(() {
    provideDummy<BaseResponse<UserEntity>>(const ErrorBaseResponse('dummy'));
    provideDummy<BaseResponse<void>>(const SuccessBaseResponse(null));
  });

  setUp(() {
    getCachedUser = MockGetCachedUserUseCase();
    getProfileData = MockGetProfileDataUseCase();
    logoutUseCase = MockLogoutUseCase();
  });

  void stubCache(UserEntity? cached) {
    when(getCachedUser()).thenAnswer((_) async => cached);
  }

  void stubFetch(BaseResponse<UserEntity> response) {
    when(getProfileData()).thenAnswer((_) async => response);
  }

  ProfileCubit buildCubit() =>
      ProfileCubit(getCachedUser, getProfileData, logoutUseCase);

  group('ProfileCubit', () {
    // First visit: nothing cached yet, so the fetch is worth a shimmer.
    blocTest<ProfileCubit, ProfileState>(
      'emits loading then the fetched user when nothing is cached',
      build: () {
        stubCache(null);
        stubFetch(const SuccessBaseResponse(user));
        return buildCubit();
      },
      act: (cubit) => cubit.doIntent(const LoadProfileEvent()),
      expect: () => const [
        ProfileState(profileState: BaseState(isLoading: true)),
        ProfileState(profileState: BaseState(data: user)),
      ],
    );

    // Every later visit: the cached user goes straight on screen, with no
    // request and no shimmer in between.
    blocTest<ProfileCubit, ProfileState>(
      'serves the cached user without loading or a fetch',
      build: () {
        stubCache(cachedUser);
        return buildCubit();
      },
      act: (cubit) => cubit.doIntent(const LoadProfileEvent()),
      expect: () => const [
        ProfileState(profileState: BaseState(data: cachedUser)),
      ],
      verify: (_) => verifyNever(getProfileData()),
    );

    // An empty response has to settle as "loaded, nothing there" rather than
    // an error, or the header would show a retry view it can do nothing about.
    blocTest<ProfileCubit, ProfileState>(
      'settles on an empty state when the fetch carries no user',
      build: () {
        stubCache(null);
        stubFetch(const SuccessBaseResponse(null));
        return buildCubit();
      },
      act: (cubit) => cubit.doIntent(const LoadProfileEvent()),
      expect: () => const [
        ProfileState(profileState: BaseState(isLoading: true)),
        ProfileState(profileState: BaseState()),
      ],
      verify: (cubit) {
        expect(cubit.state.profileState.errorMessage, isNull);
        expect(cubit.state.profileState.isLoading, isFalse);
      },
    );

    blocTest<ProfileCubit, ProfileState>(
      'reports a failed first fetch through the state',
      build: () {
        stubCache(null);
        stubFetch(const ErrorBaseResponse('no internet'));
        return buildCubit();
      },
      act: (cubit) => cubit.doIntent(const LoadProfileEvent()),
      expect: () => const [
        ProfileState(profileState: BaseState(isLoading: true)),
        ProfileState(profileState: BaseState(errorMessage: 'no internet')),
      ],
    );

    test('emits a DisplayErrorEvent when the fetch fails', () async {
      stubCache(null);
      stubFetch(const ErrorBaseResponse('no internet'));
      final cubit = buildCubit();

      final displayed = expectLater(
        cubit.eventStream,
        emits(
          isA<DisplayErrorEvent>().having(
                (event) => event.errorMessage,
            'errorMessage',
            'no internet',
          ),
        ),
      );

      cubit.doIntent(const LoadProfileEvent());

      await displayed;
    });

    // Refresh is the one path that goes past the cache — it's how the tab
    // picks up an edit — and it skips the loading emit so the header doesn't
    // flash back to a shimmer.
    blocTest<ProfileCubit, ProfileState>(
      'refresh fetches past the cache without a loading state',
      build: () {
        stubFetch(const SuccessBaseResponse(user));
        return buildCubit();
      },
      act: (cubit) => cubit.doIntent(const RefreshProfileEvent()),
      expect: () => const [ProfileState(profileState: BaseState(data: user))],
      verify: (_) => verifyNever(getCachedUser()),
    );

    // Losing the connection on a refresh shouldn't wipe the user already on
    // screen — only the message is new.
    blocTest<ProfileCubit, ProfileState>(
      'keeps the user already shown when a refresh fails',
      build: () {
        stubFetch(const ErrorBaseResponse('no internet'));
        return buildCubit();
      },
      seed: () => const ProfileState(profileState: BaseState(data: user)),
      act: (cubit) => cubit.doIntent(const RefreshProfileEvent()),
      expect: () => const [
        ProfileState(
          profileState: BaseState(data: user, errorMessage: 'no internet'),
        ),
      ],
    );

    // The refresh fires on every return from the edit screen, so an unchanged
    // user has to cost nothing — Equatable makes the re-emit a no-op.
    blocTest<ProfileCubit, ProfileState>(
      'refresh emits nothing when the fetched user is unchanged',
      build: () {
        stubFetch(const SuccessBaseResponse(user));
        return buildCubit();
      },
      seed: () => const ProfileState(profileState: BaseState(data: user)),
      act: (cubit) => cubit.doIntent(const RefreshProfileEvent()),
      expect: () => const <ProfileState>[],
    );

    blocTest<ProfileCubit, ProfileState>(
      'hits the network once per event at most',
      build: () {
        stubCache(null);
        stubFetch(const SuccessBaseResponse(user));
        return buildCubit();
      },
      act: (cubit) async {
        cubit.doIntent(const LoadProfileEvent());
        await Future.delayed(Duration.zero);
        cubit.doIntent(const RefreshProfileEvent());
        await Future.delayed(Duration.zero);
      },
      verify: (_) {
        verify(getCachedUser()).called(1);
        verify(getProfileData()).called(2);
      },
    );

    blocTest<ProfileCubit, ProfileState>(
      'LogoutEvent calls LogoutUseCase',
      build: () {
        when(
          logoutUseCase(),
        ).thenAnswer((_) async => const SuccessBaseResponse(null));
        return buildCubit();
      },
      act: (cubit) => cubit.doIntent(const LogoutEvent()),
      verify: (_) => verify(logoutUseCase()).called(1),
    );
  });

  group('ProfileState', () {
    test('fullName joins the first and last name', () {
      const state = ProfileState(profileState: BaseState(data: user));

      expect(state.fullName, 'Ahmed Emam');
    });

    test('fullName is empty when there is no user', () {
      const state = ProfileState();

      expect(state.fullName, isEmpty);
    });

    // The header drops the name line on an empty string, so a half-filled
    // record must not leave a stray space behind.
    test('fullName trims when one half of the name is missing', () {
      const state = ProfileState(
        profileState: BaseState(data: UserEntity(firstName: 'Ahmed')),
      );

      expect(state.fullName, 'Ahmed');
    });

    test('photo falls back to an empty string', () {
      const withoutPhoto = ProfileState(
        profileState: BaseState(data: UserEntity(firstName: 'Ahmed')),
      );

      expect(withoutPhoto.photo, isEmpty);
      expect(
        const ProfileState(profileState: BaseState(data: user)).photo,
        'https://example.com/ahmed.png',
      );
    });
  });
}