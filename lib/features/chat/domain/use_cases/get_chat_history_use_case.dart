import 'package:injectable/injectable.dart';
import '../../../../config/base_response/base_response.dart';
import '../repo/chat_repo_contract.dart';

@lazySingleton
class GetChatHistoryUseCase {
  final ChatRepoContract _repo;

  GetChatHistoryUseCase(this._repo);

  Future<BaseResponse<List<Map<String, String>>>> call() {
    return _repo.getChatHistory();
  }
}
