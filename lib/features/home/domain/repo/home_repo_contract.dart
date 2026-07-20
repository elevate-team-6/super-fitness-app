import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/features/home/domain/entities/meal_entity.dart';
import 'package:super_fitness/features/home/domain/entities/meal_time.dart';

abstract class HomeRepoContract {
  Future<BaseResponse<List<MealEntity>>> getMealsByMealTime(MealTime mealTime);
}
