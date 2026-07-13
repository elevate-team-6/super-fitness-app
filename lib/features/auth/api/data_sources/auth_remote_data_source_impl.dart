import 'package:injectable/injectable.dart';

import '../../data/data_sources/auth_remote_data_source_contract.dart';
import '../api_client/auth_api_client.dart';

@Injectable(as: AuthRemoteDataSourceContract)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSourceContract {
  // ignore: unused_field
  final AuthApiClient _apiClient;
  const AuthRemoteDataSourceImpl(this._apiClient);
}
