import 'package:injectable/injectable.dart';
import 'package:super_fitness/features/auth/domain/entities/user_entity.dart';
import 'package:super_fitness/features/profile/data/data_sources/profile_local_data_source_contract.dart';
import 'package:super_fitness/features/profile/data/data_sources/profile_remote_data_source_contract.dart';
import 'package:super_fitness/features/profile/domain/repo/profile_repo_contract.dart';

@Injectable(as: ProfileRepoContract)
class ProfileRepoImpl implements ProfileRepoContract {
  /// Injected and ready for whoever wires the profile endpoint; the ignore
  /// below goes away with the first method that uses it.
  // ignore: unused_field
  final ProfileRemoteDataSourceContract _remoteDataSource;

  final ProfileLocalDataSourceContract _localDataSource;

  const ProfileRepoImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<UserEntity?> getCachedUser() => _localDataSource.getCachedUser();
}
