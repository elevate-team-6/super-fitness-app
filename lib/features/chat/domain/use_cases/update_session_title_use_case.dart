import 'package:injectable/injectable.dart';
import '../../../../config/base_response/base_response.dart';
import '../repo/chat_repo_contract.dart';

@lazySingleton
class UpdateSessionTitleUseCase {
  final ChatRepoContract _repo;

  UpdateSessionTitleUseCase(this._repo);

  Future<BaseResponse<void>> call(String id, String title) {
    return _repo.updateSessionTitle(id, title);
  }
}
