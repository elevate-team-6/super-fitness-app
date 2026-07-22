import 'package:injectable/injectable.dart';
import '../../../../config/base_response/base_response.dart';
import '../entities/meal_category_entity.dart';
import '../repo/home_repo_contract.dart';

@injectable
class GetMealsCategoriesUseCase {
  final HomeRepoContract _repo;

  GetMealsCategoriesUseCase(this._repo);

  Future<BaseResponse<List<MealCategoryEntity>>> call() {
    return _repo.getMealsCategories();
  }
}
