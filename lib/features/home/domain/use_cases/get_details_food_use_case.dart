import 'package:injectable/injectable.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/features/home/domain/entities/details_food_entity.dart';
import 'package:super_fitness/features/home/domain/repo/food_repo_contract.dart';

@injectable
class GetDetailsFoodUseCase {
  final FoodRepoContract _repo;

  GetDetailsFoodUseCase(this._repo);

  Future<BaseResponse<DetailsFoodEntity>> call(String id) {
    return _repo.getDetailsFood(id);
  }
}
