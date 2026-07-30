import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/config/base_state/base_state.dart';
import 'package:super_fitness/features/auth/domain/entities/user_entity.dart';
import 'package:super_fitness/features/auth/domain/use_cases/logout_use_case.dart';
import 'package:super_fitness/features/profile/domain/use_cases/get_cached_user_use_case.dart';
import 'package:super_fitness/features/profile/presentation/view_model/profile_view_model/profile_cubit.dart';
import 'package:super_fitness/features/profile/presentation/view_model/profile_view_model/profile_event.dart';
import 'package:super_fitness/features/profile/presentation/view_model/profile_view_model/profile_state.dart';

import 'profile_cubit_test.mocks.dart';

@GenerateMocks([GetCachedUserUseCase, LogoutUseCase])
void main() {
  provideDummy<BaseResponse<void>>(const SuccessBaseResponse(null));
  late MockGetCachedUserUseCase useCase;
  late MockLogoutUseCase logoutUseCase;

  const user = UserEntity(
    id: 'user_123',
    firstName: 'Ahmed',
    lastName: 'Emam',
    email: 'ahmed@example.com',
    photo: 'https://example.com/ahmed.png',
  );

  setUp(() {
    useCase = MockGetCachedUserUseCase();
    logoutUseCase = MockLogoutUseCase();
  });

  group('ProfileCubit', () {
    blocTest<ProfileCubit, ProfileState>(
      'emits loading then the cached user on LoadProfileEvent',
      build: () {
        when(useCase()).thenAnswer((_) async => user);
        return ProfileCubit(useCase, logoutUseCase);
      },
      act: (cubit) => cubit.doIntent(const LoadProfileEvent()),
      expect: () => const [
        ProfileState(profileState: BaseState(isLoading: true)),
        ProfileState(profileState: BaseState(data: user)),
      ],
    );

    blocTest<ProfileCubit, ProfileState>(
      'settles on an empty state when nothing is cached',
      build: () {
        when(useCase()).thenAnswer((_) async => null);
        return ProfileCubit(useCase, logoutUseCase);
      },
      act: (cubit) => cubit.doIntent(const LoadProfileEvent()),
      expect: () => const [
        ProfileState(profileState: BaseState(isLoading: true)),
        ProfileState(profileState: BaseState()),
      ],
    );

    blocTest<ProfileCubit, ProfileState>(
      'refresh emits the new user without a loading state',
      build: () {
        when(useCase()).thenAnswer((_) async => user);
        return ProfileCubit(useCase, logoutUseCase);
      },
      act: (cubit) => cubit.doIntent(const RefreshProfileEvent()),
      expect: () => const [ProfileState(profileState: BaseState(data: user))],
    );

    blocTest<ProfileCubit, ProfileState>(
      'LogoutEvent calls LogoutUseCase',
      build: () {
        when(
          logoutUseCase(),
        ).thenAnswer((_) async => const SuccessBaseResponse(null));
        return ProfileCubit(useCase, logoutUseCase);
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
