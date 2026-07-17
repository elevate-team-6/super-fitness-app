import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/config/cache/secure_cache_helper.dart';
import 'package:super_fitness/core/utils/app_keys.dart';
import 'package:super_fitness/features/auth/data/data_sources/auth_remote_data_source_contract.dart';
import 'package:super_fitness/features/auth/data/data_sources/forget_password_remote_data_source_contract.dart';
import 'package:super_fitness/features/auth/data/models/request/sign_in_request_model.dart';
import 'package:super_fitness/features/auth/data/models/response/forgot_password_response.dart';
import 'package:super_fitness/features/auth/data/models/response/reset_password_response.dart';
import 'package:super_fitness/features/auth/data/models/response/sign_in_response_model.dart';
import 'package:super_fitness/features/auth/data/models/response/user_model.dart';
import 'package:super_fitness/features/auth/data/models/response/verify_reset_code_response.dart';
import 'package:super_fitness/features/auth/data/repo/auth_repo_impl.dart';
import 'package:super_fitness/features/auth/domain/entities/forget_password_entity.dart';
import 'package:super_fitness/features/auth/domain/entities/sign_in_entity.dart';

import 'auth_repo_impl_test.mocks.dart';

@GenerateMocks([
  AuthRemoteDataSourceContract,
  ForgotPasswordRemoteDataSourceContract,
  SecureCacheHelper,
])
void main() {
  late MockAuthRemoteDataSourceContract mockAuthRemoteDataSource;
  late MockForgotPasswordRemoteDataSourceContract
  mockForgotPasswordRemoteDataSource;
  late MockSecureCacheHelper mockCache;
  late AuthRepoImpl repo;

  const request = SignInRequestModel(
    email: 'test@test.com',
    password: 'Ahmed@123',
  );

  const userModel = UserModel(
    id: 'u1',
    firstName: 'Ahmed',
    lastName: 'Emam',
    email: 'test@test.com',
    gender: 'male',
    age: 25,
    weight: 90,
    height: 183,
    activityLevel: 'level1',
    goal: 'Gain weight',
    photo: 'photo.png',
    createdAt: '2026-07-13T15:06:13.971Z',
  );

  const responseModel = SignInResponseModel(
    message: 'success',
    token: 'fake_token',
    user: userModel,
  );

  setUp(() {
    mockAuthRemoteDataSource = MockAuthRemoteDataSourceContract();
    mockForgotPasswordRemoteDataSource =
        MockForgotPasswordRemoteDataSourceContract();
    mockCache = MockSecureCacheHelper();

    repo = AuthRepoImpl(
      mockAuthRemoteDataSource,
      mockForgotPasswordRemoteDataSource,
      mockCache,
    );

    when(
      mockCache.writeData(key: anyNamed('key'), value: anyNamed('value')),
    ).thenAnswer((_) async {});

    provideDummy<BaseResponse<SignInResponseModel>>(ErrorBaseResponse('dummy'));

    provideDummy<BaseResponse<ForgetPasswordResponse>>(
      ErrorBaseResponse('dummy'),
    );

    provideDummy<BaseResponse<VerifyResetCodeResponse>>(
      ErrorBaseResponse('dummy'),
    );

    provideDummy<BaseResponse<ResetPasswordResponse>>(
      ErrorBaseResponse('dummy'),
    );
  });
  group('signIn', () {
    test('forwards the request to the remote data source', () async {
      when(
        mockAuthRemoteDataSource.signIn(request),
      ).thenAnswer((_) async => SuccessBaseResponse(responseModel));

      await repo.signIn(request);

      verify(mockAuthRemoteDataSource.signIn(request)).called(1);
    });

    test('maps a successful response model to its entity', () async {
      when(
        mockAuthRemoteDataSource.signIn(request),
      ).thenAnswer((_) async => SuccessBaseResponse(responseModel));

      final result = await repo.signIn(request);

      expect(result, isA<SuccessBaseResponse<SignInEntity>>());

      final entity = (result as SuccessBaseResponse<SignInEntity>).data;

      expect(entity?.message, 'success');
      expect(entity?.token, 'fake_token');
      expect(entity?.user?.id, 'u1');
      expect(entity?.user?.firstName, 'Ahmed');
      expect(entity?.user?.lastName, 'Emam');
      expect(entity?.user?.email, 'test@test.com');
      expect(entity?.user?.gender, 'male');
      expect(entity?.user?.age, 25);
      expect(entity?.user?.weight, 90);
      expect(entity?.user?.height, 183);
      expect(entity?.user?.activityLevel, 'level1');
      expect(entity?.user?.goal, 'Gain weight');
      expect(entity?.user?.photo, 'photo.png');
    });

    test('maps a success with no user to an entity with a null user', () async {
      when(mockAuthRemoteDataSource.signIn(request)).thenAnswer(
        (_) async => SuccessBaseResponse(
          const SignInResponseModel(message: 'success', token: 'fake_token'),
        ),
      );

      final result = await repo.signIn(request);

      final entity = (result as SuccessBaseResponse<SignInEntity>).data;

      expect(entity?.token, 'fake_token');
      expect(entity?.user, isNull);
    });

    test('maps a success with null data to a success with null data', () async {
      when(
        mockAuthRemoteDataSource.signIn(request),
      ).thenAnswer((_) async => SuccessBaseResponse(null));

      final result = await repo.signIn(request);

      expect(result, isA<SuccessBaseResponse<SignInEntity>>());
      expect((result as SuccessBaseResponse<SignInEntity>).data, isNull);
    });

    test('passes the error message through on failure', () async {
      when(
        mockAuthRemoteDataSource.signIn(request),
      ).thenAnswer((_) async => ErrorBaseResponse('invalid credentials'));

      final result = await repo.signIn(request);

      expect(result, isA<ErrorBaseResponse<SignInEntity>>());

      expect(
        (result as ErrorBaseResponse<SignInEntity>).errorMessage,
        'invalid credentials',
      );
    });
  });

  group('signIn session caching', () {
    test('caches the token, the full user data and the user id', () async {
      when(
        mockAuthRemoteDataSource.signIn(request),
      ).thenAnswer((_) async => SuccessBaseResponse(responseModel));

      await repo.signIn(request);

      verify(
        mockCache.writeData(key: AppKeys.tokenKey, value: 'fake_token'),
      ).called(1);

      verify(
        mockCache.writeData(key: AppKeys.userIdKey, value: 'u1'),
      ).called(1);

      final userJson =
          verify(
                mockCache.writeData(
                  key: AppKeys.userDataKey,
                  value: captureAnyNamed('value'),
                ),
              ).captured.single
              as String;

      expect(userJson, contains('Ahmed'));
      expect(userJson, contains('Gain weight'));
      expect(userJson, contains('183'));
    });

    test('does not cache an empty token', () async {
      when(mockAuthRemoteDataSource.signIn(request)).thenAnswer(
        (_) async => SuccessBaseResponse(
          const SignInResponseModel(
            message: 'success',
            token: '',
            user: userModel,
          ),
        ),
      );

      await repo.signIn(request);

      verifyNever(
        mockCache.writeData(key: AppKeys.tokenKey, value: anyNamed('value')),
      );
    });

    test('skips the user cache when the response has no user', () async {
      when(mockAuthRemoteDataSource.signIn(request)).thenAnswer(
        (_) async => SuccessBaseResponse(
          const SignInResponseModel(message: 'success', token: 'fake_token'),
        ),
      );

      await repo.signIn(request);

      verify(
        mockCache.writeData(key: AppKeys.tokenKey, value: 'fake_token'),
      ).called(1);

      verifyNever(
        mockCache.writeData(key: AppKeys.userDataKey, value: anyNamed('value')),
      );
    });

    test('caches nothing when sign-in fails', () async {
      when(
        mockAuthRemoteDataSource.signIn(request),
      ).thenAnswer((_) async => ErrorBaseResponse('invalid credentials'));

      await repo.signIn(request);

      verifyNever(
        mockCache.writeData(key: anyNamed('key'), value: anyNamed('value')),
      );
    });
  });
  group('forgotPassword', () {
    test('should return SuccessBaseResponse<ForgetPasswordEntity>', () async {
      const response = ForgetPasswordResponse(
        message: 'OTP Sent',
        info: 'Success',
      );

      when(
        mockForgotPasswordRemoteDataSource.forgotPassword(any),
      ).thenAnswer((_) async => SuccessBaseResponse(response));

      final result = await repo.forgotPassword(email: 'test@test.com');

      expect(result, isA<SuccessBaseResponse<ForgetPasswordEntity>>());

      verify(mockForgotPasswordRemoteDataSource.forgotPassword(any)).called(1);

      verifyNoMoreInteractions(mockForgotPasswordRemoteDataSource);
    });

    test('should return ErrorBaseResponse<ForgetPasswordEntity>', () async {
      when(
        mockForgotPasswordRemoteDataSource.forgotPassword(any),
      ).thenAnswer((_) async => ErrorBaseResponse('Error'));

      final result = await repo.forgotPassword(email: 'test@test.com');

      expect(result, isA<ErrorBaseResponse<ForgetPasswordEntity>>());

      verify(mockForgotPasswordRemoteDataSource.forgotPassword(any)).called(1);

      verifyNoMoreInteractions(mockForgotPasswordRemoteDataSource);
    });
  });

  group('verifyResetCode', () {
    test('should return SuccessBaseResponse<ForgetPasswordEntity>', () async {
      const response = VerifyResetCodeResponse(
        status: 'Success',
        message: 'Verified',
      );

      when(
        mockForgotPasswordRemoteDataSource.verifyResetCode(any),
      ).thenAnswer((_) async => SuccessBaseResponse(response));

      final result = await repo.verifyResetCode(resetCode: '123456');

      expect(result, isA<SuccessBaseResponse<ForgetPasswordEntity>>());

      verify(mockForgotPasswordRemoteDataSource.verifyResetCode(any)).called(1);

      verifyNoMoreInteractions(mockForgotPasswordRemoteDataSource);
    });

    test('should return ErrorBaseResponse<ForgetPasswordEntity>', () async {
      when(
        mockForgotPasswordRemoteDataSource.verifyResetCode(any),
      ).thenAnswer((_) async => ErrorBaseResponse('Error'));

      final result = await repo.verifyResetCode(resetCode: '123456');

      expect(result, isA<ErrorBaseResponse<ForgetPasswordEntity>>());

      verify(mockForgotPasswordRemoteDataSource.verifyResetCode(any)).called(1);

      verifyNoMoreInteractions(mockForgotPasswordRemoteDataSource);
    });
  });

  group('resetPassword', () {
    test('should return SuccessBaseResponse<ForgetPasswordEntity>', () async {
      const response = ResetPasswordResponse(
        message: 'Password Reset',
        token: 'token123',
      );

      when(
        mockForgotPasswordRemoteDataSource.resetPassword(any),
      ).thenAnswer((_) async => SuccessBaseResponse(response));

      final result = await repo.resetPassword(
        email: 'test@test.com',
        newPassword: '12345678',
      );

      expect(result, isA<SuccessBaseResponse<ForgetPasswordEntity>>());

      verify(mockForgotPasswordRemoteDataSource.resetPassword(any)).called(1);

      verifyNoMoreInteractions(mockForgotPasswordRemoteDataSource);
    });

    test('should return ErrorBaseResponse<ForgetPasswordEntity>', () async {
      when(
        mockForgotPasswordRemoteDataSource.resetPassword(any),
      ).thenAnswer((_) async => ErrorBaseResponse('Error'));

      final result = await repo.resetPassword(
        email: 'test@test.com',
        newPassword: '12345678',
      );

      expect(result, isA<ErrorBaseResponse<ForgetPasswordEntity>>());

      verify(mockForgotPasswordRemoteDataSource.resetPassword(any)).called(1);

      verifyNoMoreInteractions(mockForgotPasswordRemoteDataSource);
    });
  });
}
