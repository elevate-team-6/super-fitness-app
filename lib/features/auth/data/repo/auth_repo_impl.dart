import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/config/cache/secure_cache_helper.dart';
import 'package:super_fitness/core/utils/app_keys.dart';
import 'package:super_fitness/features/auth/data/data_sources/auth_remote_data_source_contract.dart';
import 'package:super_fitness/features/auth/data/data_sources/forget_password_remote_data_source_contract.dart';
import 'package:super_fitness/features/auth/data/models/request/forgot_password_request.dart';
import 'package:super_fitness/features/auth/data/models/request/reset_password_request.dart';
import 'package:super_fitness/features/auth/data/models/request/sign_in_request_model.dart';
import 'package:super_fitness/features/auth/data/models/request/verify_reset_code_request.dart';
import 'package:super_fitness/features/auth/data/models/response/forgot_password_response.dart';
import 'package:super_fitness/features/auth/data/models/response/reset_password_response.dart';
import 'package:super_fitness/features/auth/data/models/response/sign_in_response_model.dart';
import 'package:super_fitness/features/auth/data/models/response/verify_reset_code_response.dart';
import 'package:super_fitness/features/auth/domain/entities/forget_password_entity.dart';
import 'package:super_fitness/features/auth/domain/entities/sign_in_entity.dart';
import 'package:super_fitness/features/auth/domain/repo/auth_repo_contract.dart';

@Injectable(as: AuthRepoContract)
class AuthRepoImpl implements AuthRepoContract {
  final AuthRemoteDataSourceContract _authRemoteDataSource;

  final ForgotPasswordRemoteDataSourceContract
  _forgotPasswordRemoteDataSource;

  final ForgotPasswordRemoteDataSourceContract?
  _forgotPasswordMockDataSource;

  final SecureCacheHelper _secureCacheHelper;

  AuthRepoImpl(
      this._authRemoteDataSource,
      this._forgotPasswordRemoteDataSource,
      this._secureCacheHelper, [
        @Named('mock')
        this._forgotPasswordMockDataSource,
      ]);

  @override
  Future<BaseResponse<SignInEntity>> signIn(
      SignInRequestModel request,
      ) async {
    final result = await _authRemoteDataSource.signIn(request);

    switch (result) {
      case SuccessBaseResponse<SignInResponseModel>():
        final model = result.data;

        if (model != null) {
          await _cacheUserSession(model);
        }

        return SuccessBaseResponse(model?.toEntity());

      case ErrorBaseResponse<SignInResponseModel>():
        return ErrorBaseResponse(result.errorMessage);
    }
  }

  @override
  Future<BaseResponse<ForgetPasswordEntity>> forgotPassword({
    required String email,
  }) async {
    final dataSource =
        _forgotPasswordMockDataSource ??
            _forgotPasswordRemoteDataSource;

    final response = await dataSource.forgotPassword(
      ForgetPasswordRequest(email: email),
    );

    switch (response) {
      case SuccessBaseResponse<ForgetPasswordResponse>():
        return SuccessBaseResponse(
          response.data?.toEntity(),
        );

      case ErrorBaseResponse<ForgetPasswordResponse>():
        return ErrorBaseResponse(response.errorMessage);
    }
  }

  @override
  Future<BaseResponse<ForgetPasswordEntity>> verifyResetCode({
    required String resetCode,
  }) async {
    final dataSource =
        _forgotPasswordMockDataSource ??
            _forgotPasswordRemoteDataSource;

    final response = await dataSource.verifyResetCode(
      VerifyResetCodeRequest(resetCode: resetCode),
    );

    switch (response) {
      case SuccessBaseResponse<VerifyResetCodeResponse>():
        return SuccessBaseResponse(
          response.data?.toEntity(),
        );

      case ErrorBaseResponse<VerifyResetCodeResponse>():
        return ErrorBaseResponse(response.errorMessage);
    }
  }

  @override
  Future<BaseResponse<ForgetPasswordEntity>> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    final dataSource =
        _forgotPasswordMockDataSource ??
            _forgotPasswordRemoteDataSource;

    final response = await dataSource.resetPassword(
      ResetPasswordRequest(
        email: email,
        newPassword: newPassword,
      ),
    );

    switch (response) {
      case SuccessBaseResponse<ResetPasswordResponse>():
        return SuccessBaseResponse(
          response.data?.toEntity(),
        );

      case ErrorBaseResponse<ResetPasswordResponse>():
        return ErrorBaseResponse(response.errorMessage);
    }
  }

  Future<void> _cacheUserSession(
      SignInResponseModel model,
      ) async {
    final token = model.token;

    if (token != null && token.isNotEmpty) {
      await _secureCacheHelper.writeData(
        key: AppKeys.tokenKey,
        value: token,
      );
    }

    final user = model.user;

    if (user == null) return;

    await _secureCacheHelper.writeData(
      key: AppKeys.userDataKey,
      value: jsonEncode(user.toJson()),
    );

    final userId = user.id;

    if (userId != null) {
      await _secureCacheHelper.writeData(
        key: AppKeys.userIdKey,
        value: userId,
      );
    }
  }
}