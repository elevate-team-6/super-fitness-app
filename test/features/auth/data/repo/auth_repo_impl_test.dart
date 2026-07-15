// import 'package:flutter_test/flutter_test.dart';
// import 'package:mockito/annotations.dart';
// import 'package:mockito/mockito.dart';
// import 'package:super_fitness/config/base_response/base_response.dart';
// import 'package:super_fitness/config/cache/secure_cache_helper.dart';
// import 'package:super_fitness/features/auth/data/data_sources/auth_remote_data_source_contract.dart';
// import 'package:super_fitness/features/auth/data/models/request/sign_in_request_model.dart';
// import 'package:super_fitness/features/auth/data/models/request/signup_request.dart';
// import 'package:super_fitness/features/auth/data/models/response/sign_in_response_model.dart';
// import 'package:super_fitness/features/auth/data/models/response/signup_response.dart';
// import 'package:super_fitness/features/auth/data/models/response/user_model.dart';
// import 'package:super_fitness/features/auth/data/repo/auth_repo_impl.dart';
// import 'package:super_fitness/features/auth/domain/entities/sign_in_entity.dart';
// import 'package:super_fitness/features/auth/domain/entities/user_entity.dart';

// import 'auth_repo_impl_test.mocks.dart';

// @GenerateMocks([AuthRemoteDataSourceContract, SecureCacheHelper])
// void main() {
//   provideDummy<BaseResponse<SignInResponseModel>>(ErrorBaseResponse('dummy'));
//   provideDummy<BaseResponse<SignupResponse>>(
//     const SuccessBaseResponse<SignupResponse>(null),
//   );

//   late AuthRepoImpl repository;
//   late MockAuthRemoteDataSourceContract mockRemoteDataSource;
//   late MockSecureCacheHelper mockSecureCacheHelper;

//   const signInRequest = SignInRequestModel(
//     email: 'test@test.com',
//     password: 'Ahmed@123',
//   );

//   const signInResponseModel = SignInResponseModel(
//     message: 'success',
//     token: 'fake_token',
//     user: UserModel(
//       id: 'u1',
//       firstName: 'Ahmed',
//       lastName: 'Emam',
//       email: 'test@test.com',
//       gender: 'male',
//       age: 25,
//       weight: 90,
//       height: 183,
//       activityLevel: 'level1',
//       goal: 'Gain weight',
//       photo: 'photo.png',
//       createdAt: '2026-07-13T15:06:13.971Z',
//     ),
//   );

//   const signupRequest = SignupRequest(
//     firstName: 'John',
//     lastName: 'Doe',
//     email: 'john@example.com',
//     password: 'password123',
//     rePassword: 'password123',
//     gender: 'male',
//     height: 180,
//     weight: 75,
//     age: 25,
//     goal: 'weight_loss',
//     activityLevel: 'moderate',
//   );

//   const signupResponse = SignupResponse(
//     message: 'Registration successful',
//     token: 'test_token_123',
//     user: UserModel(
//       id: 'user_123',
//       firstName: 'John',
//       lastName: 'Doe',
//       email: 'john@example.com',
//       gender: 'male',
//       age: 25,
//       weight: 75,
//       height: 180,
//       activityLevel: 'moderate',
//       goal: 'weight_loss',
//     ),
//   );

//   setUp(() {
//     mockRemoteDataSource = MockAuthRemoteDataSourceContract();
//     mockSecureCacheHelper = MockSecureCacheHelper();
//     repository = AuthRepoImpl(mockRemoteDataSource, mockSecureCacheHelper);
//   });

//   group('signIn', () {
//     test('forwards the request to the remote data source', () async {
//       when(
//         mockRemoteDataSource.signIn(signInRequest),
//       ).thenAnswer((_) async => SuccessBaseResponse(signInResponseModel));

//       await repository.signIn(signInRequest);

//       verify(mockRemoteDataSource.signIn(signInRequest)).called(1);
//     });

