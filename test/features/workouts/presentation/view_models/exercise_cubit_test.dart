import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/features/workouts/domain/entities/difficulty_level_entity.dart';
import 'package:super_fitness/features/workouts/domain/entities/exercise_entity.dart';
import 'package:super_fitness/features/workouts/domain/use_cases/get_difficulty_levels_by_prime_mover_use_case.dart';
import 'package:super_fitness/features/workouts/domain/use_cases/get_exercises_by_muscle_difficulty_use_case.dart';
import 'package:super_fitness/features/workouts/presentation/view_models/exercise_view_model/exercise_cubit.dart';
import 'package:super_fitness/features/workouts/presentation/view_models/exercise_view_model/exercise_event.dart';

import 'exercise_cubit_test.mocks.dart';

@GenerateMocks([
  GetDifficultyLevelsByPrimeMoverUseCase,
  GetExercisesByMuscleDifficultyUseCase,
])
void main() {
  late ExerciseCubit cubit;
  late MockGetDifficultyLevelsByPrimeMoverUseCase
  mockGetDifficultyLevelsUseCase;
  late MockGetExercisesByMuscleDifficultyUseCase mockGetExercisesUseCase;

  setUp(() {
    provideDummy<BaseResponse<List<DifficultyLevelEntity>>>(
      const ErrorBaseResponse('dummy'),
    );
    provideDummy<BaseResponse<ExercisesEntity>>(
      const ErrorBaseResponse('dummy'),
    );

    mockGetDifficultyLevelsUseCase =
        MockGetDifficultyLevelsByPrimeMoverUseCase();
    mockGetExercisesUseCase = MockGetExercisesByMuscleDifficultyUseCase();
    cubit = ExerciseCubit(
      mockGetDifficultyLevelsUseCase,
      mockGetExercisesUseCase,
    );
  });

  group('ExerciseCubit Intent Tests', () {
    const tMuscleId = '69d982ef85f6bfa972bf2248';

    const tLevels = [
      DifficultyLevelEntity(id: '1', name: 'Beginner'),
      DifficultyLevelEntity(id: '2', name: 'Intermediate'),
    ];

    const tExercise1 = ExerciseEntity(
      id: 'ex1',
      exercise: 'Bench Press',
      difficultyLevel: 'Beginner',
      targetMuscleGroup: 'Chest',
      primeMoverMuscle: 'Pectoralis Major',
      primaryEquipment: 'Barbell',
      posture: 'Supine',
      bodyRegion: 'Upper Body',
      mechanics: 'Compound',
      laterality: 'Bilateral',
      primaryExerciseClassification: 'Push',
      shortYoutubeDemonstrationLink: 'http://short.demo',
      inDepthYoutubeExplanationLink: 'http://indepth.demo',
    );

    const tExercise2 = ExerciseEntity(
      id: 'ex2',
      exercise: 'Incline Dumbbell Press',
      difficultyLevel: 'Beginner',
      targetMuscleGroup: 'Chest',
      primeMoverMuscle: 'Pectoralis Major',
      primaryEquipment: 'Dumbbell',
      posture: 'Incline',
      bodyRegion: 'Upper Body',
      mechanics: 'Compound',
      laterality: 'Bilateral',
      primaryExerciseClassification: 'Push',
      shortYoutubeDemonstrationLink: 'http://short.demo2',
      inDepthYoutubeExplanationLink: 'http://indepth.demo2',
    );

    const tExercisesPage1 = ExercisesEntity(
      message: 'success',
      totalExercises: 20,
      totalPages: 2,
      currentPage: 1,
      exercises: [tExercise1],
    );

    const tExercisesPage2 = ExercisesEntity(
      message: 'success',
      totalExercises: 20,
      totalPages: 2,
      currentPage: 2,
      exercises: [tExercise2],
    );

    test(
      'InitializeExerciseScreen loads levels, auto-selects level 1, and loads page 1 exercises',
      () async {
        when(
          mockGetDifficultyLevelsUseCase(primeMoverMuscleId: tMuscleId),
        ).thenAnswer((_) async => const SuccessBaseResponse(tLevels));

        when(
          mockGetExercisesUseCase(
            primeMoverMuscleId: tMuscleId,
            difficultyLevelId: '1',
          ),
        ).thenAnswer((_) async => const SuccessBaseResponse(tExercisesPage1));

        cubit.doIntent(const InitializeExerciseScreen(tMuscleId));
        await Future.delayed(Duration.zero);

        expect(cubit.state.isLoadingLevels, false);
        expect(cubit.state.difficultyLevels, tLevels);
        expect(cubit.state.selectedDifficulty, tLevels.first);
        expect(cubit.state.isLoadingExercises, false);
        expect(cubit.state.exercises, [tExercise1]);
        expect(cubit.state.hasReachedMax, false);
        expect(cubit.state.activePrimeMoverMuscleId, tMuscleId);
      },
    );

    test(
      'ChangeDifficulty updates selected level and loads new exercises',
      () async {
        when(
          mockGetDifficultyLevelsUseCase(primeMoverMuscleId: tMuscleId),
        ).thenAnswer((_) async => const SuccessBaseResponse(tLevels));

        when(
          mockGetExercisesUseCase(
            primeMoverMuscleId: tMuscleId,
            difficultyLevelId: '1',
          ),
        ).thenAnswer((_) async => const SuccessBaseResponse(tExercisesPage1));

        when(
          mockGetExercisesUseCase(
            primeMoverMuscleId: tMuscleId,
            difficultyLevelId: '2',
          ),
        ).thenAnswer((_) async => const SuccessBaseResponse(tExercisesPage2));

        cubit.doIntent(const InitializeExerciseScreen(tMuscleId));
        await Future.delayed(Duration.zero);

        cubit.doIntent(ChangeDifficulty(tLevels[1]));
        await Future.delayed(Duration.zero);

        expect(cubit.state.selectedDifficulty, tLevels[1]);
        expect(cubit.state.exercises, [tExercise2]);
      },
    );

    test('LoadMoreExercises appends exercises to current list', () async {
      when(
        mockGetDifficultyLevelsUseCase(primeMoverMuscleId: tMuscleId),
      ).thenAnswer((_) async => const SuccessBaseResponse(tLevels));

      when(
        mockGetExercisesUseCase(
          primeMoverMuscleId: tMuscleId,
          difficultyLevelId: '1',
        ),
      ).thenAnswer((_) async => const SuccessBaseResponse(tExercisesPage1));

      cubit.doIntent(const InitializeExerciseScreen(tMuscleId));
      await Future.delayed(Duration.zero);

      when(
        mockGetExercisesUseCase(
          primeMoverMuscleId: tMuscleId,
          difficultyLevelId: '1',
        ),
      ).thenAnswer((_) async => const SuccessBaseResponse(tExercisesPage2));

      cubit.doIntent(const LoadMoreExercises());
      await Future.delayed(Duration.zero);

      expect(cubit.state.exercises, [tExercise1, tExercise2]);
      expect(cubit.state.currentPage, 2);
      expect(cubit.state.hasReachedMax, true);
    });

    test('RefreshExercises replaces exercise list from page 1', () async {
      when(
        mockGetDifficultyLevelsUseCase(primeMoverMuscleId: tMuscleId),
      ).thenAnswer((_) async => const SuccessBaseResponse(tLevels));

      when(
        mockGetExercisesUseCase(
          primeMoverMuscleId: tMuscleId,
          difficultyLevelId: '1',
        ),
      ).thenAnswer((_) async => const SuccessBaseResponse(tExercisesPage1));

      cubit.doIntent(const InitializeExerciseScreen(tMuscleId));
      await Future.delayed(Duration.zero);

      cubit.doIntent(const RefreshExercises());
      await Future.delayed(Duration.zero);

      expect(cubit.state.isRefreshing, false);
      expect(cubit.state.exercises, [tExercise1]);
    });
  });
}
