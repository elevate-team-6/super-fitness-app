import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/config/cache/secure_cache_helper.dart';
import 'package:super_fitness/core/utils/app_keys.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/features/home/data/data_sources/home_remote_data_source_contract.dart';
import 'package:super_fitness/features/home/data/models/response/details_food_model.dart';
import 'package:super_fitness/features/home/data/models/response/details_food_response_model.dart';
import 'package:super_fitness/features/home/data/models/response/exercise_response.dart';
import 'package:super_fitness/features/home/data/models/response/level_response.dart';
import 'package:super_fitness/features/home/data/models/response/meal_category_response.dart';
import 'package:super_fitness/features/home/data/models/response/meal_model.dart';
import 'package:super_fitness/features/home/data/models/response/meals_response_model.dart';
import 'package:super_fitness/features/home/data/models/response/muscle_response.dart';
import 'package:super_fitness/features/home/data/models/response/muscles_by_group_response.dart';
import 'package:super_fitness/features/home/data/repo/home_repo_impl.dart';
import 'package:super_fitness/features/home/domain/entities/details_food_entity.dart';
import 'package:super_fitness/features/home/domain/entities/exercise_entity.dart';
import 'package:super_fitness/features/home/domain/entities/home_user_entity.dart';
import 'package:super_fitness/features/home/domain/entities/level_entity.dart';
import 'package:super_fitness/features/home/domain/entities/meal_category_entity.dart';
import 'package:super_fitness/features/home/domain/entities/meal_entity.dart';
import 'package:super_fitness/features/home/domain/entities/meal_time.dart';
import 'package:super_fitness/features/home/domain/entities/muscle_entity.dart';

import 'home_repo_impl_test.mocks.dart';

