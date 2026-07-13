import 'package:easy_localization/easy_localization.dart';
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
      case SuccessBaseResponse<SignupResponse>():
        if (response.data?.user == null) {
          return ErrorBaseResponse(AppStrings.signupFailed.tr());
        }
        await _secureCacheHelper.writeData(
          key: AppKeys.tokenKey,
          value: response.data?.token,
        );
        return SuccessBaseResponse(response.data?.user!.toEntity());
      case ErrorBaseResponse<SignupResponse>():
        return ErrorBaseResponse(response.errorMessage);
    }
  }
}
