import 'package:injectable/injectable.dart';
import '../../../../config/base_response/base_response.dart';
import '../repo/chat_repo_contract.dart';

@lazySingleton
class DeleteSessionUseCase {
  final ChatRepoContract _repo;

  DeleteSessionUseCase(this._repo);

  Future<BaseResponse<void>> call(String id) {
    return _repo.deleteSession(id);
  }
}
