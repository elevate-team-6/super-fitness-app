import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/features/auth/api/api_client/auth_api_client.dart';
import 'package:super_fitness/features/auth/api/data_sources/auth_remote_data_source_impl.dart';
import 'package:super_fitness/features/auth/data/models/request/sign_in_request_model.dart';
import 'package:super_fitness/features/auth/data/models/response/sign_in_response_model.dart';
import 'package:super_fitness/features/auth/data/models/response/user_model.dart';

import 'auth_remote_data_source_impl_test.mocks.dart';

@GenerateMocks([AuthApiClient])
void main() {
  late MockAuthApiClient mockApiClient;
  late AuthRemoteDataSourceImpl dataSource;

  const request = SignInRequestModel(
    email: 'test@test.com',
    password: 'Ahmed@123',
  );

  const responseModel = SignInResponseModel(
    message: 'success',
    token: 'fake_token',
    user: UserModel(id: 'u1', firstName: 'Ahmed'),
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
}
