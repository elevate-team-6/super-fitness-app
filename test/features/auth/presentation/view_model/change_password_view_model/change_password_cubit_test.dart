import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/config/base_state/base_state.dart';
import 'package:super_fitness/config/base_ui_event/base_ui_event.dart';
import 'package:super_fitness/features/auth/domain/entities/forget_password_entity.dart';
import 'package:super_fitness/features/auth/domain/use_cases/change_password_use_case.dart';
import 'package:super_fitness/features/auth/presentation/view_model/change_password_view_model/change_password_cubit.dart';
import 'package:super_fitness/features/auth/presentation/view_model/change_password_view_model/change_password_events.dart';
import 'package:super_fitness/features/auth/presentation/view_model/change_password_view_model/change_password_state.dart';

import 'change_password_cubit_test.mocks.dart';

@GenerateMocks([ChangePasswordUseCase])
void main() {
  late MockChangePasswordUseCase mockChangePasswordUseCase;
  late ChangePasswordCubit cubit;

  const tOldPassword = 'OldPassword@123';
  const tValidNewPassword = 'NewPassword@123';
  const tEntity = ForgetPasswordEntity(message: 'Success', status: 'success');

  setUp(() {
    provideDummy<BaseResponse<ForgetPasswordEntity>>(
      ErrorBaseResponse<ForgetPasswordEntity>('dummy'),
    );
    mockChangePasswordUseCase = MockChangePasswordUseCase();
    cubit = ChangePasswordCubit(mockChangePasswordUseCase);
  });

  tearDown(() async {
    if (!cubit.isClosed) {
      await cubit.close();
    }
  });

  group('Initial State', () {
    test('verify initial state values', () {
      expect(cubit.state.oldPassword, isEmpty);
      expect(cubit.state.newPassword, isEmpty);
      expect(cubit.state.confirmPassword, isEmpty);
      expect(cubit.state.isFormValid, isFalse);
      expect(cubit.state.obscureOldPassword, isTrue);
      expect(cubit.state.obscureNewPassword, isTrue);
      expect(cubit.state.obscureConfirmPassword, isTrue);
      expect(
        cubit.state.changePasswordState,
        equals(const BaseState<ForgetPasswordEntity>()),
      );
      expect(cubit.state.changePasswordState.isLoading, isFalse);
    });
  });

  group('Update Events', () {
    blocTest<ChangePasswordCubit, ChangePasswordState>(
      'UpdatePasswordsEvent with oldPassword updates only oldPassword',
      build: () => cubit,
      act: (cubit) =>
          cubit.doEvent(UpdatePasswordsEvent(oldPassword: 'OldPass123!')),
      expect: () => [
        const ChangePasswordState(
          oldPassword: 'OldPass123!',
          newPassword: '',
          confirmPassword: '',
          isFormValid: false,
        ),
      ],
    );

    blocTest<ChangePasswordCubit, ChangePasswordState>(
      'UpdatePasswordsEvent with newPassword updates only newPassword',
      build: () => cubit,
      act: (cubit) =>
          cubit.doEvent(UpdatePasswordsEvent(newPassword: tValidNewPassword)),
      expect: () => [
        const ChangePasswordState(
          oldPassword: '',
          newPassword: tValidNewPassword,
          confirmPassword: '',
          isFormValid: false,
        ),
      ],
    );

    blocTest<ChangePasswordCubit, ChangePasswordState>(
      'UpdatePasswordsEvent with confirmPassword updates only confirmPassword',
      build: () => cubit,
      act: (cubit) => cubit.doEvent(
        UpdatePasswordsEvent(confirmPassword: 'ConfirmPass123!'),
      ),
      expect: () => [
        const ChangePasswordState(
          oldPassword: '',
          newPassword: '',
          confirmPassword: 'ConfirmPass123!',
          isFormValid: false,
        ),
      ],
    );

    blocTest<ChangePasswordCubit, ChangePasswordState>(
      'ToggleOldPasswordVisibilityEvent toggles obscureOldPassword from true to false',
      build: () => cubit,
      act: (cubit) => cubit.doEvent(ToggleOldPasswordVisibilityEvent()),
      expect: () => [const ChangePasswordState(obscureOldPassword: false)],
    );

    blocTest<ChangePasswordCubit, ChangePasswordState>(
      'ToggleNewPasswordVisibilityEvent toggles obscureNewPassword from true to false',
      build: () => cubit,
      act: (cubit) => cubit.doEvent(ToggleNewPasswordVisibilityEvent()),
      expect: () => [const ChangePasswordState(obscureNewPassword: false)],
    );

    blocTest<ChangePasswordCubit, ChangePasswordState>(
      'ToggleConfirmPasswordVisibilityEvent toggles obscureConfirmPassword from true to false',
      build: () => cubit,
      act: (cubit) => cubit.doEvent(ToggleConfirmPasswordVisibilityEvent()),
      expect: () => [const ChangePasswordState(obscureConfirmPassword: false)],
    );
  });

  group('Form Validation', () {
    blocTest<ChangePasswordCubit, ChangePasswordState>(
      'case: all fields empty -> isFormValid == false',
      build: () => cubit,
      act: (cubit) => cubit.doEvent(
        UpdatePasswordsEvent(
          oldPassword: '',
          newPassword: '',
          confirmPassword: '',
        ),
      ),
      expect: () => [
        const ChangePasswordState(
          oldPassword: '',
          newPassword: '',
          confirmPassword: '',
          isFormValid: false,
        ),
      ],
    );

    blocTest<ChangePasswordCubit, ChangePasswordState>(
      'case: old password only -> isFormValid == false',
      build: () => cubit,
      act: (cubit) =>
          cubit.doEvent(UpdatePasswordsEvent(oldPassword: tOldPassword)),
      expect: () => [
        const ChangePasswordState(
          oldPassword: tOldPassword,
          newPassword: '',
          confirmPassword: '',
          isFormValid: false,
        ),
      ],
    );

    blocTest<ChangePasswordCubit, ChangePasswordState>(
      'case: old + new password -> isFormValid == false',
      build: () => cubit,
      act: (cubit) => cubit.doEvent(
        UpdatePasswordsEvent(
          oldPassword: tOldPassword,
          newPassword: tValidNewPassword,
        ),
      ),
      expect: () => [
        const ChangePasswordState(
          oldPassword: tOldPassword,
          newPassword: tValidNewPassword,
          confirmPassword: '',
          isFormValid: false,
        ),
      ],
    );

    blocTest<ChangePasswordCubit, ChangePasswordState>(
      'case: confirm password missing -> isFormValid == false',
      build: () => cubit,
      act: (cubit) => cubit.doEvent(
        UpdatePasswordsEvent(
          oldPassword: tOldPassword,
          newPassword: tValidNewPassword,
          confirmPassword: '',
        ),
      ),
      expect: () => [
        const ChangePasswordState(
          oldPassword: tOldPassword,
          newPassword: tValidNewPassword,
          confirmPassword: '',
          isFormValid: false,
        ),
      ],
    );

    blocTest<ChangePasswordCubit, ChangePasswordState>(
      'case: new password equals old password -> isFormValid == false',
      build: () => cubit,
      act: (cubit) => cubit.doEvent(
        UpdatePasswordsEvent(
          oldPassword: tOldPassword,
          newPassword: tOldPassword,
          confirmPassword: tOldPassword,
        ),
      ),
      expect: () => [
        const ChangePasswordState(
          oldPassword: tOldPassword,
          newPassword: tOldPassword,
          confirmPassword: tOldPassword,
          isFormValid: false,
        ),
      ],
    );

    blocTest<ChangePasswordCubit, ChangePasswordState>(
      'case: confirm password does not match new password -> isFormValid == false',
      build: () => cubit,
      act: (cubit) => cubit.doEvent(
        UpdatePasswordsEvent(
          oldPassword: tOldPassword,
          newPassword: tValidNewPassword,
          confirmPassword: 'MismatchPassword@123',
        ),
      ),
      expect: () => [
        const ChangePasswordState(
          oldPassword: tOldPassword,
          newPassword: tValidNewPassword,
          confirmPassword: 'MismatchPassword@123',
          isFormValid: false,
        ),
      ],
    );

    blocTest<ChangePasswordCubit, ChangePasswordState>(
      'case: invalid new password format (weak password) -> isFormValid == false',
      build: () => cubit,
      act: (cubit) => cubit.doEvent(
        UpdatePasswordsEvent(
          oldPassword: tOldPassword,
          newPassword: 'short',
          confirmPassword: 'short',
        ),
      ),
      expect: () => [
        const ChangePasswordState(
          oldPassword: tOldPassword,
          newPassword: 'short',
          confirmPassword: 'short',
          isFormValid: false,
        ),
      ],
    );

    blocTest<ChangePasswordCubit, ChangePasswordState>(
      'case: valid old password, valid new password, confirm matches -> isFormValid == true',
      build: () => cubit,
      act: (cubit) => cubit.doEvent(
        UpdatePasswordsEvent(
          oldPassword: tOldPassword,
          newPassword: tValidNewPassword,
          confirmPassword: tValidNewPassword,
        ),
      ),
      expect: () => [
        const ChangePasswordState(
          oldPassword: tOldPassword,
          newPassword: tValidNewPassword,
          confirmPassword: tValidNewPassword,
          isFormValid: false,
        ),
        const ChangePasswordState(
          oldPassword: tOldPassword,
          newPassword: tValidNewPassword,
          confirmPassword: tValidNewPassword,
          isFormValid: true,
        ),
      ],
    );
  });

  group('Change Password Flow', () {
    blocTest<ChangePasswordCubit, ChangePasswordState>(
      'emits loading state and resets loading state back to idle on success',
      build: () {
        when(
          mockChangePasswordUseCase(
            password: tOldPassword,
            newPassword: tValidNewPassword,
          ),
        ).thenAnswer((_) async => const SuccessBaseResponse(tEntity));
        cubit.doEvent(
          UpdatePasswordsEvent(
            oldPassword: tOldPassword,
            newPassword: tValidNewPassword,
            confirmPassword: tValidNewPassword,
          ),
        );
        return cubit;
      },
      act: (cubit) => cubit.doEvent(ChangePasswordEvent()),
      expect: () => [
        const ChangePasswordState(
          oldPassword: tOldPassword,
          newPassword: tValidNewPassword,
          confirmPassword: tValidNewPassword,
          isFormValid: true,
          changePasswordState: BaseState(isLoading: true),
        ),
        const ChangePasswordState(
          oldPassword: tOldPassword,
          newPassword: tValidNewPassword,
          confirmPassword: tValidNewPassword,
          isFormValid: true,
          changePasswordState: BaseState(isLoading: false),
        ),
      ],
    );

    test(
      'emits ShowLoadingEvent, HideLoadingEvent, DisplaySuccessEvent, and NavigateEvent on success',
      () async {
        when(
          mockChangePasswordUseCase(
            password: tOldPassword,
            newPassword: tValidNewPassword,
          ),
        ).thenAnswer((_) async => const SuccessBaseResponse(tEntity));

        cubit.doEvent(
          UpdatePasswordsEvent(
            oldPassword: tOldPassword,
            newPassword: tValidNewPassword,
            confirmPassword: tValidNewPassword,
          ),
        );

        final expectation = expectLater(
          cubit.eventStream,
          emitsInOrder([
            isA<ShowLoadingEvent>(),
            isA<HideLoadingEvent>(),
            isA<DisplaySuccessEvent>(),
            isA<NavigateEvent>(),
          ]),
        );

        cubit.doEvent(ChangePasswordEvent());
        await expectation;

        verify(
          mockChangePasswordUseCase(
            password: tOldPassword,
            newPassword: tValidNewPassword,
          ),
        ).called(1);
        verifyNoMoreInteractions(mockChangePasswordUseCase);
      },
    );

    test('captures correct request parameters passed to use case', () async {
      when(
        mockChangePasswordUseCase(
          password: tOldPassword,
          newPassword: tValidNewPassword,
        ),
      ).thenAnswer((_) async => const SuccessBaseResponse(tEntity));

      cubit.doEvent(
        UpdatePasswordsEvent(
          oldPassword: tOldPassword,
          newPassword: tValidNewPassword,
          confirmPassword: tValidNewPassword,
        ),
      );

      final expectation = expectLater(
        cubit.eventStream,
        emitsThrough(isA<DisplaySuccessEvent>()),
      );

      cubit.doEvent(ChangePasswordEvent());
      await expectation;

      final captured = verify(
        mockChangePasswordUseCase(
          password: captureThat(equals(tOldPassword), named: 'password'),
          newPassword: captureThat(
            equals(tValidNewPassword),
            named: 'newPassword',
          ),
        ),
      ).captured;

      expect(captured[0], equals(tOldPassword));
      expect(captured[1], equals(tValidNewPassword));
    });

    blocTest<ChangePasswordCubit, ChangePasswordState>(
      'emits loading state and resets to idle when error occurs',
      build: () {
        when(
          mockChangePasswordUseCase(
            password: tOldPassword,
            newPassword: tValidNewPassword,
          ),
        ).thenAnswer(
          (_) async => const ErrorBaseResponse('Incorrect old password'),
        );
        cubit.doEvent(
          UpdatePasswordsEvent(
            oldPassword: tOldPassword,
            newPassword: tValidNewPassword,
            confirmPassword: tValidNewPassword,
          ),
        );
        return cubit;
      },
      act: (cubit) => cubit.doEvent(ChangePasswordEvent()),
      expect: () => [
        const ChangePasswordState(
          oldPassword: tOldPassword,
          newPassword: tValidNewPassword,
          confirmPassword: tValidNewPassword,
          isFormValid: true,
          changePasswordState: BaseState(isLoading: true),
        ),
        const ChangePasswordState(
          oldPassword: tOldPassword,
          newPassword: tValidNewPassword,
          confirmPassword: tValidNewPassword,
          isFormValid: true,
          changePasswordState: BaseState(isLoading: false),
        ),
      ],
    );

    test(
      'emits ShowLoadingEvent, HideLoadingEvent, and DisplayErrorEvent on failure',
      () async {
        when(
          mockChangePasswordUseCase(
            password: tOldPassword,
            newPassword: tValidNewPassword,
          ),
        ).thenAnswer(
          (_) async => const ErrorBaseResponse('Incorrect old password'),
        );

        cubit.doEvent(
          UpdatePasswordsEvent(
            oldPassword: tOldPassword,
            newPassword: tValidNewPassword,
            confirmPassword: tValidNewPassword,
          ),
        );

        final expectation = expectLater(
          cubit.eventStream,
          emitsInOrder([
            isA<ShowLoadingEvent>(),
            isA<HideLoadingEvent>(),
            isA<DisplayErrorEvent>(),
          ]),
        );

        cubit.doEvent(ChangePasswordEvent());
        await expectation;

        verify(
          mockChangePasswordUseCase(
            password: tOldPassword,
            newPassword: tValidNewPassword,
          ),
        ).called(1);
      },
    );
  });

  group('Edge Cases', () {
    test(
      'submitting with invalid form does NOT call ChangePasswordUseCase',
      () async {
        cubit.doEvent(
          UpdatePasswordsEvent(
            oldPassword: tOldPassword,
            newPassword: 'invalid_pass',
            confirmPassword: 'invalid_pass',
          ),
        );

        cubit.doEvent(ChangePasswordEvent());
        await Future<void>.delayed(const Duration(milliseconds: 10));

        verifyNever(
          mockChangePasswordUseCase(
            password: anyNamed('password'),
            newPassword: anyNamed('newPassword'),
          ),
        );
      },
    );

    test(
      'submitting multiple times while loading does NOT send duplicate requests',
      () async {
        when(
          mockChangePasswordUseCase(
            password: tOldPassword,
            newPassword: tValidNewPassword,
          ),
        ).thenAnswer((_) async {
          await Future<void>.delayed(const Duration(milliseconds: 100));
          return const SuccessBaseResponse(tEntity);
        });

        cubit.doEvent(
          UpdatePasswordsEvent(
            oldPassword: tOldPassword,
            newPassword: tValidNewPassword,
            confirmPassword: tValidNewPassword,
          ),
        );

        // First submit
        cubit.doEvent(ChangePasswordEvent());
        // Duplicate submit while loading
        cubit.doEvent(ChangePasswordEvent());

        await Future<void>.delayed(const Duration(milliseconds: 150));

        verify(
          mockChangePasswordUseCase(
            password: tOldPassword,
            newPassword: tValidNewPassword,
          ),
        ).called(1);
      },
    );
  });
}