@GenerateMocks([HomeRemoteDataSourceContract, SecureCacheHelper])
void main() {
  provideDummy<BaseResponse<ExerciseResponse>>(
    const SuccessBaseResponse(ExerciseResponse()),
  );
  provideDummy<BaseResponse<MuscleResponse>>(
    const SuccessBaseResponse(MuscleResponse()),
  );
  provideDummy<BaseResponse<MusclesByGroupResponse>>(
    const SuccessBaseResponse(MusclesByGroupResponse()),
  );
  provideDummy<BaseResponse<MealCategoryResponse>>(
    const SuccessBaseResponse(MealCategoryResponse()),
  );
  provideDummy<BaseResponse<LevelResponse>>(
    const SuccessBaseResponse(LevelResponse()),
  );
  provideDummy<BaseResponse<MealsResponseModel>>(
    const ErrorBaseResponse('dummy'),
  );
  provideDummy<BaseResponse<DetailsFoodResponseModel>>(
    const ErrorBaseResponse('dummy'),
  );

  late HomeRepoImpl repo;
  late MockHomeRemoteDataSourceContract mockRemoteDataSource;
  late MockSecureCacheHelper mockCacheHelper;

  setUp(() {
    mockRemoteDataSource = MockHomeRemoteDataSourceContract();
    mockCacheHelper = MockSecureCacheHelper();
    repo = HomeRepoImpl(mockRemoteDataSource, mockCacheHelper);
  });

  MealsResponseModel mealsOf(List<String> ids) => MealsResponseModel(
        meals: ids
            .map((id) => MealModel(idMeal: id, strMeal: 'Meal $id'))
            .toList(),
      );

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
    const tExerciseResponse = ExerciseResponse(exercises: []);

    test(
      'should return SuccessBaseResponse with List<ExerciseEntity> when remote call is successful',
      () async {
        // arrange
        when(
          mockRemoteDataSource.getRandomExercises(
            language: anyNamed('language'),
            targetMuscleGroupId: anyNamed('targetMuscleGroupId'),
            difficultyLevelId: anyNamed('difficultyLevelId'),
            limit: anyNamed('limit'),
          ),
        ).thenAnswer((_) async => const SuccessBaseResponse(tExerciseResponse));

        // act
        final result = await repo.getRandomExercises();

        // assert
        expect(result, isA<SuccessBaseResponse<List<ExerciseEntity>>>());
        verify(mockRemoteDataSource.getRandomExercises(
          language: anyNamed('language'),
          targetMuscleGroupId: anyNamed('targetMuscleGroupId'),
          difficultyLevelId: anyNamed('difficultyLevelId'),
          limit: anyNamed('limit'),
        )).called(1);
      },
    );

    test('should return ErrorBaseResponse when remote call fails', () async {
      // arrange
      when(
        mockRemoteDataSource.getRandomExercises(
          language: anyNamed('language'),
          targetMuscleGroupId: anyNamed('targetMuscleGroupId'),
          difficultyLevelId: anyNamed('difficultyLevelId'),
          limit: anyNamed('limit'),
        ),
      ).thenAnswer((_) async => const ErrorBaseResponse('error'));

      // act
      final result = await repo.getRandomExercises();

      // assert
      expect(result, isA<ErrorBaseResponse<List<ExerciseEntity>>>());
    });
  });

  group('getMuscleGroups', () {
    const tMuscleResponse = MuscleResponse(musclesGroup: []);

    test(
      'should return SuccessBaseResponse with List<MuscleEntity> when remote call is successful',
      () async {
        // arrange
        when(
          mockRemoteDataSource.getMuscleGroups(language: anyNamed('language')),
        ).thenAnswer((_) async => const SuccessBaseResponse(tMuscleResponse));

        // act
        final result = await repo.getMuscleGroups();

        // assert
        expect(result, isA<SuccessBaseResponse<List<MuscleEntity>>>());
        verify(mockRemoteDataSource.getMuscleGroups(language: anyNamed('language')))
            .called(1);
      },
    );
  });

  group('getRandomMuscles', () {
    const tModel = MuscleModel(id: '1', name: 'Muscle 1');
    const tResponse = MuscleResponse(muscles: [tModel]);

    test(
      'should return SuccessBaseResponse with List<MuscleEntity> when remote call is successful',
      () async {
        // arrange
        when(
          mockRemoteDataSource.getRandomMuscles(language: anyNamed('language')),
        ).thenAnswer((_) async => const SuccessBaseResponse(tResponse));

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
    const tMusclesByGroupResponse = MusclesByGroupResponse(muscles: []);

    test(
      'should return SuccessBaseResponse with List<MuscleEntity> when remote call is successful',
      () async {
        // arrange
        when(
          mockRemoteDataSource.getMusclesByGroupId(
            language: anyNamed('language'),
            id: anyNamed('id'),
          ),
        ).thenAnswer(
            (_) async => const SuccessBaseResponse(tMusclesByGroupResponse));

        // act
        final result = await repo.getMusclesByGroupId('1');

        // assert
        expect(result, isA<SuccessBaseResponse<List<MuscleEntity>>>());
        verify(mockRemoteDataSource.getMusclesByGroupId(
          language: anyNamed('language'),
          id: '1',
        )).called(1);
      },
    );
  });

  group('getLevels', () {
    const tLevelResponse = LevelResponse(levels: []);

    test(
      'should return SuccessBaseResponse with List<LevelEntity> when remote call is successful',
      () async {
        // arrange
        when(
          mockRemoteDataSource.getLevels(language: anyNamed('language')),
        ).thenAnswer((_) async => const SuccessBaseResponse(tLevelResponse));

        // act
        final result = await repo.getLevels();

        // assert
        expect(result, isA<SuccessBaseResponse<List<LevelEntity>>>());
        verify(mockRemoteDataSource.getLevels(language: anyNamed('language')))
            .called(1);
      },
    );
  });

  group('getMealsCategories', () {
    const tMealCategoryResponse = MealCategoryResponse(categories: []);

    test(
      'should return SuccessBaseResponse with List<MealCategoryEntity> when remote call is successful',
      () async {
        // arrange
        when(
          mockRemoteDataSource.getMealsCategories(),
        ).thenAnswer(
            (_) async => const SuccessBaseResponse(tMealCategoryResponse));

        // act
        final result = await repo.getMealsCategories();

        // assert
        expect(result, isA<SuccessBaseResponse<List<MealCategoryEntity>>>());
        verify(mockRemoteDataSource.getMealsCategories()).called(1);
      },
    );
  });

  group('getAllExercises', () {
    const tExerciseResponse = ExerciseResponse(exercises: []);

    test(
      'should return SuccessBaseResponse with List<ExerciseEntity> when remote call is successful',
      () async {
        // arrange
        when(
          mockRemoteDataSource.getAllExercises(
            language: anyNamed('language'),
            targetMuscleGroupId: anyNamed('targetMuscleGroupId'),
            muscleId: anyNamed('muscleId'),
            difficultyLevelId: anyNamed('difficultyLevelId'),
            page: anyNamed('page'),
            limit: anyNamed('limit'),
          ),
        ).thenAnswer((_) async => const SuccessBaseResponse(tExerciseResponse));

        // act
        final result = await repo.getAllExercises();

        // assert
        expect(result, isA<SuccessBaseResponse<List<ExerciseEntity>>>());
        verify(mockRemoteDataSource.getAllExercises(
          language: anyNamed('language'),
          targetMuscleGroupId: anyNamed('targetMuscleGroupId'),
          muscleId: anyNamed('muscleId'),
          difficultyLevelId: anyNamed('difficultyLevelId'),
          page: anyNamed('page'),
          limit: anyNamed('limit'),
        )).called(1);
      },
    );
  });

  group('HomeRepoImpl.getMealsByMealTime', () {
    test('interleaves the categories of a multi-category meal time', () async {
      // MealTime.lunch is Chicken + Pasta + Seafood.
      when(
        mockRemoteDataSource.getMealsByCategory('Chicken'),
      ).thenAnswer((_) async => SuccessBaseResponse(mealsOf(['c1', 'c2'])));
      when(
        mockRemoteDataSource.getMealsByCategory('Pasta'),
      ).thenAnswer((_) async => SuccessBaseResponse(mealsOf(['p1'])));
      when(
        mockRemoteDataSource.getMealsByCategory('Seafood'),
      ).thenAnswer((_) async => SuccessBaseResponse(mealsOf(['s1', 's2'])));

      final result = await repo.getMealsByMealTime(MealTime.lunch);

      expect(result, isA<SuccessBaseResponse>());
      final ids = (result as SuccessBaseResponse<List<MealEntity>>).data!.map(
        (m) => m.id,
      );
      expect(ids, ['c1', 'p1', 's1', 'c2', 's2']);
    });

    test('drops duplicate meals that appear in two categories', () async {
      when(
        mockRemoteDataSource.getMealsByCategory('Chicken'),
      ).thenAnswer((_) async => SuccessBaseResponse(mealsOf(['shared'])));
      when(
        mockRemoteDataSource.getMealsByCategory('Pasta'),
      ).thenAnswer((_) async => SuccessBaseResponse(mealsOf(['shared'])));
      when(
        mockRemoteDataSource.getMealsByCategory('Seafood'),
      ).thenAnswer((_) async => SuccessBaseResponse(mealsOf(['s1'])));

      final result = await repo.getMealsByMealTime(MealTime.lunch);

      final ids = (result as SuccessBaseResponse<List<MealEntity>>).data!.map(
        (m) => m.id,
      );
      expect(ids, ['shared', 's1']);
    });

    test('still succeeds when only some categories fail', () async {
      when(
        mockRemoteDataSource.getMealsByCategory('Chicken'),
      ).thenAnswer((_) async => const ErrorBaseResponse('boom'));
      when(
        mockRemoteDataSource.getMealsByCategory('Pasta'),
      ).thenAnswer((_) async => SuccessBaseResponse(mealsOf(['p1'])));
      when(
        mockRemoteDataSource.getMealsByCategory('Seafood'),
      ).thenAnswer((_) async => const ErrorBaseResponse('boom'));

      final result = await repo.getMealsByMealTime(MealTime.lunch);

      expect(result, isA<SuccessBaseResponse>());
      expect(
        (result as SuccessBaseResponse<List<MealEntity>>).data!.single.id,
        'p1',
      );
    });

    test('fails with the first error when every category fails', () async {
      when(
        mockRemoteDataSource.getMealsByCategory(any),
      ).thenAnswer((_) async => const ErrorBaseResponse('boom'));

      final result = await repo.getMealsByMealTime(MealTime.lunch);

      expect(result, isA<ErrorBaseResponse>());
      expect(
        (result as ErrorBaseResponse<List<MealEntity>>).errorMessage,
        'boom',
      );
    });

    test(
      'returns an empty success when the API returns a null meals list',
      () async {
        when(mockRemoteDataSource.getMealsByCategory('Breakfast')).thenAnswer(
          (_) async => const SuccessBaseResponse(MealsResponseModel()),
        );

        final result = await repo.getMealsByMealTime(MealTime.breakfast);

        expect(result, isA<SuccessBaseResponse>());
        expect((result as SuccessBaseResponse<List<MealEntity>>).data, isEmpty);
      },
    );
  });

  group('HomeRepoImpl.getDetailsFood', () {
    test('maps the first record onto the entity', () async {
      when(mockRemoteDataSource.getDetailsFood('52959')).thenAnswer(
        (_) async => SuccessBaseResponse(
          DetailsFoodResponseModel(
            meals: [
              DetailsFoodModel.fromJson(const {
                'idMeal': '52959',
                'strMeal': 'Baked salmon',
                'strIngredient1': 'Salmon',
                'strMeasure1': '350g',
              }),
            ],
          ),
        ),
      );

      final result = await repo.getDetailsFood('52959');

      expect(result, isA<SuccessBaseResponse>());
      final details = (result as SuccessBaseResponse<DetailsFoodEntity>).data!;
      expect(details.id, '52959');
      expect(details.name, 'Baked salmon');
      expect(details.ingredients.single.name, 'Salmon');
    });

    // `lookup.php` answers an unknown id with a 200 and `{"meals": null}`
    // rather than a 404, so the repo has to turn that into a failure itself.
    test('fails when the API returns a null meals list', () async {
      when(mockRemoteDataSource.getDetailsFood(any)).thenAnswer(
        (_) async => const SuccessBaseResponse(DetailsFoodResponseModel()),
      );

      final result = await repo.getDetailsFood('nope');

      expect(result, isA<ErrorBaseResponse>());
      expect(
        (result as ErrorBaseResponse<DetailsFoodEntity>).errorMessage,
        AppStrings.detailsFoodNotFound,
      );
    });

    test('fails when the API returns an empty meals list', () async {
      when(mockRemoteDataSource.getDetailsFood(any)).thenAnswer(
        (_) async =>
            const SuccessBaseResponse(DetailsFoodResponseModel(meals: [])),
      );

      final result = await repo.getDetailsFood('nope');

      expect(result, isA<ErrorBaseResponse>());
    });

    test('passes a data source failure through', () async {
      when(
        mockRemoteDataSource.getDetailsFood(any),
      ).thenAnswer((_) async => const ErrorBaseResponse('offline'));

      final result = await repo.getDetailsFood('52959');

      expect(result, isA<ErrorBaseResponse>());
      expect(
        (result as ErrorBaseResponse<DetailsFoodEntity>).errorMessage,
        'offline',
      );
    });
  });
}
