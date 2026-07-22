import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/config/cache/secure_cache_helper.dart';
import 'package:super_fitness/core/utils/app_keys.dart';
import 'package:super_fitness/features/home/data/data_sources/home_remote_data_source_contract.dart';
import 'package:super_fitness/features/home/data/models/response/exercise_response.dart';
import 'package:super_fitness/features/home/data/models/response/meal_category_response.dart';
import 'package:super_fitness/features/home/data/models/response/muscle_response.dart';
import 'package:super_fitness/features/home/data/repo/home_repo_impl.dart';
import 'package:super_fitness/features/home/domain/entities/exercise_entity.dart';
import 'package:super_fitness/features/home/domain/entities/home_user_entity.dart';
import 'package:super_fitness/features/home/domain/entities/meal_category_entity.dart';
import 'package:super_fitness/features/home/domain/entities/muscle_entity.dart';

import 'home_repo_impl_test.mocks.dart';

@GenerateMocks([HomeRemoteDataSourceContract, SecureCacheHelper])
void main() {
  late HomeRepoImpl repo;
  late MockHomeRemoteDataSourceContract mockRemoteDataSource;
  late MockSecureCacheHelper mockCacheHelper;

  setUp(() {
    mockRemoteDataSource = MockHomeRemoteDataSourceContract();
    mockCacheHelper = MockSecureCacheHelper();
    repo = HomeRepoImpl(mockRemoteDataSource, mockCacheHelper);
  });

  group('getCachedUserData', () {
    test('should return SuccessBaseResponse with UserEntity when cache has data', () async {
      // arrange
      when(mockCacheHelper.readData(key: AppKeys.userNameKey)).thenAnswer((_) async => 'Test User');
      when(mockCacheHelper.readData(key: AppKeys.userImageKey)).thenAnswer((_) async => 'image_url');

      // act
      final result = await repo.getCachedUserData();

      // assert
      expect(result, isA<SuccessBaseResponse<HomeUserEntity>>());
      final data = (result as SuccessBaseResponse<HomeUserEntity>).data;
      expect(data?.name, 'Test User');
      expect(data?.image, 'image_url');
    });

    test('should return SuccessBaseResponse with empty HomeUserEntity when cache read fails', () async {
      // arrange
      when(mockCacheHelper.readData(key: anyNamed('key'))).thenThrow(Exception());

      // act
      final result = await repo.getCachedUserData();

      // assert
      expect(result, isA<SuccessBaseResponse<HomeUserEntity>>());
      expect((result as SuccessBaseResponse<HomeUserEntity>).data, HomeUserEntity.empty);
    });
  });

  group('getRandomExercises', () {
    const tModel = ExerciseModel(id: '1', exercise: 'Exercise 1');
    const tResponse = ExerciseResponse(exercises: [tModel]);

    test('should return SuccessBaseResponse with List<ExerciseEntity> when remote call is successful', () async {
      // arrange
      when(mockRemoteDataSource.getRandomExercises(
        language: anyNamed('language'),
        targetMuscleGroupId: anyNamed('targetMuscleGroupId'),
        difficultyLevelId: anyNamed('difficultyLevelId'),
        limit: anyNamed('limit'),
      )).thenAnswer((_) async => const SuccessBaseResponse(tResponse));

      // act
      final result = await repo.getRandomExercises();

      // assert
      expect(result, isA<SuccessBaseResponse<List<ExerciseEntity>>>());
      final data = (result as SuccessBaseResponse<List<ExerciseEntity>>).data;
      expect(data?.length, 1);
      expect(data?.first.id, '1');
    });

    test('should return ErrorBaseResponse when remote call fails', () async {
      // arrange
      when(mockRemoteDataSource.getRandomExercises(
        language: anyNamed('language'),
        targetMuscleGroupId: anyNamed('targetMuscleGroupId'),
        difficultyLevelId: anyNamed('difficultyLevelId'),
        limit: anyNamed('limit'),
      )).thenAnswer((_) async => const ErrorBaseResponse('Error'));

      // act
      final result = await repo.getRandomExercises();

      // assert
      expect(result, isA<ErrorBaseResponse<List<ExerciseEntity>>>());
    });
  });

  group('getMuscleGroups', () {
    const tModel = MuscleModel(id: '1', name: 'Muscle 1');
    const tResponse = MuscleResponse(musclesGroup: [tModel]);

    test('should return SuccessBaseResponse with List<MuscleEntity> when remote call is successful', () async {
      // arrange
      when(mockRemoteDataSource.getMuscleGroups(language: anyNamed('language')))
          .thenAnswer((_) async => const SuccessBaseResponse(tResponse));

      // act
      final result = await repo.getMuscleGroups();

      // assert
      expect(result, isA<SuccessBaseResponse<List<MuscleEntity>>>());
      expect((result as SuccessBaseResponse<List<MuscleEntity>>).data?.first.name, 'Muscle 1');
    });
  });

  group('getMealsCategories', () {
    const tModel = MealCategoryModel(idCategory: '1', strCategory: 'Cat 1');
    const tResponse = MealCategoryResponse(categories: [tModel]);

    test('should return SuccessBaseResponse with List<MealCategoryEntity> when remote call is successful', () async {
      // arrange
      when(mockRemoteDataSource.getMealsCategories())
          .thenAnswer((_) async => const SuccessBaseResponse(tResponse));

      // act
      final result = await repo.getMealsCategories();

      // assert
      expect(result, isA<SuccessBaseResponse<List<MealCategoryEntity>>>());
      expect((result as SuccessBaseResponse<List<MealCategoryEntity>>).data?.first.name, 'Cat 1');
    });
  });

  group('getAllExercises', () {
    const tModel = ExerciseModel(id: '1', exercise: 'Exercise 1');
    const tResponse = ExerciseResponse(exercises: [tModel]);

    test('should return SuccessBaseResponse with List<ExerciseEntity> when remote call is successful', () async {
      // arrange
      when(mockRemoteDataSource.getAllExercises(
        language: anyNamed('language'),
        page: anyNamed('page'),
        limit: anyNamed('limit'),
      )).thenAnswer((_) async => const SuccessBaseResponse(tResponse));

      // act
      final result = await repo.getAllExercises();

      // assert
      expect(result, isA<SuccessBaseResponse<List<ExerciseEntity>>>());
      expect((result as SuccessBaseResponse<List<ExerciseEntity>>).data?.first.id, '1');
    });
  });
}
