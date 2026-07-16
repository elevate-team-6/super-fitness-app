import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/config/base_ui_event/base_ui_event.dart';
import 'package:super_fitness/features/auth/data/models/request/sign_in_request_model.dart';
import 'package:super_fitness/features/auth/domain/entities/sign_in_entity.dart';
import 'package:super_fitness/features/auth/domain/entities/user_entity.dart';
import 'package:super_fitness/features/auth/domain/use_cases/sign_in_use_case.dart';
import 'package:super_fitness/features/auth/presentation/view_model/login_view_model/login_cubit.dart';
import 'package:super_fitness/features/auth/presentation/view_model/login_view_model/login_event.dart';
import 'package:super_fitness/features/auth/presentation/view_model/login_view_model/login_state.dart';

import 'login_cubit_test.mocks.dart';

@GenerateMocks([SignInUseCase])
void main() {
  late MockSignInUseCase mockUseCase;
  late LoginCubit cubit;

  const request = SignInRequestModel(
    email: 'test@test.com',
    password: 'Ahmed@123',
  );

  const fakeEntity = SignInEntity(
    message: 'success',
    token: 'fake_token',
    user: UserEntity(
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
    ),
  );

  setUp(() {
    mockUseCase = MockSignInUseCase();
    cubit = LoginCubit(mockUseCase);

    provideDummy<BaseResponse<SignInEntity>>(ErrorBaseResponse('dummy'));
  });

  tearDown(() async {
    if (!cubit.isClosed) await cubit.close();
  });

  group('TogglePasswordVisibilityEvent', () {
    blocTest<LoginCubit, LoginState>(
      'toggles obscurePassword from true to false',
      build: () => cubit,
      act: (cubit) => cubit.doIntent(const TogglePasswordVisibilityEvent()),
      expect: () => [
        isA<LoginState>().having(
          (s) => s.obscurePassword,
          'obscurePassword',
          false,
        ),
      ],
    );

    blocTest<LoginCubit, LoginState>(
      'toggles back to obscured on a second tap',
      build: () => cubit,
      act: (cubit) => cubit
        ..doIntent(const TogglePasswordVisibilityEvent())
        ..doIntent(const TogglePasswordVisibilityEvent()),
      expect: () => [
        isA<LoginState>().having(
          (s) => s.obscurePassword,
          'obscurePassword',
          false,
        ),
        isA<LoginState>().having(
          (s) => s.obscurePassword,
          'obscurePassword',
          true,
        ),
      ],
    );
  });

  group('LoginEvent', () {
    test('passes the request straight to the use case', () async {
      when(
        mockUseCase(request),
      ).thenAnswer((_) async => SuccessBaseResponse(fakeEntity));

      final expectation = expectLater(
        cubit.eventStream,
        emitsThrough(isA<NavigateEvent>()),
      );

      cubit.doIntent(const LoginEvent(request));
      await expectation;

      verify(mockUseCase(request)).called(1);
      verifyNoMoreInteractions(mockUseCase);
    });

    test(
      'emits loading then success side effects on valid credentials',
      () async {
        when(
          mockUseCase(request),
        ).thenAnswer((_) async => SuccessBaseResponse(fakeEntity));

        final expectation = expectLater(
          cubit.eventStream,
          emitsInOrder([
            isA<ShowLoadingEvent>(),
            isA<HideLoadingEvent>(),
            isA<DisplaySuccessEvent>(),
            isA<NavigateEvent>(),
          ]),
        );

        cubit.doIntent(const LoginEvent(request));
        await expectation;
      },
    );

    test(
      'emits loading then failure side effects on wrong credentials',
      () async {
        when(
          mockUseCase(request),
        ).thenAnswer((_) async => ErrorBaseResponse('invalid credentials'));

        final expectation = expectLater(
          cubit.eventStream,
          emitsInOrder([
            isA<ShowLoadingEvent>(),
            isA<HideLoadingEvent>(),
            isA<DisplayErrorEvent>().having(
              (e) => e.errorMessage,
              'errorMessage',
              'invalid credentials',
            ),
          ]),
        );

        cubit.doIntent(const LoginEvent(request));
        await expectation;
      },
    );

    test('never navigates when sign-in fails', () async {
      when(
        mockUseCase(request),
      ).thenAnswer((_) async => ErrorBaseResponse('invalid credentials'));

      // Collected rather than matched in order, so a stray NavigateEvent after
      // the error would still be caught.
      final events = <BaseUiEvent>[];
      final subscription = cubit.eventStream.listen(events.add);
      addTearDown(subscription.cancel);

      cubit.doIntent(const LoginEvent(request));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(events.whereType<NavigateEvent>(), isEmpty);
      expect(events.whereType<DisplayErrorEvent>(), hasLength(1));
    });
  });
}
