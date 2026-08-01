import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/features/auth/data/models/response/user_model.dart';
import 'package:super_fitness/features/auth/domain/entities/user_entity.dart';
import 'package:super_fitness/features/profile/data/data_sources/profile_local_data_source_contract.dart';
import 'package:super_fitness/features/profile/data/data_sources/profile_remote_data_source_contract.dart';
import 'package:super_fitness/features/profile/data/models/response/profile_data_response.dart';
import 'package:super_fitness/features/profile/data/repo/profile_repo_impl.dart';

import 'profile_repo_impl_test.mocks.dart';

@GenerateMocks([
  ProfileLocalDataSourceContract,
  ProfileRemoteDataSourceContract,
])
void main() {
  late MockProfileLocalDataSourceContract local;
  late MockProfileRemoteDataSourceContract remote;
  late ProfileRepoImpl repo;

  const userModel = UserModel(
    id: 'user_123',
    firstName: 'Ahmed',
    lastName: 'Emam',
  );
  const cachedUser = UserEntity(id: 'user_123', firstName: 'Cached');

  setUpAll(() {
    provideDummy<BaseResponse<ProfileDataResponse>>(
      const ErrorBaseResponse('dummy'),
    );
  });

  setUp(() {
    local = MockProfileLocalDataSourceContract();
    remote = MockProfileRemoteDataSourceContract();
    repo = ProfileRepoImpl(remote, local);

    when(local.cacheUser(any)).thenAnswer((_) async {});
  });

  void stubRemote(BaseResponse<ProfileDataResponse> response) {
    when(remote.getProfileData()).thenAnswer((_) async => response);
  }

  group('getCachedUser', () {
    test('serves the cached user from the local source', () async {
      when(local.getCachedUser()).thenAnswer((_) async => cachedUser);

      expect(await repo.getCachedUser(), cachedUser);
      verify(local.getCachedUser()).called(1);
    });

    test('passes an empty cache straight through', () async {
      when(local.getCachedUser()).thenAnswer((_) async => null);

      expect(await repo.getCachedUser(), isNull);
    });

    // Reading the cache is what every visit after the first one does; a stray
    // call here would put a request behind each of them.
    test('does not touch the remote source', () async {
      when(local.getCachedUser()).thenAnswer((_) async => cachedUser);

      await repo.getCachedUser();

      verifyZeroInteractions(remote);
    });
  });

  group('getProfileData', () {
    test('maps the fetched user to an entity', () async {
      stubRemote(
        const SuccessBaseResponse(ProfileDataResponse(user: userModel)),
      );

      final result = await repo.getProfileData();

      expect(result, isA<SuccessBaseResponse<UserEntity>>());
      expect(
        (result as SuccessBaseResponse<UserEntity>).data?.firstName,
        'Ahmed',
      );
      verify(remote.getProfileData()).called(1);
    });

    // The write is what keeps the next visit off the network.
    test('writes the fetched user to the cache', () async {
      stubRemote(
        const SuccessBaseResponse(ProfileDataResponse(user: userModel)),
      );

      await repo.getProfileData();

      verify(local.cacheUser(userModel)).called(1);
    });

    test('fails when the response carries no user', () async {
      stubRemote(const SuccessBaseResponse(ProfileDataResponse(message: 'ok')));

      expect(await repo.getProfileData(), isA<ErrorBaseResponse<UserEntity>>());
      verifyNever(local.cacheUser(any));
    });

    // A failed fetch must not overwrite the cache with nothing.
    test('surfaces the error and leaves the cache alone', () async {
      stubRemote(const ErrorBaseResponse('no internet'));

      final result = await repo.getProfileData();

      expect(
        (result as ErrorBaseResponse<UserEntity>).errorMessage,
        'no internet',
      );
      verifyNever(local.cacheUser(any));
    });
  });
}
