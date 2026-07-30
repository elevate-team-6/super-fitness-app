import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_fitness/config/base_state/base_state.dart';
import 'package:super_fitness/features/auth/domain/entities/user_entity.dart';
import 'package:super_fitness/features/profile/domain/use_cases/get_cached_user_use_case.dart';
import 'package:super_fitness/features/profile/presentation/view_model/profile_view_model/profile_cubit.dart';
import 'package:super_fitness/features/profile/presentation/view_model/profile_view_model/profile_event.dart';
import 'package:super_fitness/features/profile/presentation/view_model/profile_view_model/profile_state.dart';

import 'profile_cubit_test.mocks.dart';

@GenerateMocks([GetCachedUserUseCase])
void main() {
  late MockGetCachedUserUseCase useCase;

  const user = UserEntity(
    id: 'user_123',
    firstName: 'Ahmed',
    lastName: 'Emam',
    email: 'ahmed@example.com',
    photo: 'https://example.com/ahmed.png',
  );

  setUp(() {
    useCase = MockGetCachedUserUseCase();
  });

  group('ProfileCubit', () {
    blocTest<ProfileCubit, ProfileState>(
      'emits loading then the cached user on LoadProfileEvent',
      build: () {
        when(useCase()).thenAnswer((_) async => user);
        return ProfileCubit(useCase);
      },
      act: (cubit) => cubit.doIntent(const LoadProfileEvent()),
      expect: () => const [
        ProfileState(profileState: BaseState(isLoading: true)),
        ProfileState(profileState: BaseState(data: user)),
      ],
    );

    // A session that started before the user was cached reads back null. That
    // has to settle as "loaded, nothing there" rather than an error, or the
    // header would show a retry view it can do nothing about.
    blocTest<ProfileCubit, ProfileState>(
      'settles on an empty state when nothing is cached',
      build: () {
        when(useCase()).thenAnswer((_) async => null);
        return ProfileCubit(useCase);
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

    // Returning from the edit screen shouldn't flash the header back to a
    // shimmer, so the refresh path skips the loading emit entirely.
    blocTest<ProfileCubit, ProfileState>(
      'refresh emits the new user without a loading state',
      build: () {
        when(useCase()).thenAnswer((_) async => user);
        return ProfileCubit(useCase);
      },
      act: (cubit) => cubit.doIntent(const RefreshProfileEvent()),
      expect: () => const [ProfileState(profileState: BaseState(data: user))],
    );

    // The refresh fires on every return from the edit screen, so an unchanged
    // user has to cost nothing — Equatable makes the re-emit a no-op.
    blocTest<ProfileCubit, ProfileState>(
      'refresh emits nothing when the cached user is unchanged',
      build: () {
        when(useCase()).thenAnswer((_) async => user);
        return ProfileCubit(useCase);
      },
      seed: () => const ProfileState(profileState: BaseState(data: user)),
      act: (cubit) => cubit.doIntent(const RefreshProfileEvent()),
      expect: () => const <ProfileState>[],
    );

    blocTest<ProfileCubit, ProfileState>(
      'reads the cache once per event',
      build: () {
        when(useCase()).thenAnswer((_) async => user);
        return ProfileCubit(useCase);
      },
      act: (cubit) async {
        cubit.doIntent(const LoadProfileEvent());
        await Future.delayed(Duration.zero);
        cubit.doIntent(const RefreshProfileEvent());
        await Future.delayed(Duration.zero);
      },
      verify: (_) => verify(useCase()).called(2),
    );
  });

  group('ProfileState', () {
    test('fullName joins the first and last name', () {
      const state = ProfileState(profileState: BaseState(data: user));

      expect(state.fullName, 'Ahmed Emam');
    });

    test('fullName is empty when nothing is cached', () {
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
