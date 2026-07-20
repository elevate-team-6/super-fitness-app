import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/features/home/api/api_client/food_api_client.dart';
import 'package:super_fitness/features/home/api/data_sources/food_remote_data_source_impl.dart';
import 'package:super_fitness/features/home/data/models/response/meal_model.dart';
import 'package:super_fitness/features/home/data/models/response/meals_response_model.dart';

import 'food_remote_data_source_impl_test.mocks.dart';

@GenerateMocks([FoodApiClient])
void main() {
  late MockFoodApiClient mockApiClient;
  late FoodRemoteDataSourceImpl dataSource;

  const responseModel = MealsResponseModel(
    meals: [
      MealModel(
        idMeal: '52940',
        strMeal: 'Brown Stew Chicken',
        strMealThumb: 'https://themealdb.com/brown-stew.jpg',
        strArea: 'Jamaican',
        strCountry: 'Jamaica',
      ),
    ],
  );

  setUp(() {
    mockApiClient = MockFoodApiClient();
    dataSource = FoodRemoteDataSourceImpl(mockApiClient);
  });

  group('getMealsByCategory', () {
    test('forwards the category to the api client', () async {
      when(
        mockApiClient.getMealsByCategory('Chicken'),
      ).thenAnswer((_) async => responseModel);

      await dataSource.getMealsByCategory('Chicken');

      verify(mockApiClient.getMealsByCategory('Chicken')).called(1);
      verifyNoMoreInteractions(mockApiClient);
    });

    test('wraps a successful api response in SuccessBaseResponse', () async {
      when(
        mockApiClient.getMealsByCategory(any),
      ).thenAnswer((_) async => responseModel);

      final result = await dataSource.getMealsByCategory('Chicken');

      expect(result, isA<SuccessBaseResponse<MealsResponseModel>>());
      final meal =
          (result as SuccessBaseResponse<MealsResponseModel>).data!.meals!
              .single;
      expect(meal.idMeal, '52940');
      expect(meal.strMeal, 'Brown Stew Chicken');
    });

    test('passes through the null meals list TheMealDB returns for an '
        'empty category', () async {
      when(
        mockApiClient.getMealsByCategory(any),
      ).thenAnswer((_) async => const MealsResponseModel());

      final result = await dataSource.getMealsByCategory('Chicken');

      expect(result, isA<SuccessBaseResponse<MealsResponseModel>>());
      expect(
        (result as SuccessBaseResponse<MealsResponseModel>).data!.meals,
        isNull,
      );
    });

    test('wraps a Dio failure in ErrorBaseResponse instead of throwing', () async {
      when(mockApiClient.getMealsByCategory(any)).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/filter.php'),
          type: DioExceptionType.connectionTimeout,
        ),
      );

      final result = await dataSource.getMealsByCategory('Chicken');

      // ErrorHandler must swallow the exception and surface it as a response.
      expect(result, isA<ErrorBaseResponse<MealsResponseModel>>());
      expect(
        (result as ErrorBaseResponse<MealsResponseModel>).errorMessage,
        isNotEmpty,
      );
    });

    test('wraps a 500 bad response in ErrorBaseResponse', () async {
      when(mockApiClient.getMealsByCategory(any)).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/filter.php'),
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 500,
            requestOptions: RequestOptions(path: '/filter.php'),
          ),
        ),
      );

      final result = await dataSource.getMealsByCategory('Chicken');

      expect(result, isA<ErrorBaseResponse<MealsResponseModel>>());
    });

    test('wraps an unexpected error in ErrorBaseResponse', () async {
      when(
        mockApiClient.getMealsByCategory(any),
      ).thenThrow(Exception('unexpected'));

      final result = await dataSource.getMealsByCategory('Chicken');

      expect(result, isA<ErrorBaseResponse<MealsResponseModel>>());
    });
  });
}
