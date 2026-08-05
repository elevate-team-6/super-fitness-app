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
    when(
      remote.getProfileData(),
    ).thenAnswer((_) async => const ErrorBaseResponse('dummy'));
  });

  void stubRemote(BaseResponse<ProfileDataResponse> response) {
    when(remote.getProfileData()).thenAnswer((_) async => response);
  }

  group('getLocalProfileData', () {
    test('serves the cached user from the local source', () async {
      when(local.getCachedUser()).thenAnswer((_) async => cachedUser);

      final result = await repo.getLocalProfileData();
      expect((result as SuccessBaseResponse<UserEntity>).data, cachedUser);
      verify(local.getCachedUser()).called(1);
    });

    test('falls back to remote when cache is empty', () async {
      when(local.getCachedUser()).thenAnswer((_) async => null);
      stubRemote(
        const SuccessBaseResponse(ProfileDataResponse(user: userModel)),
      );

      final result = await repo.getLocalProfileData();

      expect(result, isA<SuccessBaseResponse<UserEntity>>());
      expect(
        (result as SuccessBaseResponse<UserEntity>).data?.id,
        userModel.id,
      );
      verify(local.getCachedUser()).called(1);
      verify(remote.getProfileData()).called(1);
      verify(local.cacheUser(userModel)).called(1);
    });
  });

  group('getRemoteProfileData', () {
    test('maps the fetched user to an entity', () async {
      stubRemote(
        const SuccessBaseResponse(ProfileDataResponse(user: userModel)),
      );

      final result = await repo.getRemoteProfileData();

      expect(result, isA<SuccessBaseResponse<UserEntity>>());
      expect(
        (result as SuccessBaseResponse<UserEntity>).data?.firstName,
        'Ahmed',
      );
      verify(remote.getProfileData()).called(1);
    });

    test('writes the fetched user to the cache', () async {
      stubRemote(
        const SuccessBaseResponse(ProfileDataResponse(user: userModel)),
      );

      await repo.getRemoteProfileData();

      verify(local.cacheUser(userModel)).called(1);
    });

    test('fails when the response carries no user', () async {
      stubRemote(const SuccessBaseResponse(ProfileDataResponse(message: 'ok')));

      expect(
        await repo.getRemoteProfileData(),
        isA<ErrorBaseResponse<UserEntity>>(),
      );
      verifyNever(local.cacheUser(any));
    });

    test('surfaces the error and leaves the cache alone', () async {
      stubRemote(const ErrorBaseResponse('no internet'));

      final result = await repo.getRemoteProfileData();

      expect(
        (result as ErrorBaseResponse<UserEntity>).errorMessage,
        'no internet',
      );
      verifyNever(local.cacheUser(any));
    });
  });

  group('userStream', () {
    test('emits user when remote data is fetched successfully', () async {
      stubRemote(
        const SuccessBaseResponse(ProfileDataResponse(user: userModel)),
      );

      final expectation = expectLater(
        repo.userStream,
        emits(userModel.toEntity()),
      );

      await repo.getRemoteProfileData();
      await expectation;
    });

    test('emits user when local data is found', () async {
      when(local.getCachedUser()).thenAnswer((_) async => cachedUser);

      final expectation = expectLater(repo.userStream, emits(cachedUser));

      await repo.getLocalProfileData();
      await expectation;
    });
  });
}
