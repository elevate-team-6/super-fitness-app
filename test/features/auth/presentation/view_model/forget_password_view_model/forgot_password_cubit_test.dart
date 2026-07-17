import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/config/base_state/base_state.dart';
import 'package:super_fitness/config/base_ui_event/base_ui_event.dart';
import 'package:super_fitness/core/utils/app_routes.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
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

  group('Forgot Password', () {
    blocTest<ForgotPasswordCubit, ForgotPasswordState>(
      'emits loading then success state',
      build: () {
        when(
          forgotPasswordUseCase(email: 'test@test.com'),
        ).thenAnswer((_) async => SuccessBaseResponse(entity));

        return cubit;
      },
      act: (cubit) =>
          cubit.doEvent(ForgotPasswordEvent(email: 'test@test.com')),
      expect: () => [
        const ForgotPasswordState(
          forgotPasswordState: BaseState(isLoading: true),
        ),
        const ForgotPasswordState(),
      ],
      verify: (_) {
        verify(forgotPasswordUseCase(email: 'test@test.com')).called(1);
      },
    );

    test('emits success ui events', () async {
      when(
        forgotPasswordUseCase(email: 'test@test.com'),
      ).thenAnswer((_) async => SuccessBaseResponse(entity));

      final events = <BaseUiEvent>[];

      final sub = cubit.eventStream.listen(events.add);

      cubit.doEvent(ForgotPasswordEvent(email: 'test@test.com'));

      await Future.delayed(Duration.zero);

      expect(events.length, 2);

      expect(events[0], isA<DisplaySuccessEvent>());
      expect(
        (events[0] as DisplaySuccessEvent).successMessage,
        AppStrings.verificationCodeSentToYourEmail,
      );

      expect(events[1], isA<NavigateEvent>());
      expect((events[1] as NavigateEvent).routeName, AppRoutes.verifyResetCode);

      await sub.cancel();
    });

    blocTest<ForgotPasswordCubit, ForgotPasswordState>(
      'emits error state',
      build: () {
        when(
          forgotPasswordUseCase(email: 'test@test.com'),
        ).thenAnswer((_) async => ErrorBaseResponse('Error'));

        return cubit;
      },
      act: (cubit) =>
          cubit.doEvent(ForgotPasswordEvent(email: 'test@test.com')),
      expect: () => [
        const ForgotPasswordState(
          forgotPasswordState: BaseState(isLoading: true),
        ),
        const ForgotPasswordState(),
      ],
    );
  });

  group('Verify Reset Code', () {
    blocTest<ForgotPasswordCubit, ForgotPasswordState>(
      'success',
      build: () {
        when(
          verifyResetCodeUseCase(resetCode: '123456'),
        ).thenAnswer((_) async => SuccessBaseResponse(entity));

        return cubit;
      },
      act: (cubit) => cubit.doEvent(
        VerifyResetCodeEvent(email: 'test@test.com', resetCode: '123456'),
      ),
      expect: () => [
        const ForgotPasswordState(
          verifyResetCodeState: BaseState(isLoading: true),
        ),
        const ForgotPasswordState(),
      ],
    );

    blocTest<ForgotPasswordCubit, ForgotPasswordState>(
      'error',
      build: () {
        when(
          verifyResetCodeUseCase(resetCode: '123456'),
        ).thenAnswer((_) async => ErrorBaseResponse('Error'));

        return cubit;
      },
      act: (cubit) => cubit.doEvent(
        VerifyResetCodeEvent(email: 'test@test.com', resetCode: '123456'),
      ),
      expect: () => [
        const ForgotPasswordState(
          verifyResetCodeState: BaseState(isLoading: true),
        ),
        const ForgotPasswordState(),
      ],
    );
  });

  group('Reset Password', () {
    blocTest<ForgotPasswordCubit, ForgotPasswordState>(
      'success',
      build: () {
        when(
          resetPasswordUseCase(email: 'test@test.com', newPassword: '12345678'),
        ).thenAnswer((_) async => SuccessBaseResponse(entity));

        return cubit;
      },
      act: (cubit) => cubit.doEvent(
        ResetPasswordEvent(email: 'test@test.com', newPassword: '12345678'),
      ),
      expect: () => [
        ForgotPasswordState(resetPasswordState: BaseState(isLoading: true)),
        const ForgotPasswordState(),
      ],
    );

    blocTest<ForgotPasswordCubit, ForgotPasswordState>(
      'error',
      build: () {
        when(
          resetPasswordUseCase(email: 'test@test.com', newPassword: '12345678'),
        ).thenAnswer((_) async => ErrorBaseResponse('Error'));

        return cubit;
      },
      act: (cubit) => cubit.doEvent(
        ResetPasswordEvent(email: 'test@test.com', newPassword: '12345678'),
      ),
      expect: () => [
        const ForgotPasswordState(
          resetPasswordState: BaseState(isLoading: true),
        ),
        const ForgotPasswordState(),
      ],
    );
  });
}
