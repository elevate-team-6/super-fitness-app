import 'package:injectable/injectable.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/config/error_handler/error_handler.dart';
import 'package:super_fitness/features/auth/api/api_client/auth_api_client.dart';
import 'package:super_fitness/features/auth/data/data_sources/forget_password_remote_data_source_contract.dart';
import 'package:super_fitness/features/auth/data/models/request/forgot_password_request.dart';
import 'package:super_fitness/features/auth/data/models/request/reset_password_request.dart';
import 'package:super_fitness/features/auth/data/models/request/verify_reset_code_request.dart';
import 'package:super_fitness/features/auth/data/models/response/forgot_password_response.dart';
import 'package:super_fitness/features/auth/data/models/response/reset_password_response.dart';
import 'package:super_fitness/features/auth/data/models/response/verify_reset_code_response.dart';

@Injectable(as: ForgotPasswordRemoteDataSourceContract)
class ForgotPasswordRemoteDataSourceImpl implements ForgotPasswordRemoteDataSourceContract {
  final AuthApiClient _apiClient;

  ForgotPasswordRemoteDataSourceImpl(this._apiClient);

  @override
  Future<BaseResponse<ForgetPasswordResponse>> forgotPassword(ForgetPasswordRequest request) {
    return ErrorHandler.handleApiCall(() => _apiClient.forgotPassword(request));
  }

  @override
  Future<BaseResponse<VerifyResetCodeResponse>> verifyResetCode(VerifyResetCodeRequest request) {
    return ErrorHandler.handleApiCall(() => _apiClient.verifyResetCode(request));
  }

  @override
  Future<BaseResponse<ResetPasswordResponse>> resetPassword(ResetPasswordRequest request) {
    return ErrorHandler.handleApiCall(() => _apiClient.resetPassword(request));
  }
}
