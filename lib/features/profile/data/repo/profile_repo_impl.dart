import 'package:injectable/injectable.dart';
import 'package:super_fitness/features/profile/data/data_sources/profile_remote_data_source_contract.dart';
import 'package:super_fitness/features/profile/domain/repo/profile_repo_contract.dart';

@Injectable(as: ProfileRepoContract)
class ProfileRepoImpl implements ProfileRepoContract {
  /// Injected and ready — the first method added to this class uses it, and
  /// the ignore below can go away with it.
  // ignore: unused_field
  final ProfileRemoteDataSourceContract _remoteDataSource;

  const ProfileRepoImpl(this._remoteDataSource);
}