//     test('maps a successful response model to its entity', () async {
//       when(
//         mockRemoteDataSource.signIn(signInRequest),
//       ).thenAnswer((_) async => SuccessBaseResponse(signInResponseModel));

//       final result = await repository.signIn(signInRequest);

//       expect(result, isA<SuccessBaseResponse<SignInEntity>>());
//       final entity = (result as SuccessBaseResponse<SignInEntity>).data;
//       expect(entity?.message, 'success');
//       expect(entity?.token, 'fake_token');
//       expect(entity?.user?.id, 'u1');
//       expect(entity?.user?.firstName, 'Ahmed');
//       expect(entity?.user?.lastName, 'Emam');
//       expect(entity?.user?.email, 'test@test.com');
//       expect(entity?.user?.gender, 'male');
//       expect(entity?.user?.age, 25);
//       expect(entity?.user?.weight, 90);
//       expect(entity?.user?.height, 183);
//       expect(entity?.user?.activityLevel, 'level1');
//       expect(entity?.user?.goal, 'Gain weight');
//       expect(entity?.user?.photo, 'photo.png');
//     });

//     test('passes the error message through on failure', () async {
//       when(
//         mockRemoteDataSource.signIn(signInRequest),
//       ).thenAnswer((_) async => ErrorBaseResponse('invalid credentials'));

//       final result = await repository.signIn(signInRequest);

//       expect(result, isA<ErrorBaseResponse<SignInEntity>>());
//       expect(
//         (result as ErrorBaseResponse<SignInEntity>).errorMessage,
//         'invalid credentials',
//       );
//     });
//   });

//   group('signup', () {
//     test(
//       'returns a mapped UserEntity and stores the token on success',
//       () async {
//         when(
//           mockRemoteDataSource.signup(signupRequest),
//         ).thenAnswer((_) async => const SuccessBaseResponse(signupResponse));
//         when(
//           mockSecureCacheHelper.writeData(
//             key: anyNamed('key'),
//             value: anyNamed('value'),
//           ),
//         ).thenAnswer((_) async => Future.value());

//         final result = await repository.signup(signupRequest);

//         expect(result, isA<SuccessBaseResponse<UserEntity>>());
//         expect(
//           (result as SuccessBaseResponse<UserEntity>).data?.id,
//           'user_123',
//         );
//         expect((result).data?.firstName, 'John');
//         verify(mockRemoteDataSource.signup(signupRequest)).called(1);
//         verify(
//           mockSecureCacheHelper.writeData(
//             key: 'token',
//             value: 'test_token_123',
//           ),
//         ).called(1);
//       },
//     );

//     test('returns an error when the remote response has no user', () async {
//       const responseWithoutUser = SignupResponse(
//         message: 'Registration failed',
//         token: null,
//         user: null,
//       );
//       when(
//         mockRemoteDataSource.signup(signupRequest),
//       ).thenAnswer((_) async => const SuccessBaseResponse(responseWithoutUser));

//       final result = await repository.signup(signupRequest);

//       expect(result, isA<ErrorBaseResponse<UserEntity>>());
//       expect(
//         (result as ErrorBaseResponse<UserEntity>).errorMessage,
//         isNotEmpty,
//       );
//       verifyNever(
//         mockSecureCacheHelper.writeData(
//           key: anyNamed('key'),
//           value: anyNamed('value'),
//         ),
//       );
//     });

//     test('passes through the remote error response', () async {
//       const errorMessage = 'Email already exists';
//       when(mockRemoteDataSource.signup(signupRequest)).thenAnswer(
//         (_) async => ErrorBaseResponse<SignupResponse>(errorMessage),
//       );

//       final result = await repository.signup(signupRequest);

//       expect(result, isA<ErrorBaseResponse<UserEntity>>());
//       expect(
//         (result as ErrorBaseResponse<UserEntity>).errorMessage,
//         errorMessage,
//       );
//       verifyNever(
//         mockSecureCacheHelper.writeData(
//           key: anyNamed('key'),
//           value: anyNamed('value'),
//         ),
//       );
//     });
//   });
// }
