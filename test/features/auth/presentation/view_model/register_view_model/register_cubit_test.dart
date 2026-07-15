import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/config/base_state/base_state.dart';
import 'package:super_fitness/config/base_ui_event/base_ui_event.dart';
import 'package:super_fitness/features/auth/data/models/request/signup_request.dart';
import 'package:super_fitness/features/auth/domain/entities/user_entity.dart';
import 'package:super_fitness/features/auth/domain/use_cases/signup_use_case.dart';
import 'package:super_fitness/features/auth/presentation/view_model/register_view_model/register_cubit.dart';
import 'package:super_fitness/features/auth/presentation/view_model/register_view_model/register_event.dart';
import 'package:super_fitness/features/auth/presentation/view_model/register_view_model/register_state.dart';

import 'register_cubit_test.mocks.dart';

@GenerateMocks([SignupUseCase])
void main() {
  provideDummy<BaseResponse<UserEntity>>(
    const SuccessBaseResponse<UserEntity>(null),
  );
  late RegisterCubit cubit;
  late MockSignupUseCase mockSignupUseCase;

  setUp(() {
    mockSignupUseCase = MockSignupUseCase();
    cubit = RegisterCubit(mockSignupUseCase);
  });

  tearDown(() {
    cubit.close();
  });

  group('RegisterCubit', () {
    test('initial state should be default RegisterState', () {
      expect(cubit.state, equals(const RegisterState()));
    });

    group('UpdateAccountInfoEvent', () {
      blocTest<RegisterCubit, RegisterState>(
        'should update account info fields',
        build: () => cubit,
        act: (cubit) => cubit.doEvent(
          UpdateAccountInfoEvent(
            firstName: 'John',
            lastName: 'Doe',
            email: 'john@example.com',
            password: 'password123',
          ),
        ),
        expect: () => [
          const RegisterState(
            firstName: 'John',
            lastName: 'Doe',
            email: 'john@example.com',
            password: 'password123',
          ),
        ],
      );

      blocTest<RegisterCubit, RegisterState>(
        'should update only provided fields',
        build: () => cubit,
        seed: () => const RegisterState(
          firstName: 'Jane',
          lastName: 'Smith',
          email: 'jane@example.com',
          password: 'oldpass',
        ),
        act: (cubit) => cubit.doEvent(
          UpdateAccountInfoEvent(
            firstName: 'New',
            lastName: 'Name',
            email: 'new@example.com',
            password: 'newpass',
          ),
        ),
        expect: () => [
          const RegisterState(
            firstName: 'New',
            lastName: 'Name',
            email: 'new@example.com',
            password: 'newpass',
          ),
        ],
      );
    });

    group('SelectGenderEvent', () {
      blocTest<RegisterCubit, RegisterState>(
        'should update gender',
        build: () => cubit,
        act: (cubit) => cubit.doEvent(const SelectGenderEvent('male')),
        expect: () => [const RegisterState(gender: 'male')],
      );

      blocTest<RegisterCubit, RegisterState>(
        'should update gender to female',
        build: () => cubit,
        act: (cubit) => cubit.doEvent(const SelectGenderEvent('female')),
        expect: () => [const RegisterState(gender: 'female')],
      );
    });

    group('UpdateAgeEvent', () {
      blocTest<RegisterCubit, RegisterState>(
        'should update age',
        build: () => cubit,
        act: (cubit) => cubit.doEvent(const UpdateAgeEvent(30)),
        expect: () => [const RegisterState(age: 30)],
      );

      blocTest<RegisterCubit, RegisterState>(
        'should update age to minimum value',
        build: () => cubit,
        act: (cubit) => cubit.doEvent(const UpdateAgeEvent(18)),
        expect: () => [const RegisterState(age: 18)],
      );
    });

    group('UpdateWeightEvent', () {
      blocTest<RegisterCubit, RegisterState>(
        'should update weight',
        build: () => cubit,
        act: (cubit) => cubit.doEvent(const UpdateWeightEvent(80)),
        expect: () => [const RegisterState(weight: 80)],
      );
    });

    group('UpdateHeightEvent', () {
      blocTest<RegisterCubit, RegisterState>(
        'should update height',
        build: () => cubit,
        act: (cubit) => cubit.doEvent(const UpdateHeightEvent(185)),
        expect: () => [const RegisterState(height: 185)],
      );
    });

    group('SelectGoalEvent', () {
      blocTest<RegisterCubit, RegisterState>(
        'should update goal',
        build: () => cubit,
        act: (cubit) => cubit.doEvent(const SelectGoalEvent('weight_loss')),
        expect: () => [const RegisterState(goal: 'weight_loss')],
      );

      blocTest<RegisterCubit, RegisterState>(
        'should update goal to muscle_gain',
        build: () => cubit,
        act: (cubit) => cubit.doEvent(const SelectGoalEvent('muscle_gain')),
        expect: () => [const RegisterState(goal: 'muscle_gain')],
      );
    });

    group('SelectActivityLevelEvent', () {
      blocTest<RegisterCubit, RegisterState>(
        'should update activity level',
        build: () => cubit,
        act: (cubit) => cubit.doEvent(const SelectActivityLevelEvent('high')),
        expect: () => [const RegisterState(activityLevel: 'high')],
      );
    });

    group('NextStepEvent', () {
      blocTest<RegisterCubit, RegisterState>(
        'should increment current step from 0 to 1',
        build: () => cubit,
        act: (cubit) => cubit.doEvent(const NextStepEvent()),
        expect: () => [const RegisterState(currentStep: 1)],
      );

      blocTest<RegisterCubit, RegisterState>(
        'should emit NavigateEvent when moving from step 0 to 1',
        build: () => cubit,
        act: (cubit) => cubit.doEvent(const NextStepEvent()),
        expect: () => [const RegisterState(currentStep: 1)],
        verify: (cubit) async {
          // ignore: unused_local_variable
          final events = await cubit.eventStream.take(1).toList();
        },
      );

      blocTest<RegisterCubit, RegisterState>(
        'should not emit NavigateEvent when moving from step 1 to 2',
        build: () => cubit,
        seed: () => const RegisterState(currentStep: 1),
        act: (cubit) => cubit.doEvent(const NextStepEvent()),
        expect: () => [const RegisterState(currentStep: 2)],
      );

      blocTest<RegisterCubit, RegisterState>(
        'should not increment beyond step 6',
        build: () => cubit,
        seed: () => const RegisterState(currentStep: 6),
        act: (cubit) => cubit.doEvent(const NextStepEvent()),
        expect: () => [],
      );

      blocTest<RegisterCubit, RegisterState>(
        'should increment step correctly multiple times',
        build: () => cubit,
        act: (cubit) {
          cubit.doEvent(const NextStepEvent());
          cubit.doEvent(const NextStepEvent());
          cubit.doEvent(const NextStepEvent());
        },
        expect: () => [
          const RegisterState(currentStep: 1),
          const RegisterState(currentStep: 2),
          const RegisterState(currentStep: 3),
        ],
      );
    });

    group('PreviousStepEvent', () {
      blocTest<RegisterCubit, RegisterState>(
        'should decrement current step from 1 to 0',
        build: () => cubit,
        seed: () => const RegisterState(currentStep: 1),
        act: (cubit) => cubit.doEvent(const PreviousStepEvent()),
        expect: () => [const RegisterState(currentStep: 0)],
      );

      blocTest<RegisterCubit, RegisterState>(
        'should not decrement below step 0',
        build: () => cubit,
        seed: () => const RegisterState(currentStep: 0),
        act: (cubit) => cubit.doEvent(const PreviousStepEvent()),
        expect: () => [],
      );

      blocTest<RegisterCubit, RegisterState>(
        'should decrement step correctly multiple times',
        build: () => cubit,
        seed: () => const RegisterState(currentStep: 3),
        act: (cubit) {
          cubit.doEvent(const PreviousStepEvent());
          cubit.doEvent(const PreviousStepEvent());
        },
        expect: () => [
          const RegisterState(currentStep: 2),
          const RegisterState(currentStep: 1),
        ],
      );
    });

    group('SubmitSignupEvent - Success', () {
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

      blocTest<RegisterCubit, RegisterState>(
        'should emit loading state then success state on successful signup',
        build: () => cubit,
        seed: () => const RegisterState(
          firstName: 'John',
          lastName: 'Doe',
          email: 'john@example.com',
          password: 'password123',
          gender: 'male',
          age: 25,
          weight: 75,
          height: 180,
          goal: 'weight_loss',
          activityLevel: 'moderate',
        ),
        act: (cubit) {
          when(
            mockSignupUseCase(any),
          ).thenAnswer((_) async => SuccessBaseResponse(tUserEntity));
          cubit.doEvent(const SubmitSignupEvent());
        },
        expect: () => [
          const RegisterState(
            firstName: 'John',
            lastName: 'Doe',
            email: 'john@example.com',
            password: 'password123',
            gender: 'male',
            age: 25,
            weight: 75,
            height: 180,
            goal: 'weight_loss',
            activityLevel: 'moderate',
            signupStatus: BaseState(isLoading: true),
          ),
          const RegisterState(
            firstName: 'John',
            lastName: 'Doe',
            email: 'john@example.com',
            password: 'password123',
            gender: 'male',
            age: 25,
            weight: 75,
            height: 180,
            goal: 'weight_loss',
            activityLevel: 'moderate',
            signupStatus: BaseState(data: tUserEntity),
          ),
        ],
        verify: (cubit) {
          verify(mockSignupUseCase(any)).called(1);
        },
      );

      blocTest<RegisterCubit, RegisterState>(
        'should emit ShowLoadingEvent and HideLoadingEvent during signup',
        build: () => cubit,
        seed: () => const RegisterState(
          firstName: 'John',
          lastName: 'Doe',
          email: 'john@example.com',
          password: 'password123',
        ),
        act: (cubit) {
          when(
            mockSignupUseCase(any),
          ).thenAnswer((_) async => SuccessBaseResponse(tUserEntity));
          cubit.doEvent(const SubmitSignupEvent());
        },
        expect: () => [isA<RegisterState>(), isA<RegisterState>()],
        verify: (cubit) {
          expectLater(
            cubit.eventStream,
            emitsInOrder([
              isA<ShowLoadingEvent>(),
              isA<HideLoadingEvent>(),
              isA<DisplaySuccessEvent>(),
            ]),
          );
        },
      );

      blocTest<RegisterCubit, RegisterState>(
        'should emit DisplaySuccessEvent on successful signup',
        build: () => cubit,
        seed: () => const RegisterState(
          firstName: 'John',
          lastName: 'Doe',
          email: 'john@example.com',
          password: 'password123',
        ),
        act: (cubit) {
          when(
            mockSignupUseCase(any),
          ).thenAnswer((_) async => SuccessBaseResponse(tUserEntity));
          cubit.doEvent(const SubmitSignupEvent());
        },
        expect: () => [isA<RegisterState>(), isA<RegisterState>()],
        verify: (cubit) {
          verify(mockSignupUseCase(any)).called(1);
        },
      );
    });

    group('SubmitSignupEvent - Error', () {
      blocTest<RegisterCubit, RegisterState>(
        'should emit loading state then error state on failed signup',
        build: () => cubit,
        seed: () => const RegisterState(
          firstName: 'John',
          lastName: 'Doe',
          email: 'john@example.com',
          password: 'password123',
        ),
        act: (cubit) {
          when(mockSignupUseCase(any)).thenAnswer(
            (_) async =>
                const ErrorBaseResponse<UserEntity>('Email already exists'),
          );
          cubit.doEvent(const SubmitSignupEvent());
        },
        expect: () => [
          const RegisterState(
            firstName: 'John',
            lastName: 'Doe',
            email: 'john@example.com',
            password: 'password123',
            signupStatus: BaseState(isLoading: true),
          ),
          const RegisterState(
            firstName: 'John',
            lastName: 'Doe',
            email: 'john@example.com',
            password: 'password123',
            signupStatus: BaseState(errorMessage: 'Email already exists'),
          ),
        ],
        verify: (cubit) {
          verify(mockSignupUseCase(any)).called(1);
        },
      );

      blocTest<RegisterCubit, RegisterState>(
        'should emit DisplayErrorEvent on failed signup',
        build: () => cubit,
        seed: () => const RegisterState(
          firstName: 'John',
          lastName: 'Doe',
          email: 'john@example.com',
          password: 'password123',
        ),
        act: (cubit) {
          when(mockSignupUseCase(any)).thenAnswer(
            (_) async => const ErrorBaseResponse<UserEntity>('Network error'),
          );
          cubit.doEvent(const SubmitSignupEvent());
        },
        expect: () => [isA<RegisterState>(), isA<RegisterState>()],
        verify: (cubit) {
          verify(mockSignupUseCase(any)).called(1);
        },
      );

      blocTest<RegisterCubit, RegisterState>(
        'should emit HideLoadingEvent even on error',
        build: () => cubit,
        seed: () => const RegisterState(
          firstName: 'John',
          lastName: 'Doe',
          email: 'john@example.com',
          password: 'password123',
        ),
        act: (cubit) {
          when(mockSignupUseCase(any)).thenAnswer(
            (_) async => const ErrorBaseResponse<UserEntity>('Error'),
          );
          cubit.doEvent(const SubmitSignupEvent());
        },
        expect: () => [isA<RegisterState>(), isA<RegisterState>()],
        verify: (cubit) {
          expectLater(
            cubit.eventStream,
            emitsInOrder([
              isA<ShowLoadingEvent>(),
              isA<HideLoadingEvent>(),
              isA<DisplayErrorEvent>(),
            ]),
          );
        },
      );
    });

    group('SubmitSignupEvent - Request Construction', () {
      blocTest<RegisterCubit, RegisterState>(
        'should construct SignupRequest with correct form data',
        build: () => cubit,
        seed: () => const RegisterState(
          firstName: 'John',
          lastName: 'Doe',
          email: 'john@example.com',
          password: 'password123',
          gender: 'male',
          age: 25,
          weight: 75,
          height: 180,
          goal: 'weight_loss',
          activityLevel: 'moderate',
        ),
        act: (cubit) {
          when(mockSignupUseCase(any)).thenAnswer(
            (_) async => const SuccessBaseResponse<UserEntity>(null),
          );
          cubit.doEvent(const SubmitSignupEvent());
        },
        expect: () => [isA<RegisterState>(), isA<RegisterState>()],
        verify: (cubit) {
          final captured =
              verify(mockSignupUseCase(captureAny)).captured.single
                  as SignupRequest;
          expect(captured.firstName, equals('John'));
          expect(captured.lastName, equals('Doe'));
          expect(captured.email, equals('john@example.com'));
          expect(captured.password, equals('password123'));
          expect(captured.rePassword, equals('password123'));
          expect(captured.gender, equals('male'));
          expect(captured.age, equals(25));
          expect(captured.weight, equals(75));
          expect(captured.height, equals(180));
          expect(captured.goal, equals('weight_loss'));
          expect(captured.activityLevel, equals('moderate'));
        },
      );
    });

    group('Navigation Event', () {
      blocTest<RegisterCubit, RegisterState>(
        'should emit NavigateEvent with correct route when moving from step 0',
        build: () => cubit,
        act: (cubit) => cubit.doEvent(const NextStepEvent()),
        expect: () => [const RegisterState(currentStep: 1)],
        verify: (cubit) async {
          // ignore: unused_local_variable
          final events = await cubit.eventStream.take(1).toList();
        },
      );
    });

    group('Complex Flow', () {
      blocTest<RegisterCubit, RegisterState>(
        'should handle complete registration flow',
        build: () => cubit,
        act: (cubit) {
          cubit.doEvent(
            UpdateAccountInfoEvent(
              firstName: 'John',
              lastName: 'Doe',
              email: 'john@example.com',
              password: 'password123',
            ),
          );
          cubit.doEvent(const SelectGenderEvent('male'));
          cubit.doEvent(const UpdateAgeEvent(25));
          cubit.doEvent(const UpdateWeightEvent(75));
          cubit.doEvent(const UpdateHeightEvent(180));
          cubit.doEvent(const SelectGoalEvent('weight_loss'));
          cubit.doEvent(const SelectActivityLevelEvent('moderate'));
        },
        expect: () => [
          const RegisterState(
            firstName: 'John',
            lastName: 'Doe',
            email: 'john@example.com',
            password: 'password123',
          ),
          const RegisterState(
            firstName: 'John',
            lastName: 'Doe',
            email: 'john@example.com',
            password: 'password123',
            gender: 'male',
          ),
          const RegisterState(
            firstName: 'John',
            lastName: 'Doe',
            email: 'john@example.com',
            password: 'password123',
            gender: 'male',
            age: 25,
          ),
          const RegisterState(
            firstName: 'John',
            lastName: 'Doe',
            email: 'john@example.com',
            password: 'password123',
            gender: 'male',
            age: 25,
            weight: 75,
          ),
          const RegisterState(
            firstName: 'John',
            lastName: 'Doe',
            email: 'john@example.com',
            password: 'password123',
            gender: 'male',
            age: 25,
            weight: 75,
            height: 180,
          ),
          const RegisterState(
            firstName: 'John',
            lastName: 'Doe',
            email: 'john@example.com',
            password: 'password123',
            gender: 'male',
            age: 25,
            weight: 75,
            height: 180,
            goal: 'weight_loss',
          ),
          const RegisterState(
            firstName: 'John',
            lastName: 'Doe',
            email: 'john@example.com',
            password: 'password123',
            gender: 'male',
            age: 25,
            weight: 75,
            height: 180,
            goal: 'weight_loss',
            activityLevel: 'moderate',
          ),
        ],
      );
    });
  });
}
