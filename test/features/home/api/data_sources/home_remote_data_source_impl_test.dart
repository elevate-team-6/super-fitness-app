import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/features/home/api/api_client/home_api_client.dart';
import 'package:super_fitness/features/home/api/data_sources/home_remote_data_source_impl.dart';
import 'package:super_fitness/features/home/data/models/response/exercise_response.dart';
import 'package:super_fitness/features/home/data/models/response/meal_category_response.dart';
import 'package:super_fitness/features/home/data/models/response/muscle_response.dart';

import 'home_remote_data_source_impl_test.mocks.dart';

@GenerateMocks([HomeApiClient])
void main() {
  late HomeRemoteDataSourceImpl dataSource;
  late MockHomeApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockHomeApiClient();
    dataSource = HomeRemoteDataSourceImpl(mockApiClient);
  });

  const tLanguage = 'en';

  group('getRandomExercises', () {
    const tExerciseResponse = ExerciseResponse(exercises: []);

    test('should return SuccessBaseResponse when API call is successful', () async {
      // arrange
      when(mockApiClient.getRandomExercises(
        language: anyNamed('language'),
        targetMuscleGroupId: anyNamed('targetMuscleGroupId'),
        difficultyLevelId: anyNamed('difficultyLevelId'),
        limit: anyNamed('limit'),
      )).thenAnswer((_) async => tExerciseResponse);

      // act
      final result = await dataSource.getRandomExercises(language: tLanguage);

      // assert
      expect(result, isA<SuccessBaseResponse<ExerciseResponse>>());
      expect((result as SuccessBaseResponse).data, tExerciseResponse);
      verify(mockApiClient.getRandomExercises(language: tLanguage));
    });

    test('should return ErrorBaseResponse when API call throws an exception', () async {
      // arrange
      when(mockApiClient.getRandomExercises(
        language: anyNamed('language'),
        targetMuscleGroupId: anyNamed('targetMuscleGroupId'),
        difficultyLevelId: anyNamed('difficultyLevelId'),
        limit: anyNamed('limit'),
      )).thenThrow(Exception('Server Error'));

      // act
      final result = await dataSource.getRandomExercises(language: tLanguage);

      // assert
      expect(result, isA<ErrorBaseResponse<ExerciseResponse>>());
    });
  });

  group('getMuscleGroups', () {
    const tMuscleResponse = MuscleResponse(musclesGroup: []);

    test('should return SuccessBaseResponse when API call is successful', () async {
      // arrange
      when(mockApiClient.getMuscleGroups(language: anyNamed('language')))
          .thenAnswer((_) async => tMuscleResponse);

      // act
      final result = await dataSource.getMuscleGroups(language: tLanguage);

      // assert
      expect(result, isA<SuccessBaseResponse<MuscleResponse>>());
      verify(mockApiClient.getMuscleGroups(language: tLanguage));
    });
  });

  group('getMealsCategories', () {
    const tMealCategoryResponse = MealCategoryResponse(categories: []);

    test('should return SuccessBaseResponse when API call is successful', () async {
      // arrange
      when(mockApiClient.getMealsCategories())
          .thenAnswer((_) async => tMealCategoryResponse);

      // act
      final result = await dataSource.getMealsCategories();

      // assert
      expect(result, isA<SuccessBaseResponse<MealCategoryResponse>>());
      verify(mockApiClient.getMealsCategories());
    });
  });

  group('getAllExercises', () {
    const tExerciseResponse = ExerciseResponse(exercises: []);

    test('should return SuccessBaseResponse when API call is successful', () async {
      // arrange
      when(mockApiClient.getAllExercises(
        language: anyNamed('language'),
        page: anyNamed('page'),
        limit: anyNamed('limit'),
      )).thenAnswer((_) async => tExerciseResponse);

      // act
      final result = await dataSource.getAllExercises(language: tLanguage);

      // assert
      expect(result, isA<SuccessBaseResponse<ExerciseResponse>>());
      verify(mockApiClient.getAllExercises(language: tLanguage));
    });
  });
}
