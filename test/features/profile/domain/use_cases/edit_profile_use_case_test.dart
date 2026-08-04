import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/features/auth/domain/entities/user_entity.dart';
import 'package:super_fitness/features/profile/data/models/request/edit_profile_request.dart';
import 'package:super_fitness/features/profile/domain/repo/profile_repo_contract.dart';
import 'package:super_fitness/features/profile/domain/use_cases/edit_profile_use_case.dart';

import 'edit_profile_use_case_test.mocks.dart';

@GenerateMocks([ProfileRepoContract])
void main() {
  late MockProfileRepoContract repo;
  late EditProfileUseCase useCase;

  const request = EditProfileRequest(firstName: 'Ahmed', lastName: 'Mohamed');
  const user = UserEntity(id: '123', firstName: 'Ahmed', lastName: 'Mohamed');

  setUpAll(() {
    provideDummy<BaseResponse<UserEntity>>(const SuccessBaseResponse(null));
  });

  setUp(() {
    repo = MockProfileRepoContract();
    useCase = EditProfileUseCase(repo);
  });

  group('EditProfileUseCase', () {
    test('returns success response from repository unchanged', () async {
      const expectedResponse = SuccessBaseResponse<UserEntity>(user);
      when(repo.editProfile(request)).thenAnswer((_) async => expectedResponse);

      final result = await useCase(request);

      expect(result, equals(expectedResponse));
      verify(repo.editProfile(request)).called(1);
    });

    test('returns error response from repository unchanged', () async {
      const expectedResponse = ErrorBaseResponse<UserEntity>('Update failed');
      when(repo.editProfile(request)).thenAnswer((_) async => expectedResponse);

      final result = await useCase(request);

      expect(result, equals(expectedResponse));
      verify(repo.editProfile(request)).called(1);
    });
  });
}
