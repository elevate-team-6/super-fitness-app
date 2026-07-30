import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/config/cache/secure_cache_helper.dart';
import 'package:super_fitness/core/data/local/sqlite/catalog_local_data_source.dart';
import 'package:super_fitness/core/utils/app_keys.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/features/home/data/models/response/details_food_model.dart';
import 'package:super_fitness/features/home/data/models/response/exercise_response.dart';
import 'package:super_fitness/features/home/data/models/response/level_response.dart';
import 'package:super_fitness/features/home/data/models/response/meal_category_response.dart';
import 'package:super_fitness/features/home/data/models/response/meal_model.dart';
import 'package:super_fitness/features/home/data/models/response/muscle_response.dart';
import 'package:super_fitness/features/home/data/repo/home_repo_impl.dart';
import 'package:super_fitness/features/home/domain/entities/details_food_entity.dart';
import 'package:super_fitness/features/workouts/domain/entities/exercise_entity.dart';
import 'package:super_fitness/features/home/domain/entities/home_user_entity.dart';
import 'package:super_fitness/features/home/domain/entities/level_entity.dart';
import 'package:super_fitness/features/home/domain/entities/meal_category_entity.dart';
import 'package:super_fitness/features/home/domain/entities/meal_entity.dart';
import 'package:super_fitness/features/home/domain/entities/muscle_entity.dart';

import 'home_repo_impl_test.mocks.dart';

