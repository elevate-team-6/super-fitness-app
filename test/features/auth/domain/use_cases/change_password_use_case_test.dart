import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/features/auth/domain/entities/forget_password_entity.dart';
import 'package:super_fitness/features/auth/domain/repo/auth_repo_contract.dart';
import 'package:super_fitness/features/auth/domain/use_cases/change_password_use_case.dart';

import 'change_password_use_case_test.mocks.dart';

@GenerateMocks([AuthRepoContract])
void main() {
  late MockAuthRepoContract mockRepository;
  late ChangePasswordUseCase useCase;

  const tOldPassword = 'OldPassword@123';
  const tNewPassword = 'NewPassword@123';
  const tSuccessEntity = ForgetPasswordEntity(
    message: 'Password changed successfully',
    status: 'success',
  );

  setUp(() {
    provideDummy<BaseResponse<ForgetPasswordEntity>>(
      ErrorBaseResponse<ForgetPasswordEntity>('dummy'),
    );
    mockRepository = MockAuthRepoContract();
    useCase = ChangePasswordUseCase(mockRepository);
  });

  group('ChangePasswordUseCase', () {
    test(
      'should call repository.changePassword once with correct parameters and return SuccessBaseResponse',
      () async {
        // arrange
        const expectedResponse = SuccessBaseResponse<ForgetPasswordEntity>(
          tSuccessEntity,
        );
        when(
          mockRepository.changePassword(
            password: tOldPassword,
            newPassword: tNewPassword,
          ),
        ).thenAnswer((_) async => expectedResponse);

        // act
        final result = await useCase(
          password: tOldPassword,
          newPassword: tNewPassword,
        );

        // assert
        expect(result, equals(expectedResponse));
        verify(
          mockRepository.changePassword(
            password: tOldPassword,
            newPassword: tNewPassword,
          ),
        ).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test(
      'should call repository.changePassword once and forward ErrorBaseResponse unchanged',
      () async {
        // arrange
        const expectedResponse = ErrorBaseResponse<ForgetPasswordEntity>(
          'Invalid credentials',
        );
        when(
          mockRepository.changePassword(
            password: tOldPassword,
            newPassword: tNewPassword,
          ),
        ).thenAnswer((_) async => expectedResponse);

        // act
        final result = await useCase(
          password: tOldPassword,
          newPassword: tNewPassword,
        );

        // assert
        expect(result, equals(expectedResponse));
        verify(
          mockRepository.changePassword(
            password: tOldPassword,
            newPassword: tNewPassword,
          ),
        ).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );
  });
}
