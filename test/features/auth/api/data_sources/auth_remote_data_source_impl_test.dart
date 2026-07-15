import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/features/auth/api/api_client/auth_api_client.dart';
import 'package:super_fitness/features/auth/api/data_sources/auth_remote_data_source_impl.dart';
import 'package:super_fitness/features/auth/data/models/request/forgot_password_request.dart';
import 'package:super_fitness/features/auth/data/models/request/reset_password_request.dart';
import 'package:super_fitness/features/auth/data/models/request/verify_reset_code_request.dart';
import 'package:super_fitness/features/auth/data/models/response/forgot_password_response.dart';
import 'package:super_fitness/features/auth/data/models/response/reset_password_response.dart';
import 'package:super_fitness/features/auth/data/models/response/verify_reset_code_response.dart';

import 'auth_remote_data_source_impl_test.mocks.dart';

@GenerateMocks([AuthApiClient])
void main() {
  late MockAuthApiClient mockApiClient;
  late AuthRemoteDataSourceImpl remoteDataSource;

  setUp(() {
    mockApiClient = MockAuthApiClient();
    remoteDataSource = AuthRemoteDataSourceImpl(mockApiClient);
  });

  group('forgotPassword', () {
    test('should return SuccessBaseResponse when api call succeeds', () async {
      final request = ForgetPasswordRequest(email: 'test@test.com');

      const response = ForgetPasswordResponse(message: 'Success');

      when(
        mockApiClient.forgotPassword(request),
      ).thenAnswer((_) async => response);

      final result = await remoteDataSource.forgotPassword(request);

      expect(result, isA<SuccessBaseResponse<ForgetPasswordResponse>>());

      verify(mockApiClient.forgotPassword(request)).called(1);
      verifyNoMoreInteractions(mockApiClient);
    });

    test(
      'should return ErrorBaseResponse when api call throws exception',
      () async {
        final request = ForgetPasswordRequest(email: 'test@test.com');

        when(
          mockApiClient.forgotPassword(request),
        ).thenThrow(Exception('Network Error'));

        final result = await remoteDataSource.forgotPassword(request);

        expect(result, isA<ErrorBaseResponse<ForgetPasswordResponse>>());

        verify(mockApiClient.forgotPassword(request)).called(1);
        verifyNoMoreInteractions(mockApiClient);
      },
    );
  });

  group('verifyResetCode', () {
    test('should return SuccessBaseResponse when api call succeeds', () async {
      final request = VerifyResetCodeRequest(resetCode: '123456');

      const response = VerifyResetCodeResponse(
        status: 'success',
        message: 'Code verified',
      );

      when(
        mockApiClient.verifyResetCode(request),
      ).thenAnswer((_) async => response);

      final result = await remoteDataSource.verifyResetCode(request);

      expect(result, isA<SuccessBaseResponse<VerifyResetCodeResponse>>());

      verify(mockApiClient.verifyResetCode(request)).called(1);
      verifyNoMoreInteractions(mockApiClient);
    });

    test(
      'should return ErrorBaseResponse when api call throws exception',
      () async {
        final request = VerifyResetCodeRequest(resetCode: '123456');

        when(
          mockApiClient.verifyResetCode(request),
        ).thenThrow(Exception('Network Error'));

        final result = await remoteDataSource.verifyResetCode(request);

        expect(result, isA<ErrorBaseResponse<VerifyResetCodeResponse>>());

        verify(mockApiClient.verifyResetCode(request)).called(1);
        verifyNoMoreInteractions(mockApiClient);
      },
    );
  });

  group('resetPassword', () {
    test('should return SuccessBaseResponse when api call succeeds', () async {
      final request = ResetPasswordRequest(
        email: 'test@test.com',
        newPassword: '12345678',
      );

      const response = ResetPasswordResponse(
        message: 'Password reset successfully',
        token: 'token123',
      );

      when(
        mockApiClient.resetPassword(request),
      ).thenAnswer((_) async => response);

      final result = await remoteDataSource.resetPassword(request);

      expect(result, isA<SuccessBaseResponse<ResetPasswordResponse>>());

      verify(mockApiClient.resetPassword(request)).called(1);
      verifyNoMoreInteractions(mockApiClient);
    });

    test(
      'should return ErrorBaseResponse when api call throws exception',
      () async {
        final request = ResetPasswordRequest(
          email: 'test@test.com',
          newPassword: '12345678',
        );

        when(
          mockApiClient.resetPassword(request),
        ).thenThrow(Exception('Network Error'));

        final result = await remoteDataSource.resetPassword(request);

        expect(result, isA<ErrorBaseResponse<ResetPasswordResponse>>());

        verify(mockApiClient.resetPassword(request)).called(1);
        verifyNoMoreInteractions(mockApiClient);
      },
    );
  });
}
