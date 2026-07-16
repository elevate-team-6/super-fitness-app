import 'package:easy_localization/easy_localization.dart';
import 'package:injectable/injectable.dart';
import 'dart:convert';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/config/cache/secure_cache_helper.dart';
import 'package:super_fitness/core/utils/app_keys.dart';
import 'package:super_fitness/features/auth/data/models/request/sign_in_request_model.dart';
import 'package:super_fitness/features/auth/data/models/response/sign_in_response_model.dart';
import 'package:super_fitness/features/auth/domain/entities/sign_in_entity.dart';
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

  const AuthRepoImpl(this._remoteDataSource, this._secureCacheHelper);

  @override
  Future<BaseResponse<SignInEntity>> signIn(SignInRequestModel request) async {
    final result = await _remoteDataSource.signIn(request);

    switch (result) {
      case SuccessBaseResponse<SignInResponseModel>():
        final model = result.data;
        if (model != null) await _cacheUserSession(model);
        return SuccessBaseResponse(model?.toEntity());
      case ErrorBaseResponse<SignInResponseModel>():
        return ErrorBaseResponse(result.errorMessage);
    }
  }

  /// Persists the session after a successful login: the auth token and the full
  /// user data, so the app keeps the user signed in on the next launch
  /// (per the acceptance criteria).
  Future<void> _cacheUserSession(SignInResponseModel model) async {
    final token = model.token;
    if (token != null && token.isNotEmpty) {
      await _secureCacheHelper.writeData(key: AppKeys.tokenKey, value: token);
    }

    // Save the full user data locally so the app can use it offline / on resume.
    final user = model.user;
    if (user == null) return;

    await _secureCacheHelper.writeData(
      key: AppKeys.userDataKey,
      value: jsonEncode(user.toJson()),
    );

    final userId = user.id;
    if (userId != null) {
      await _secureCacheHelper.writeData(key: AppKeys.userIdKey, value: userId);
    }
  }

  @override
  Future<BaseResponse<UserEntity>> signup(SignupRequest request) async {
    final BaseResponse<SignupResponse> response = await _remoteDataSource
        .signup(request);

    switch (response) {
      case SuccessBaseResponse<SignupResponse>():
        if (response.data?.user == null) {
          return ErrorBaseResponse(AppStrings.registerFailed.tr());
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
