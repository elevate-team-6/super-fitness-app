import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/config/cache/secure_cache_helper.dart';
import 'package:super_fitness/features/auth/data/data_sources/auth_remote_data_source_contract.dart';
import 'package:super_fitness/features/auth/data/models/request/signup_request.dart';
import 'package:super_fitness/features/auth/data/models/response/signup_response.dart';
import 'package:super_fitness/features/auth/data/repo/auth_repo_impl.dart';
import 'package:super_fitness/features/auth/domain/entities/user_entity.dart';

import 'auth_repo_impl_test.mocks.dart';

@GenerateMocks([AuthRemoteDataSourceContract, SecureCacheHelper])
void main() {
  provideDummy<BaseResponse<SignupResponse>>(
    const SuccessBaseResponse<SignupResponse>(null),
  );
  late AuthRepoImpl repository;
  late MockAuthRemoteDataSourceContract mockRemoteDataSource;
  late MockSecureCacheHelper mockSecureCacheHelper;

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSourceContract();
    mockSecureCacheHelper = MockSecureCacheHelper();
    repository = AuthRepoImpl(mockRemoteDataSource, mockSecureCacheHelper);
  });

  group('AuthRepoImpl', () {
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
      user: UserModel(
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

    const tUserEntity = UserEntity(
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
      photo: '',
    );

    test(
      'should return SuccessBaseResponse with UserEntity when signup is successful',
      () async {
        // arrange
        when(mockRemoteDataSource.signup(any)).thenAnswer(
          (_) async => SuccessBaseResponse<SignupResponse>(tSignupResponse),
        );
        when(
          mockSecureCacheHelper.writeData(
            key: anyNamed('key'),
            value: anyNamed('value'),
          ),
        ).thenAnswer((_) async => Future.value());

        // act
        final result = await repository.signup(tSignupRequest);

        // assert
        expect(result, isA<SuccessBaseResponse<UserEntity>>());
        expect((result as SuccessBaseResponse).data, equals(tUserEntity));
        verify(mockRemoteDataSource.signup(tSignupRequest)).called(1);
        verify(
          mockSecureCacheHelper.writeData(
            key: 'token',
            value: 'test_token_123',
          ),
        ).called(1);
        verifyNoMoreInteractions(mockRemoteDataSource);
        verifyNoMoreInteractions(mockSecureCacheHelper);
      },
    );

    test(
      'should return ErrorBaseResponse when user is null in response',
      () async {
        // arrange
        const responseWithoutUser = SignupResponse(
          message: 'Registration failed',
          token: null,
          user: null,
        );
        when(
          mockRemoteDataSource.signup(any),
        ).thenAnswer((_) async => SuccessBaseResponse(responseWithoutUser));

        // act
        final result = await repository.signup(tSignupRequest);

        // assert
        expect(result, isA<ErrorBaseResponse<UserEntity>>());
        expect((result as ErrorBaseResponse).errorMessage, isNotEmpty);
        verify(mockRemoteDataSource.signup(tSignupRequest)).called(1);
        verifyNever(
          mockSecureCacheHelper.writeData(
            key: anyNamed('key'),
            value: anyNamed('value'),
          ),
        );
        verifyNoMoreInteractions(mockRemoteDataSource);
        verifyNoMoreInteractions(mockSecureCacheHelper);
      },
    );

    test(
      'should return ErrorBaseResponse when remote data source returns error',
      () async {
        // arrange
        const errorMessage = 'Email already exists';
        when(mockRemoteDataSource.signup(any)).thenAnswer(
          (_) async => ErrorBaseResponse<SignupResponse>(errorMessage),
        );

        // act
        final result = await repository.signup(tSignupRequest);

        // assert
        expect(result, isA<ErrorBaseResponse<UserEntity>>());
        expect(
          (result as ErrorBaseResponse).errorMessage,
          equals(errorMessage),
        );
        verify(mockRemoteDataSource.signup(tSignupRequest)).called(1);
        verifyNever(
          mockSecureCacheHelper.writeData(
            key: anyNamed('key'),
            value: anyNamed('value'),
          ),
        );
        verifyNoMoreInteractions(mockRemoteDataSource);
        verifyNoMoreInteractions(mockSecureCacheHelper);
      },
    );

    test(
      'should save token to secure cache when signup is successful',
      () async {
        // arrange
        const testToken = 'saved_token_456';
        const responseWithToken = SignupResponse(
          message: 'Success',
          token: testToken,
          user: UserModel(
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
        when(
          mockRemoteDataSource.signup(any),
        ).thenAnswer((_) async => SuccessBaseResponse(responseWithToken));
        when(
          mockSecureCacheHelper.writeData(
            key: anyNamed('key'),
            value: anyNamed('value'),
          ),
        ).thenAnswer((_) async => Future.value());

        // act
        await repository.signup(tSignupRequest);

        // assert
        verify(
          mockSecureCacheHelper.writeData(key: 'token', value: testToken),
        ).called(1);
      },
    );

    test('should not save token when signup fails', () async {
      // arrange
      when(
        mockRemoteDataSource.signup(any),
      ).thenAnswer((_) async => ErrorBaseResponse<SignupResponse>('Error'));

      // act
      await repository.signup(tSignupRequest);

      // assert
      verifyNever(
        mockSecureCacheHelper.writeData(
          key: anyNamed('key'),
          value: anyNamed('value'),
        ),
      );
    });

    test('should not save token when user is null in response', () async {
      // arrange
      const responseWithoutUser = SignupResponse(
        message: 'Success',
        token: 'some_token',
        user: null,
      );
      when(
        mockRemoteDataSource.signup(any),
      ).thenAnswer((_) async => SuccessBaseResponse(responseWithoutUser));

      // act
      await repository.signup(tSignupRequest);

      // assert
      verifyNever(
        mockSecureCacheHelper.writeData(
          key: anyNamed('key'),
          value: anyNamed('value'),
        ),
      );
    });

    test('should convert UserModel to UserEntity correctly', () async {
      // arrange
      when(
        mockRemoteDataSource.signup(any),
      ).thenAnswer((_) async => SuccessBaseResponse(tSignupResponse));
      when(
        mockSecureCacheHelper.writeData(
          key: anyNamed('key'),
          value: anyNamed('value'),
        ),
      ).thenAnswer((_) async => Future.value());

      // act
      final result = await repository.signup(tSignupRequest);

      // assert
      final userEntity = (result as SuccessBaseResponse<UserEntity>).data!;
      expect(userEntity.id, equals('user_123'));
      expect(userEntity.firstName, equals('John'));
      expect(userEntity.lastName, equals('Doe'));
      expect(userEntity.email, equals('john@example.com'));
      expect(userEntity.gender, equals('male'));
      expect(userEntity.age, equals(25));
      expect(userEntity.weight, equals(75));
      expect(userEntity.height, equals(180));
      expect(userEntity.activityLevel, equals('moderate'));
      expect(userEntity.goal, equals('weight_loss'));
      expect(userEntity.photo, equals(''));
    });

    test('should handle secure cache write error gracefully', () async {
      // arrange
      when(
        mockRemoteDataSource.signup(any),
      ).thenAnswer((_) async => SuccessBaseResponse(tSignupResponse));
      when(
        mockSecureCacheHelper.writeData(
          key: anyNamed('key'),
          value: anyNamed('value'),
        ),
      ).thenThrow(Exception('Cache write failed'));

      // act & assert
      await expectLater(
        repository.signup(tSignupRequest),
        throwsA(isA<Exception>()),
      );
      verify(mockRemoteDataSource.signup(tSignupRequest)).called(1);
      verify(
        mockSecureCacheHelper.writeData(key: 'token', value: 'test_token_123'),
      ).called(1);
    });

    test('should pass the correct request to remote data source', () async {
      // arrange
      when(
        mockRemoteDataSource.signup(any),
      ).thenAnswer((_) async => SuccessBaseResponse(tSignupResponse));
      when(
        mockSecureCacheHelper.writeData(
          key: anyNamed('key'),
          value: anyNamed('value'),
        ),
      ).thenAnswer((_) async => Future.value());

      // act
      await repository.signup(tSignupRequest);

      // assert
      final captured = verify(
        mockRemoteDataSource.signup(captureAny),
      ).captured.single;
      expect(captured, equals(tSignupRequest));
    });

    test('should handle null token in response', () async {
      // arrange
      const responseWithNullToken = SignupResponse(
        message: 'Success',
        token: null,
        user: UserModel(
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
      when(
        mockRemoteDataSource.signup(any),
      ).thenAnswer((_) async => SuccessBaseResponse(responseWithNullToken));
      when(
        mockSecureCacheHelper.writeData(
          key: anyNamed('key'),
          value: anyNamed('value'),
        ),
      ).thenAnswer((_) async => Future.value());

      // act
      final result = await repository.signup(tSignupRequest);

      // assert
      expect(result, isA<SuccessBaseResponse<UserEntity>>());
      verify(
        mockSecureCacheHelper.writeData(key: 'token', value: null),
      ).called(1);
    });
  });
}
