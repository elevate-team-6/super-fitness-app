import 'package:injectable/injectable.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/features/home/domain/entities/meal_details_entity.dart';
import 'package:super_fitness/features/home/domain/repo/food_repo_contract.dart';

@injectable
class GetMealDetailsUseCase {
  final FoodRepoContract _repo;

  GetMealDetailsUseCase(this._repo);

  Future<BaseResponse<MealDetailsEntity>> call(String id) {
    return _repo.getMealDetails(id);
  }
}
