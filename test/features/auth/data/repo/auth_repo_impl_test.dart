import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/features/auth/data/data_sources/auth_remote_data_source_contract.dart';
import 'package:super_fitness/features/auth/data/models/response/forgot_password_response.dart';
import 'package:super_fitness/features/auth/data/models/response/reset_password_response.dart';
import 'package:super_fitness/features/auth/data/models/response/verify_reset_code_response.dart';
import 'package:super_fitness/features/auth/data/repo/auth_repo_impl.dart';
import 'package:super_fitness/features/auth/domain/entities/forget_password_entity.dart';

import 'auth_repo_impl_test.mocks.dart';

@GenerateMocks([AuthRemoteDataSourceContract])
void main() {
  provideDummy<BaseResponse<ForgetPasswordResponse>>(
    ErrorBaseResponse('dummy'),
  );

  provideDummy<BaseResponse<VerifyResetCodeResponse>>(
    ErrorBaseResponse('dummy'),
  );

  provideDummy<BaseResponse<ResetPasswordResponse>>(ErrorBaseResponse('dummy'));

  late MockAuthRemoteDataSourceContract mockRemoteDataSource;
  late AuthRepoImpl repo;

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSourceContract();
    repo = AuthRepoImpl(mockRemoteDataSource);
  });

  group('forgotPassword', () {
    test('should return SuccessBaseResponse<ForgetPasswordEntity>', () async {
      const response = ForgetPasswordResponse(
        message: 'OTP Sent',
        info: 'Success',
      );

      when(
        mockRemoteDataSource.forgotPassword(any),
      ).thenAnswer((_) async => SuccessBaseResponse(response));

      final result = await repo.forgotPassword(email: 'test@test.com');

      expect(result, isA<SuccessBaseResponse<ForgetPasswordEntity>>());

      verify(mockRemoteDataSource.forgotPassword(any)).called(1);
      verifyNoMoreInteractions(mockRemoteDataSource);
    });

    test('should return ErrorBaseResponse<ForgetPasswordEntity>', () async {
      when(
        mockRemoteDataSource.forgotPassword(any),
      ).thenAnswer((_) async => ErrorBaseResponse('Error'));

      final result = await repo.forgotPassword(email: 'test@test.com');

      expect(result, isA<ErrorBaseResponse<ForgetPasswordEntity>>());

      verify(mockRemoteDataSource.forgotPassword(any)).called(1);
      verifyNoMoreInteractions(mockRemoteDataSource);
    });
  });

  group('verifyResetCode', () {
    test('should return SuccessBaseResponse<ForgetPasswordEntity>', () async {
      const response = VerifyResetCodeResponse(
        status: 'Success',
        message: 'Verified',
      );

      when(
        mockRemoteDataSource.verifyResetCode(any),
      ).thenAnswer((_) async => SuccessBaseResponse(response));

      final result = await repo.verifyResetCode(resetCode: '123456');

      expect(result, isA<SuccessBaseResponse<ForgetPasswordEntity>>());

      verify(mockRemoteDataSource.verifyResetCode(any)).called(1);
      verifyNoMoreInteractions(mockRemoteDataSource);
    });

    test('should return ErrorBaseResponse<ForgetPasswordEntity>', () async {
      when(
        mockRemoteDataSource.verifyResetCode(any),
      ).thenAnswer((_) async => ErrorBaseResponse('Error'));

      final result = await repo.verifyResetCode(resetCode: '123456');

      expect(result, isA<ErrorBaseResponse<ForgetPasswordEntity>>());

      verify(mockRemoteDataSource.verifyResetCode(any)).called(1);
      verifyNoMoreInteractions(mockRemoteDataSource);
    });
  });

  group('resetPassword', () {
    test('should return SuccessBaseResponse<ForgetPasswordEntity>', () async {
      const response = ResetPasswordResponse(
        message: 'Password Reset',
        token: 'token123',
      );

      when(
        mockRemoteDataSource.resetPassword(any),
      ).thenAnswer((_) async => SuccessBaseResponse(response));

      final result = await repo.resetPassword(
        email: 'test@test.com',
        newPassword: '12345678',
      );

      expect(result, isA<SuccessBaseResponse<ForgetPasswordEntity>>());

      verify(mockRemoteDataSource.resetPassword(any)).called(1);
      verifyNoMoreInteractions(mockRemoteDataSource);
    });

    test('should return ErrorBaseResponse<ForgetPasswordEntity>', () async {
      when(
        mockRemoteDataSource.resetPassword(any),
      ).thenAnswer((_) async => ErrorBaseResponse('Error'));

      final result = await repo.resetPassword(
        email: 'test@test.com',
        newPassword: '12345678',
      );

      expect(result, isA<ErrorBaseResponse<ForgetPasswordEntity>>());

      verify(mockRemoteDataSource.resetPassword(any)).called(1);
      verifyNoMoreInteractions(mockRemoteDataSource);
    });
  });
}
