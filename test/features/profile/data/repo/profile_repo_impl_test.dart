import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_fitness/features/auth/domain/entities/user_entity.dart';
import 'package:super_fitness/features/profile/data/data_sources/profile_local_data_source_contract.dart';
import 'package:super_fitness/features/profile/data/data_sources/profile_remote_data_source_contract.dart';
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

  const user = UserEntity(id: 'user_123', firstName: 'Ahmed', lastName: 'Emam');

  setUp(() {
    local = MockProfileLocalDataSourceContract();
    remote = MockProfileRemoteDataSourceContract();
    repo = ProfileRepoImpl(remote, local);
  });

  test('serves the cached user from the local source', () async {
    when(local.getCachedUser()).thenAnswer((_) async => user);

    expect(await repo.getCachedUser(), user);
    verify(local.getCachedUser()).called(1);
  });

  test('passes an empty cache straight through', () async {
    when(local.getCachedUser()).thenAnswer((_) async => null);

    expect(await repo.getCachedUser(), isNull);
  });

  // The header is meant to render without the network; a stray call here would
  // put a request behind every visit to the tab.
  test('does not touch the remote source', () async {
    when(local.getCachedUser()).thenAnswer((_) async => user);

    await repo.getCachedUser();

    verifyZeroInteractions(remote);
  });
}
