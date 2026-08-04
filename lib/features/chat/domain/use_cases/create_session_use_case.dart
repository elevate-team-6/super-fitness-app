import 'package:injectable/injectable.dart';
import '../../../../config/base_response/base_response.dart';
import '../repo/chat_repo_contract.dart';

@lazySingleton
class CreateSessionUseCase {
  final ChatRepoContract _repo;

  CreateSessionUseCase(this._repo);

  Future<BaseResponse<void>> call(String id, String title) {
    return _repo.createSession(id, title);
  }
}