@GenerateMocks([CatalogLocalDataSource, SecureCacheHelper])
void main() {
  late HomeRepoImpl repo;
  late MockCatalogLocalDataSource mockLocalDataSource;
  late MockSecureCacheHelper mockCacheHelper;

  setUp(() {
    mockLocalDataSource = MockCatalogLocalDataSource();
    mockCacheHelper = MockSecureCacheHelper();
    repo = HomeRepoImpl(mockLocalDataSource, mockCacheHelper);
  });

  group('getCachedUserData', () {
    test(
      'should return SuccessBaseResponse with UserEntity when cache has data',
      () async {
        // arrange
        when(
          mockCacheHelper.readData(key: AppKeys.userNameKey),
        ).thenAnswer((_) async => 'Test User');
        when(
          mockCacheHelper.readData(key: AppKeys.userImageKey),
        ).thenAnswer((_) async => 'image_url');

        // act
        final result = await repo.getCachedUserData();

        // assert
        expect(result, isA<SuccessBaseResponse<HomeUserEntity>>());
        final data = (result as SuccessBaseResponse<HomeUserEntity>).data;
        expect(data?.name, 'Test User');
        expect(data?.image, 'image_url');
      },
    );
  });

  group('getRandomExercises', () {
    final tExercises = [const ExerciseModel(id: '1', exercise: 'Exercise 1')];

    test(
      'should return SuccessBaseResponse with List<ExerciseEntity> when local call is successful',
      () async {
        // arrange
        when(
          mockLocalDataSource.getRandomExercises(
            primeMoverMuscleId: anyNamed('primeMoverMuscleId'),
            difficultyLevelId: anyNamed('difficultyLevelId'),
            limit: anyNamed('limit'),
          ),
        ).thenAnswer((_) async => tExercises);

        // act
        final result = await repo.getRandomExercises();

        // assert
        expect(result, isA<SuccessBaseResponse<List<ExerciseEntity>>>());
        verify(
          mockLocalDataSource.getRandomExercises(
            primeMoverMuscleId: anyNamed('primeMoverMuscleId'),
            difficultyLevelId: anyNamed('difficultyLevelId'),
            limit: anyNamed('limit'),
          ),
        ).called(1);
      },
    );

    test('should return ErrorBaseResponse when local call fails', () async {
      // arrange
      when(
        mockLocalDataSource.getRandomExercises(
          primeMoverMuscleId: anyNamed('primeMoverMuscleId'),
          difficultyLevelId: anyNamed('difficultyLevelId'),
          limit: anyNamed('limit'),
        ),
      ).thenThrow(Exception('database error'));

      // act
      final result = await repo.getRandomExercises();

      // assert
      expect(result, isA<ErrorBaseResponse<List<ExerciseEntity>>>());
    });
  });

  group('getMuscleGroups', () {
    final tMuscles = [const MuscleModel(id: '1', name: 'Abs')];

    test(
      'should return SuccessBaseResponse with List<MuscleEntity> when local call is successful',
      () async {
        // arrange
        when(
          mockLocalDataSource.getMuscleGroups(),
        ).thenAnswer((_) async => tMuscles);

        // act
        final result = await repo.getMuscleGroups();

        // assert
        expect(result, isA<SuccessBaseResponse<List<MuscleEntity>>>());
        verify(mockLocalDataSource.getMuscleGroups()).called(1);
      },
    );
  });

  group('getRandomMuscles', () {
    final tMuscles = [const MuscleModel(id: '1', name: 'Muscle 1')];

    test(
      'should return SuccessBaseResponse with List<MuscleEntity> when local call is successful',
      () async {
        // arrange
        when(
          mockLocalDataSource.getRandomMuscles(),
        ).thenAnswer((_) async => tMuscles);

        // act
        final result = await repo.getRandomMuscles();

        // assert
        expect(result, isA<SuccessBaseResponse<List<MuscleEntity>>>());
        final data = (result as SuccessBaseResponse<List<MuscleEntity>>).data;
        expect(data?.length, 1);
        expect(data?.first.name, 'Muscle 1');
      },
    );
  });

  group('getMusclesByGroupId', () {
    final tMuscles = [const MuscleModel(id: '1', name: 'Muscle 1')];

    test(
      'should return SuccessBaseResponse with List<MuscleEntity> when local call is successful',
      () async {
        // arrange
        when(
          mockLocalDataSource.getMusclesByGroupId(any),
        ).thenAnswer((_) async => tMuscles);

        // act
        final result = await repo.getMusclesByGroupId('1');

        // assert
        expect(result, isA<SuccessBaseResponse<List<MuscleEntity>>>());
        verify(mockLocalDataSource.getMusclesByGroupId('1')).called(1);
      },
    );
  });

  group('getLevels', () {
    final tLevels = [const LevelModel(id: '1', name: 'Beginner')];

    test(
      'should return SuccessBaseResponse with List<LevelEntity> when local call is successful',
      () async {
        // arrange
        when(mockLocalDataSource.getLevels()).thenAnswer((_) async => tLevels);

        // act
        final result = await repo.getLevels();

        // assert
        expect(result, isA<SuccessBaseResponse<List<LevelEntity>>>());
        verify(mockLocalDataSource.getLevels()).called(1);
      },
    );
  });

  group('getMealsCategories', () {
    final tCategories = [
      const MealCategoryModel(idCategory: '1', strCategory: 'Beef'),
    ];

    test(
      'should return SuccessBaseResponse with List<MealCategoryEntity> when local call is successful',
      () async {
        // arrange
        when(
          mockLocalDataSource.getMealsCategories(),
        ).thenAnswer((_) async => tCategories);

        // act
        final result = await repo.getMealsCategories();

        // assert
        expect(result, isA<SuccessBaseResponse<List<MealCategoryEntity>>>());
        verify(mockLocalDataSource.getMealsCategories()).called(1);
      },
    );
  });

  group('getMealsByCategory', () {
    final tMeals = [const MealModel(idMeal: '1', strMeal: 'Meal 1')];

    test(
      'should return SuccessBaseResponse with List<MealEntity> when local call is successful',
      () async {
        // arrange
        when(
          mockLocalDataSource.getMealsByCategory(any),
        ).thenAnswer((_) async => tMeals);

        // act
        final result = await repo.getMealsByCategory('Beef');

        // assert
        expect(result, isA<SuccessBaseResponse<List<MealEntity>>>());
        verify(mockLocalDataSource.getMealsByCategory('Beef')).called(1);
      },
    );
  });

  group('HomeRepoImpl.getDetailsFood', () {
    test('maps the model onto the entity', () async {
      // arrange
      const tMeal = DetailsFoodModel(idMeal: '52959', strMeal: 'Baked salmon');
      when(
        mockLocalDataSource.getDetailsFood('52959'),
      ).thenAnswer((_) async => tMeal);

      // act
      final result = await repo.getDetailsFood('52959');

      // assert
      expect(result, isA<SuccessBaseResponse>());
      final details = (result as SuccessBaseResponse<DetailsFoodEntity>).data!;
      expect(details.id, '52959');
      expect(details.name, 'Baked salmon');
    });

    test('fails when the data source returns null', () async {
      // arrange
      when(
        mockLocalDataSource.getDetailsFood(any),
      ).thenAnswer((_) async => null);

      // act
      final result = await repo.getDetailsFood('nope');

      // assert
      expect(result, isA<ErrorBaseResponse>());
      expect(
        (result as ErrorBaseResponse<DetailsFoodEntity>).errorMessage,
        AppStrings.detailsFoodNotFound,
      );
    });

    test('passes an exception through as error', () async {
      // arrange
      when(
        mockLocalDataSource.getDetailsFood(any),
      ).thenThrow(Exception('offline'));

      // act
      final result = await repo.getDetailsFood('52959');

      // assert
      expect(result, isA<ErrorBaseResponse>());
    });
  });
}
