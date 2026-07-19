import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/features/auth/api/api_client/auth_api_client.dart';
import 'package:super_fitness/features/auth/api/data_sources/auth_remote_data_source_impl.dart';
import 'package:super_fitness/features/auth/data/models/request/sign_in_request_model.dart';
import 'package:super_fitness/features/auth/data/models/response/sign_in_response_model.dart';
import 'package:super_fitness/features/auth/data/models/request/signup_request.dart';
import 'package:super_fitness/features/auth/data/models/response/signup_response.dart';
import 'package:super_fitness/features/auth/data/models/response/user_model.dart'
    as auth;

import 'auth_remote_data_source_impl_test.mocks.dart';

@GenerateMocks([AuthApiClient])
void main() {
  late AuthRemoteDataSourceImpl dataSource;
  late MockAuthApiClient mockApiClient;

  const request = SignInRequestModel(
    email: 'test@test.com',
    password: 'Ahmed@123',
  );

  const responseModel = SignInResponseModel(
    message: 'success',
    token: 'fake_token',
    user: auth.UserModel(id: 'u1', firstName: 'Ahmed'),
  );

  setUp(() {
    mockApiClient = MockAuthApiClient();
    dataSource = AuthRemoteDataSourceImpl(mockApiClient);
  });

  group('signIn', () {
    test('forwards the request to the api client', () async {
      when(
        mockApiClient.signIn(request),
      ).thenAnswer((_) async => responseModel);

      await dataSource.signIn(request);

      verify(mockApiClient.signIn(request)).called(1);
    });

    test('wraps a successful api response in SuccessBaseResponse', () async {
      when(
        mockApiClient.signIn(request),
      ).thenAnswer((_) async => responseModel);

      final result = await dataSource.signIn(request);

      expect(result, isA<SuccessBaseResponse<SignInResponseModel>>());
      final data = (result as SuccessBaseResponse<SignInResponseModel>).data;
      expect(data?.token, 'fake_token');
      expect(data?.user?.firstName, 'Ahmed');
    });

    test(
      'wraps a Dio failure in ErrorBaseResponse instead of throwing',
      () async {
        when(mockApiClient.signIn(request)).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/auth/signin'),
            type: DioExceptionType.connectionTimeout,
          ),
        );

        final result = await dataSource.signIn(request);

        // ErrorHandler must swallow the exception and surface it as a response.
        expect(result, isA<ErrorBaseResponse<SignInResponseModel>>());
      },
    );

    test('wraps an unexpected error in ErrorBaseResponse', () async {
      when(mockApiClient.signIn(request)).thenThrow(Exception('unexpected'));

      final result = await dataSource.signIn(request);

      expect(result, isA<ErrorBaseResponse<SignInResponseModel>>());
    });
  });

  group('register', () {
    group('AuthRemoteDataSourceImpl', () {
      const tSignupRequest = SignupRequest(
        firstName: 'John',
        lastName: 'Doe',
        email: 'john@example.com',
        password: 'password123',
        rePassword: 'password123',
        gender: 'male',
        height: 180,
        weight: 75,
        age: 25,
        goal: 'weight_loss',
        activityLevel: 'moderate',
      );

      const tSignupResponse = SignupResponse(
        message: 'Registration successful',
        token: 'test_token_123',
        user: auth.UserModel(
          id: 'user_123',
          firstName: 'John',
          lastName: 'Doe',
          email: 'john@example.com',
          gender: 'male',
          age: 25,
          weight: 75,
          height: 180,
          activityLevel: 'moderate',
          goal: 'weight_loss',
        ),
      );

      test(
        'should return SuccessBaseResponse when signup is successful',
        () async {
          // arrange
          when(
            mockApiClient.signup(any),
          ).thenAnswer((_) async => tSignupResponse);

          // act
          final result = await dataSource.signup(tSignupRequest);

          // assert
          expect(result, isA<SuccessBaseResponse<SignupResponse>>());
          verify(mockApiClient.signup(tSignupRequest)).called(1);
          verifyNoMoreInteractions(mockApiClient);
        },
      );

      test(
        'should return ErrorBaseResponse when DioException occurs',
        () async {
          // arrange
          final dioError = DioException(
            requestOptions: RequestOptions(path: '/signup'),
            type: DioExceptionType.connectionTimeout,
          );
          when(mockApiClient.signup(any)).thenThrow(dioError);

          // act
          final result = await dataSource.signup(tSignupRequest);

          // assert
          expect(result, isA<ErrorBaseResponse<SignupResponse>>());
          expect((result as ErrorBaseResponse).errorMessage, isNotEmpty);
          verify(mockApiClient.signup(tSignupRequest)).called(1);
          verifyNoMoreInteractions(mockApiClient);
        },
      );

      test(
        'should return ErrorBaseResponse when connection error occurs',
        () async {
          // arrange
          final dioError = DioException(
            requestOptions: RequestOptions(path: '/signup'),
            type: DioExceptionType.connectionError,
          );
          when(mockApiClient.signup(any)).thenThrow(dioError);

          // act
          final result = await dataSource.signup(tSignupRequest);

          // assert
          expect(result, isA<ErrorBaseResponse<SignupResponse>>());
          verify(mockApiClient.signup(tSignupRequest)).called(1);
        },
      );

      test(
        'should return ErrorBaseResponse when bad response occurs (401)',
        () async {
          // arrange
          final dioError = DioException(
            requestOptions: RequestOptions(path: '/signup'),
            type: DioExceptionType.badResponse,
            response: Response(
              statusCode: 401,
              requestOptions: RequestOptions(path: '/signup'),
            ),
          );
          when(mockApiClient.signup(any)).thenThrow(dioError);

          // act
          final result = await dataSource.signup(tSignupRequest);

          // assert
          expect(result, isA<ErrorBaseResponse<SignupResponse>>());
          verify(mockApiClient.signup(tSignupRequest)).called(1);
        },
      );

      test(
        'should return ErrorBaseResponse when bad response occurs (500)',
        () async {
          // arrange
          final dioError = DioException(
            requestOptions: RequestOptions(path: '/signup'),
            type: DioExceptionType.badResponse,
            response: Response(
              statusCode: 500,
              requestOptions: RequestOptions(path: '/signup'),
            ),
          );
          when(mockApiClient.signup(any)).thenThrow(dioError);

          // act
          final result = await dataSource.signup(tSignupRequest);

          // assert
          expect(result, isA<ErrorBaseResponse<SignupResponse>>());
          verify(mockApiClient.signup(tSignupRequest)).called(1);
        },
      );

      test(
        'should return ErrorBaseResponse when request is cancelled',
        () async {
          // arrange
          final dioError = DioException(
            requestOptions: RequestOptions(path: '/signup'),
            type: DioExceptionType.cancel,
          );
          when(mockApiClient.signup(any)).thenThrow(dioError);

          // act
          final result = await dataSource.signup(tSignupRequest);

          // assert
          expect(result, isA<ErrorBaseResponse<SignupResponse>>());
          verify(mockApiClient.signup(tSignupRequest)).called(1);
        },
      );

      test(
        'should return ErrorBaseResponse when send timeout occurs',
        () async {
          // arrange
          final dioError = DioException(
            requestOptions: RequestOptions(path: '/signup'),
            type: DioExceptionType.sendTimeout,
          );
          when(mockApiClient.signup(any)).thenThrow(dioError);

          // act
          final result = await dataSource.signup(tSignupRequest);

          // assert
          expect(result, isA<ErrorBaseResponse<SignupResponse>>());
          verify(mockApiClient.signup(tSignupRequest)).called(1);
        },
      );

      test(
        'should return ErrorBaseResponse when receive timeout occurs',
        () async {
          // arrange
          final dioError = DioException(
            requestOptions: RequestOptions(path: '/signup'),
            type: DioExceptionType.receiveTimeout,
          );
          when(mockApiClient.signup(any)).thenThrow(dioError);

          // act
          final result = await dataSource.signup(tSignupRequest);

          // assert
          expect(result, isA<ErrorBaseResponse<SignupResponse>>());
          verify(mockApiClient.signup(tSignupRequest)).called(1);
        },
      );

      test(
        'should return ErrorBaseResponse when unknown error occurs',
        () async {
          // arrange
          final dioError = DioException(
            requestOptions: RequestOptions(path: '/signup'),
            type: DioExceptionType.unknown,
          );
          when(mockApiClient.signup(any)).thenThrow(dioError);

          // act
          final result = await dataSource.signup(tSignupRequest);

          // assert
          expect(result, isA<ErrorBaseResponse<SignupResponse>>());
          verify(mockApiClient.signup(tSignupRequest)).called(1);
        },
      );

      test(
        'should return ErrorBaseResponse when non-Dio exception occurs',
        () async {
          // arrange
          when(mockApiClient.signup(any)).thenThrow(Exception('Unknown error'));

          // act
          final result = await dataSource.signup(tSignupRequest);

          // assert
          expect(result, isA<ErrorBaseResponse<SignupResponse>>());
          verify(mockApiClient.signup(tSignupRequest)).called(1);
        },
      );

      test('should pass the correct request to apiClient', () async {
        // arrange
        when(
          mockApiClient.signup(any),
        ).thenAnswer((_) async => tSignupResponse);

        // act
        await dataSource.signup(tSignupRequest);

        // assert
        final captured = verify(
          mockApiClient.signup(captureAny),
        ).captured.single;
        expect(captured, equals(tSignupRequest));
      });
    });
  });
}
