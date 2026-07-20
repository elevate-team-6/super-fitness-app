import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/features/home/data/data_sources/home_remote_data_source_contract.dart';
import 'package:super_fitness/features/home/data/models/response/meal_model.dart';
import 'package:super_fitness/features/home/data/models/response/meals_response_model.dart';
import 'package:super_fitness/features/home/data/repo/home_repo_impl.dart';
import 'package:super_fitness/features/home/domain/entities/meal_entity.dart';
import 'package:super_fitness/features/home/domain/entities/meal_time.dart';

import 'home_repo_impl_test.mocks.dart';

@GenerateMocks([HomeRemoteDataSourceContract])
void main() {
  late MockHomeRemoteDataSourceContract dataSource;
  late HomeRepoImpl repo;

  setUp(() {
    provideDummy<BaseResponse<MealsResponseModel>>(
      const ErrorBaseResponse('dummy'),
    );
    dataSource = MockHomeRemoteDataSourceContract();
    repo = HomeRepoImpl(dataSource);
  });

  MealsResponseModel mealsOf(List<String> ids) => MealsResponseModel(
    meals: ids
        .map((id) => MealModel(idMeal: id, strMeal: 'Meal $id'))
        .toList(),
  );

  group('HomeRepoImpl.getMealsByMealTime', () {
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
}
