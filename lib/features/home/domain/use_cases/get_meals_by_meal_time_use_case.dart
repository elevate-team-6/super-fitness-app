import 'package:injectable/injectable.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/features/home/domain/entities/meal_entity.dart';
import 'package:super_fitness/features/home/domain/entities/meal_time.dart';
import 'package:super_fitness/features/home/domain/repo/food_repo_contract.dart';

@injectable
class GetMealsByMealTimeUseCase {
  final FoodRepoContract _repo;

  GetMealsByMealTimeUseCase(this._repo);

  Future<BaseResponse<List<MealEntity>>> call(MealTime mealTime) {
    return _repo.getMealsByMealTime(mealTime);
  }
}
