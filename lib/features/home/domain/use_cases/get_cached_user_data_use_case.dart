import 'package:injectable/injectable.dart';
import '../../../../config/base_response/base_response.dart';
import '../entities/home_user_entity.dart';
import '../repo/home_repo_contract.dart';

@injectable
class GetCachedUserDataUseCase {
  final HomeRepoContract _repository;

  GetCachedUserDataUseCase(this._repository);

  Future<BaseResponse<HomeUserEntity>> call() async {
    return await _repository.getCachedUserData();
  }
}
