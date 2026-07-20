import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/features/home/data/data_sources/food_remote_data_source_contract.dart';
import 'package:super_fitness/features/home/data/models/response/meal_details_model.dart';
import 'package:super_fitness/features/home/data/models/response/meal_details_response_model.dart';
import 'package:super_fitness/features/home/data/models/response/meal_model.dart';
import 'package:super_fitness/features/home/data/models/response/meals_response_model.dart';
import 'package:super_fitness/features/home/data/repo/food_repo_impl.dart';
import 'package:super_fitness/features/home/domain/entities/meal_details_entity.dart';
import 'package:super_fitness/features/home/domain/entities/meal_entity.dart';
import 'package:super_fitness/features/home/domain/entities/meal_time.dart';

import 'food_repo_impl_test.mocks.dart';

@GenerateMocks([FoodRemoteDataSourceContract])
void main() {
  late MockFoodRemoteDataSourceContract dataSource;
  late FoodRepoImpl repo;

  setUp(() {
    provideDummy<BaseResponse<MealsResponseModel>>(
      const ErrorBaseResponse('dummy'),
    );
    dataSource = MockFoodRemoteDataSourceContract();
    repo = FoodRepoImpl(dataSource);
  });

  MealsResponseModel mealsOf(List<String> ids) => MealsResponseModel(
    meals: ids
        .map((id) => MealModel(idMeal: id, strMeal: 'Meal $id'))
        .toList(),
  );

  group('FoodRepoImpl.getMealsByMealTime', () {
    test('interleaves the categories of a multi-category meal time', () async {
      // MealTime.lunch is Chicken + Pasta + Seafood.
      when(dataSource.getMealsByCategory('Chicken'))
          .thenAnswer((_) async => SuccessBaseResponse(mealsOf(['c1', 'c2'])));
      when(dataSource.getMealsByCategory('Pasta'))
          .thenAnswer((_) async => SuccessBaseResponse(mealsOf(['p1'])));
      when(dataSource.getMealsByCategory('Seafood'))
          .thenAnswer((_) async => SuccessBaseResponse(mealsOf(['s1', 's2'])));

      final result = await repo.getMealsByMealTime(MealTime.lunch);

      expect(result, isA<SuccessBaseResponse>());
      final ids = (result as SuccessBaseResponse<List<MealEntity>>).data!.map((m) => m.id);
      expect(ids, ['c1', 'p1', 's1', 'c2', 's2']);
    });

    test('drops duplicate meals that appear in two categories', () async {
      when(dataSource.getMealsByCategory('Chicken'))
          .thenAnswer((_) async => SuccessBaseResponse(mealsOf(['shared'])));
      when(dataSource.getMealsByCategory('Pasta'))
          .thenAnswer((_) async => SuccessBaseResponse(mealsOf(['shared'])));
      when(dataSource.getMealsByCategory('Seafood'))
          .thenAnswer((_) async => SuccessBaseResponse(mealsOf(['s1'])));

      final result = await repo.getMealsByMealTime(MealTime.lunch);

      final ids = (result as SuccessBaseResponse<List<MealEntity>>).data!.map((m) => m.id);
      expect(ids, ['shared', 's1']);
    });

    test('still succeeds when only some categories fail', () async {
      when(dataSource.getMealsByCategory('Chicken'))
          .thenAnswer((_) async => const ErrorBaseResponse('boom'));
      when(dataSource.getMealsByCategory('Pasta'))
          .thenAnswer((_) async => SuccessBaseResponse(mealsOf(['p1'])));
      when(dataSource.getMealsByCategory('Seafood'))
          .thenAnswer((_) async => const ErrorBaseResponse('boom'));

      final result = await repo.getMealsByMealTime(MealTime.lunch);

      expect(result, isA<SuccessBaseResponse>());
      expect((result as SuccessBaseResponse<List<MealEntity>>).data!.single.id, 'p1');
    });

    test('fails with the first error when every category fails', () async {
      when(dataSource.getMealsByCategory(any))
          .thenAnswer((_) async => const ErrorBaseResponse('boom'));

      final result = await repo.getMealsByMealTime(MealTime.lunch);

      expect(result, isA<ErrorBaseResponse>());
      expect((result as ErrorBaseResponse<List<MealEntity>>).errorMessage, 'boom');
    });

    test('fails when the API returns a null meals list', () async {
      when(dataSource.getMealsByCategory('Breakfast')).thenAnswer(
        (_) async => const SuccessBaseResponse(MealsResponseModel()),
      );

      final result = await repo.getMealsByMealTime(MealTime.breakfast);

      expect(result, isA<ErrorBaseResponse>());
      expect(
        (result as ErrorBaseResponse<List<MealEntity>>).errorMessage,
        AppStrings.noMealsFound,
      );
    });
  });

  group('FoodRepoImpl.getMealDetails', () {
    setUp(() {
      provideDummy<BaseResponse<MealDetailsResponseModel>>(
        const ErrorBaseResponse('dummy'),
      );
    });

    test('maps the first record onto the entity', () async {
      when(dataSource.getMealDetails('52959')).thenAnswer(
        (_) async => SuccessBaseResponse(
          MealDetailsResponseModel(
            meals: [
              MealDetailsModel.fromJson(const {
                'idMeal': '52959',
                'strMeal': 'Baked salmon',
                'strIngredient1': 'Salmon',
                'strMeasure1': '350g',
              }),
            ],
          ),
        ),
      );

      final result = await repo.getMealDetails('52959');

      expect(result, isA<SuccessBaseResponse>());
      final details = (result as SuccessBaseResponse<MealDetailsEntity>).data!;
      expect(details.id, '52959');
      expect(details.name, 'Baked salmon');
      expect(details.ingredients.single.name, 'Salmon');
    });

    // `lookup.php` answers an unknown id with a 200 and `{"meals": null}`
    // rather than a 404, so the repo has to turn that into a failure itself.
    test('fails when the API returns a null meals list', () async {
      when(dataSource.getMealDetails(any)).thenAnswer(
        (_) async => const SuccessBaseResponse(MealDetailsResponseModel()),
      );

      final result = await repo.getMealDetails('nope');

      expect(result, isA<ErrorBaseResponse>());
      expect(
        (result as ErrorBaseResponse<MealDetailsEntity>).errorMessage,
        AppStrings.mealDetailsNotFound,
      );
    });

    test('fails when the API returns an empty meals list', () async {
      when(dataSource.getMealDetails(any)).thenAnswer(
        (_) async => const SuccessBaseResponse(
          MealDetailsResponseModel(meals: []),
        ),
      );

      final result = await repo.getMealDetails('nope');

      expect(result, isA<ErrorBaseResponse>());
    });

    test('passes a data source failure through', () async {
      when(dataSource.getMealDetails(any))
          .thenAnswer((_) async => const ErrorBaseResponse('offline'));

      final result = await repo.getMealDetails('52959');

      expect(result, isA<ErrorBaseResponse>());
      expect(
        (result as ErrorBaseResponse<MealDetailsEntity>).errorMessage,
        'offline',
      );
    });
  });
}
