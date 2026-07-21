import 'package:injectable/injectable.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/features/home/domain/entities/details_food_entity.dart';
import 'package:super_fitness/features/home/domain/entities/meal_nutrition_entity.dart';
import 'package:super_fitness/features/home/domain/repo/home_repo_contract.dart';

@injectable
class GetMealNutritionUseCase {
  final HomeRepoContract _repo;

  GetMealNutritionUseCase(this._repo);

  Future<BaseResponse<MealNutritionEntity>> call(DetailsFoodEntity meal) {
    return _repo.getMealNutrition(meal);
  }
}
