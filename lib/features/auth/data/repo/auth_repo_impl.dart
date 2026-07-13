import 'package:injectable/injectable.dart';

import '../../domain/repo/auth_repo_contract.dart';
import '../data_sources/auth_remote_data_source_contract.dart';

@Injectable(as: AuthRepoContract)
class AuthRepoImpl implements AuthRepoContract {
  // ignore: unused_field
  final AuthRemoteDataSourceContract _remoteDataSource;

  const AuthRepoImpl(this._remoteDataSource);
}
