import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/config/base_state/base_state.dart';
import 'package:super_fitness/features/auth/domain/entities/forget_password_entity.dart';
import 'package:super_fitness/features/auth/domain/use_cases/forget_password_use_case.dart';
import 'package:super_fitness/features/auth/domain/use_cases/reset_password_use_case.dart';
import 'package:super_fitness/features/auth/domain/use_cases/verify_reset_code_use_case.dart';
import 'package:super_fitness/features/auth/presentation/view_model/forget_password_view_model/forgot_password_cubit.dart';
import 'package:super_fitness/features/auth/presentation/view_model/forget_password_view_model/forgot_password_events.dart';
import 'package:super_fitness/features/auth/presentation/view_model/forget_password_view_model/forgot_password_state.dart';

import 'forgot_password_cubit_test.mocks.dart';

@GenerateMocks([
  ForgetPasswordUseCase,
  VerifyResetCodeUseCase,
  ResetPasswordUseCase,
])
void main() {
  provideDummy<BaseResponse<ForgetPasswordEntity>>(
    ErrorBaseResponse<ForgetPasswordEntity>('dummy'),
  );
  late MockForgetPasswordUseCase forgotPasswordUseCase;
  late MockVerifyResetCodeUseCase verifyResetCodeUseCase;
  late MockResetPasswordUseCase resetPasswordUseCase;
  late ForgotPasswordCubit cubit;

  const entity = ForgetPasswordEntity(
    message: 'Success',
    info: '',
    status: '',
    statusMsg: '',
    token: '',
  );

  setUp(() {
    forgotPasswordUseCase = MockForgetPasswordUseCase();
    verifyResetCodeUseCase = MockVerifyResetCodeUseCase();
    resetPasswordUseCase = MockResetPasswordUseCase();

    cubit = ForgotPasswordCubit(
      forgotPasswordUseCase: forgotPasswordUseCase,
      verifyResetCodeUseCase: verifyResetCodeUseCase,
      resetPasswordUseCase: resetPasswordUseCase,
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('Update Steps and Info', () {
    blocTest<ForgotPasswordCubit, ForgotPasswordState>(
      'UpdateStepEvent emits new currentStep',
      build: () => cubit,
      act: (cubit) => cubit.doEvent(UpdateStepEvent(1)),
      expect: () => [
        const ForgotPasswordState(currentStep: 1),
      ],
    );

    blocTest<ForgotPasswordCubit, ForgotPasswordState>(
      'UpdateForgotPasswordInfoEvent updates info',
      build: () => cubit,
      act: (cubit) => cubit.doEvent(
        UpdateForgotPasswordInfoEvent(email: 'test@test.com', otpCode: '123456'),
      ),
      expect: () => [
        const ForgotPasswordState(email: 'test@test.com', otpCode: '123456'),
      ],
    );
  });

  group('Forgot Password Flow', () {
    blocTest<ForgotPasswordCubit, ForgotPasswordState>(
      'ForgotPasswordEvent success: emits loading, then steps to 1',
      build: () {
        when(forgotPasswordUseCase(email: 'test@test.com')).thenAnswer(
          (_) async => SuccessBaseResponse(entity),
        );
        cubit.emit(const ForgotPasswordState(email: 'test@test.com'));
        return cubit;
      },
      act: (cubit) => cubit.doEvent(ForgotPasswordEvent()),
      expect: () => [
        const ForgotPasswordState(
          email: 'test@test.com',
          forgotPasswordState: BaseState(isLoading: true),
        ),
        const ForgotPasswordState(
          email: 'test@test.com',
          forgotPasswordState: BaseState(isLoading: false),
        ),
        const ForgotPasswordState(
          email: 'test@test.com',
          currentStep: 1,
          forgotPasswordState: BaseState(isLoading: false),
        ),
        const ForgotPasswordState(
          email: 'test@test.com',
          currentStep: 1,
          resendTimer: 30,
          forgotPasswordState: BaseState(isLoading: false),
        ),
      ],
    );

    blocTest<ForgotPasswordCubit, ForgotPasswordState>(
      'VerifyResetCodeEvent success: emits loading, then steps to 2',
      build: () {
        when(verifyResetCodeUseCase(resetCode: '123456')).thenAnswer(
          (_) async => SuccessBaseResponse(entity),
        );
        cubit.emit(const ForgotPasswordState(otpCode: '123456'));
        return cubit;
      },
      act: (cubit) => cubit.doEvent(VerifyResetCodeEvent()),
      expect: () => [
        const ForgotPasswordState(
          otpCode: '123456',
          verifyResetCodeState: BaseState(isLoading: true),
        ),
        const ForgotPasswordState(
          otpCode: '123456',
          verifyResetCodeState: BaseState(isLoading: false),
        ),
        const ForgotPasswordState(
          otpCode: '123456',
          currentStep: 2,
          verifyResetCodeState: BaseState(isLoading: false),
        ),
      ],
    );

    blocTest<ForgotPasswordCubit, ForgotPasswordState>(
      'ResetPasswordEvent success: emits loading, then finished state',
      build: () {
        when(
          resetPasswordUseCase(email: 'test@test.com', newPassword: 'password'),
        ).thenAnswer((_) async => SuccessBaseResponse(entity));
        cubit.emit(
          const ForgotPasswordState(
            email: 'test@test.com',
            newPassword: 'password',
          ),
        );
        return cubit;
      },
      act: (cubit) => cubit.doEvent(ResetPasswordEvent()),
      expect: () => [
        const ForgotPasswordState(
          email: 'test@test.com',
          newPassword: 'password',
          resetPasswordState: BaseState(isLoading: true),
        ),
        const ForgotPasswordState(
          email: 'test@test.com',
          newPassword: 'password',
          resetPasswordState: BaseState(isLoading: false),
        ),
      ],
    );
  });
}
