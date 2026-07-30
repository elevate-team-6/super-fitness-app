import 'package:injectable/injectable.dart';
import '../../../../config/base_response/base_response.dart';
import '../entities/meal_entity.dart';
import '../repo/home_repo_contract.dart';

@injectable
class GetMealsByCategoryUseCase {
  final HomeRepoContract _repo;

  GetMealsByCategoryUseCase(this._repo);

  Future<BaseResponse<List<MealEntity>>> call(String category) {
    return _repo.getMealsByCategory(category);
  }
}
