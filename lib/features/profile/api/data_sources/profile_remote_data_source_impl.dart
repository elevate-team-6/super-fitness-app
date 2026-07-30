import 'package:injectable/injectable.dart';
import 'package:super_fitness/features/profile/api/api_client/profile_api_client.dart';
import 'package:super_fitness/features/profile/data/data_sources/profile_remote_data_source_contract.dart';

@Injectable(as: ProfileRemoteDataSourceContract)
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSourceContract {
  /// Injected and ready — the first call added to this class uses it, and the
  /// ignore below can go away with it.
  // ignore: unused_field
  final ProfileApiClient _apiClient;

  const ProfileRemoteDataSourceImpl(this._apiClient);
}
