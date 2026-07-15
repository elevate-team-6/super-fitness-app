import 'package:injectable/injectable.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/features/auth/data/models/request/sign_in_request_model.dart';
import 'package:super_fitness/features/auth/data/models/response/sign_in_response_model.dart';
import 'package:super_fitness/features/auth/domain/entities/sign_in_entity.dart';

import '../../domain/repo/auth_repo_contract.dart';
import '../data_sources/auth_remote_data_source_contract.dart';

@Injectable(as: AuthRepoContract)
class AuthRepoImpl implements AuthRepoContract {
  final AuthRemoteDataSourceContract _remoteDataSource;

  const AuthRepoImpl(this._remoteDataSource);

  @override
  Future<BaseResponse<SignInEntity>> signIn(SignInRequestModel request) async {
    final result = await _remoteDataSource.signIn(request);

    return switch (result) {
      SuccessBaseResponse<SignInResponseModel>() => SuccessBaseResponse(
        result.data?.toEntity(),
      ),
      ErrorBaseResponse<SignInResponseModel>() => ErrorBaseResponse(
        result.errorMessage,
      ),
    };
  }
}
