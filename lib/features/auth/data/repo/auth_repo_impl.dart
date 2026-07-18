import 'package:injectable/injectable.dart';
import 'package:super_fitness/config/cache/secure_cache_helper.dart';

import '../../../../config/base_response/base_response.dart';
import '../../../../core/utils/app_keys.dart';
import '../../../../core/utils/app_strings.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repo/auth_repo_contract.dart';
import '../data_sources/auth_remote_data_source_contract.dart';
import '../models/request/signup_request.dart';
import '../models/response/signup_response.dart';

@Injectable(as: AuthRepoContract)
class AuthRepoImpl implements AuthRepoContract {
  final AuthRemoteDataSourceContract _remoteDataSource;
  final SecureCacheHelper _secureCacheHelper;

  const AuthRepoImpl(
    this._remoteDataSource,
    SecureCacheHelper secureCacheHelper,
  ) : _secureCacheHelper = secureCacheHelper;

  @override
  Future<BaseResponse<UserEntity>> signup(SignupRequest request) async {
    final BaseResponse<SignupResponse> response = await _remoteDataSource
        .signup(request);
    switch (response) {
      case SuccessBaseResponse<SignupResponse>(data: var signupData):
        final user = signupData?.user;
        if (user == null) {
          return const ErrorBaseResponse(AppStrings.registerFailed);
        }
        await _secureCacheHelper.writeData(
          key: AppKeys.tokenKey,
          value: signupData?.token,
        );
        return SuccessBaseResponse(user.toEntity());
      case ErrorBaseResponse<SignupResponse>():
        return ErrorBaseResponse(response.errorMessage);
    }
  }
}
