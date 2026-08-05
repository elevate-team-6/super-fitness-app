import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/config/base_state/base_state.dart';
import 'package:super_fitness/features/workouts/domain/entities/muscle_entity.dart';
import 'package:super_fitness/features/workouts/domain/entities/muscle_group_entity.dart';
import 'package:super_fitness/features/workouts/domain/use_cases/get_muscle_groups_use_case.dart';
import 'package:super_fitness/features/workouts/domain/use_cases/get_muscles_by_group_id_use_case.dart';
import 'package:super_fitness/features/workouts/presentation/view_models/workouts_view_model/workouts_cubit.dart';
import 'package:super_fitness/features/workouts/presentation/view_models/workouts_view_model/workouts_events.dart';
import 'package:super_fitness/features/workouts/presentation/view_models/workouts_view_model/workouts_state.dart';

import 'workouts_cubit_test.mocks.dart';

@GenerateMocks([GetMuscleGroupsUseCase, GetMusclesByGroupIdUseCase])
void main() {
  late MockGetMuscleGroupsUseCase mockGetMuscleGroupsUseCase;
  late MockGetMusclesByGroupIdUseCase mockGetMusclesByGroupIdUseCase;
  late WorkoutsCubit cubit;

  const initialState = WorkoutsState(
    muscleGroupsState: BaseState<List<MuscleGroupEntity>>(isLoading: true),
    musclesState: BaseState<List<MuscleEntity>>(isLoading: true),
  );

  setUp(() {
    mockGetMuscleGroupsUseCase = MockGetMuscleGroupsUseCase();
    mockGetMusclesByGroupIdUseCase = MockGetMusclesByGroupIdUseCase();
    cubit = WorkoutsCubit(
      getMuscleGroupsUseCase: mockGetMuscleGroupsUseCase,
      getMusclesByGroupIdUseCase: mockGetMusclesByGroupIdUseCase,
    );

    provideDummy<BaseResponse<List<MuscleGroupEntity>>>(
      const ErrorBaseResponse('dummy'),
    );
    provideDummy<BaseResponse<List<MuscleEntity>>>(
      const ErrorBaseResponse('dummy'),
    );
  });

  tearDown(() {
    cubit.close();
  });

  const tMuscleGroup = MuscleGroupEntity(id: '1', name: 'Abs');
  const tMuscleGroups = [tMuscleGroup];
  const tMuscle = MuscleEntity(id: 'm1', name: 'Crunch', image: 'img.png');
  const tMuscles = [tMuscle];

  group('GetMuscleGroups', () {
    blocTest<WorkoutsCubit, WorkoutsState>(
      'emits [success] and calls getMusclesByGroupId when muscle groups are fetched successfully',
      build: () {
        when(
          mockGetMuscleGroupsUseCase(),
        ).thenAnswer((_) async => const SuccessBaseResponse(tMuscleGroups));
        when(
          mockGetMusclesByGroupIdUseCase(id: '1'),
        ).thenAnswer((_) async => const SuccessBaseResponse(tMuscles));
        return cubit;
      },
      act: (cubit) => cubit.doEvent(GetMuscleGroupsEvent()),
      expect: () => [
        initialState.copyWith(
          muscleGroupsState: const BaseState<List<MuscleGroupEntity>>(
            isLoading: true,
          ),
        ),
        initialState.copyWith(
          muscleGroupsState: const BaseState<List<MuscleGroupEntity>>(
            data: tMuscleGroups,
          ),
        ),
        initialState.copyWith(
          muscleGroupsState: const BaseState<List<MuscleGroupEntity>>(
            data: tMuscleGroups,
          ),
          musclesState: const BaseState<List<MuscleEntity>>(isLoading: true),
          selectedMuscleGroupId: '1',
        ),
        initialState.copyWith(
          muscleGroupsState: const BaseState<List<MuscleGroupEntity>>(
            data: tMuscleGroups,
          ),
          musclesState: const BaseState<List<MuscleEntity>>(data: tMuscles),
          selectedMuscleGroupId: '1',
        ),
      ],
    );

    blocTest<WorkoutsCubit, WorkoutsState>(
      'emits [success] with empty list when no muscle groups are found',
      build: () {
        when(
          mockGetMuscleGroupsUseCase(),
        ).thenAnswer((_) async => const SuccessBaseResponse([]));
        return cubit;
      },
      act: (cubit) => cubit.doEvent(GetMuscleGroupsEvent()),
      expect: () => [
        initialState.copyWith(
          muscleGroupsState: const BaseState<List<MuscleGroupEntity>>(
            isLoading: true,
          ),
        ),
        initialState.copyWith(
          muscleGroupsState: const BaseState<List<MuscleGroupEntity>>(data: []),
        ),
      ],
    );

    blocTest<WorkoutsCubit, WorkoutsState>(
      'emits [error] when fetching muscle groups fails',
      build: () {
        when(
          mockGetMuscleGroupsUseCase(),
        ).thenAnswer((_) async => const ErrorBaseResponse('server error'));
        return cubit;
      },
      act: (cubit) => cubit.doEvent(GetMuscleGroupsEvent()),
      expect: () => [
        initialState.copyWith(
          muscleGroupsState: const BaseState<List<MuscleGroupEntity>>(
            isLoading: true,
          ),
        ),
        initialState.copyWith(
          muscleGroupsState: const BaseState<List<MuscleGroupEntity>>(
            errorMessage: 'server error',
          ),
        ),
      ],
    );
    group('GetMusclesByGroupId', () {
      blocTest<WorkoutsCubit, WorkoutsState>(
        'emits [loading, success] when muscles are fetched successfully',
        build: () {
          when(
            mockGetMusclesByGroupIdUseCase(id: '1'),
          ).thenAnswer((_) async => const SuccessBaseResponse(tMuscles));
          return cubit;
        },
        act: (cubit) => cubit.doEvent(GetMusclesByGroupIdEvent('1')),
        expect: () => [
          initialState.copyWith(
            musclesState: const BaseState<List<MuscleEntity>>(isLoading: true),
            selectedMuscleGroupId: '1',
          ),
          initialState.copyWith(
            musclesState: const BaseState<List<MuscleEntity>>(data: tMuscles),
            selectedMuscleGroupId: '1',
          ),
        ],
      );

      blocTest<WorkoutsCubit, WorkoutsState>(
        'emits [loading, error] when fetching muscles fails',
        build: () {
          when(
            mockGetMusclesByGroupIdUseCase(id: '1'),
          ).thenAnswer((_) async => const ErrorBaseResponse('not found'));
          return cubit;
        },
        act: (cubit) => cubit.doEvent(GetMusclesByGroupIdEvent('1')),
        expect: () => [
          initialState.copyWith(
            musclesState: const BaseState<List<MuscleEntity>>(isLoading: true),
            selectedMuscleGroupId: '1',
          ),
          initialState.copyWith(
            musclesState: const BaseState<List<MuscleEntity>>(
              errorMessage: 'not found',
            ),
            selectedMuscleGroupId: '1',
          ),
        ],
      );
    });
  });
}
