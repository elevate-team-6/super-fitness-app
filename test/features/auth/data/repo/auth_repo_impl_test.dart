import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/features/auth/data/data_sources/auth_remote_data_source_contract.dart';
import 'package:super_fitness/features/auth/data/models/request/sign_in_request_model.dart';
import 'package:super_fitness/features/auth/data/models/response/sign_in_response_model.dart';
import 'package:super_fitness/features/auth/data/models/response/user_model.dart';
import 'package:super_fitness/features/auth/data/repo/auth_repo_impl.dart';
import 'package:super_fitness/features/auth/domain/entities/sign_in_entity.dart';

import 'auth_repo_impl_test.mocks.dart';

@GenerateMocks([AuthRemoteDataSourceContract])
void main() {
  late MockAuthRemoteDataSourceContract mockDataSource;
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
    mockDataSource = MockAuthRemoteDataSourceContract();
    repo = AuthRepoImpl(mockDataSource);

    provideDummy<BaseResponse<SignInResponseModel>>(ErrorBaseResponse('dummy'));
  });

  group('signIn', () {
    test('forwards the request to the remote data source', () async {
      when(
        mockDataSource.signIn(request),
      ).thenAnswer((_) async => SuccessBaseResponse(responseModel));

      await repo.signIn(request);

      verify(mockDataSource.signIn(request)).called(1);
    });

    test('maps a successful response model to its entity', () async {
      when(
        mockDataSource.signIn(request),
      ).thenAnswer((_) async => SuccessBaseResponse(responseModel));

      final result = await repo.signIn(request);

      expect(result, isA<SuccessBaseResponse<SignInEntity>>());
      final entity = (result as SuccessBaseResponse<SignInEntity>).data;
      expect(entity?.message, 'success');
      expect(entity?.token, 'fake_token');
      // The nested user model is mapped too, field by field.
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
      when(mockDataSource.signIn(request)).thenAnswer(
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
        mockDataSource.signIn(request),
      ).thenAnswer((_) async => SuccessBaseResponse(null));

      final result = await repo.signIn(request);

      expect(result, isA<SuccessBaseResponse<SignInEntity>>());
      expect((result as SuccessBaseResponse<SignInEntity>).data, isNull);
    });

    test('passes the error message through on failure', () async {
      when(
        mockDataSource.signIn(request),
      ).thenAnswer((_) async => ErrorBaseResponse('invalid credentials'));

      final result = await repo.signIn(request);

      expect(result, isA<ErrorBaseResponse<SignInEntity>>());
      expect(
        (result as ErrorBaseResponse<SignInEntity>).errorMessage,
        'invalid credentials',
      );
    });
  });
}
