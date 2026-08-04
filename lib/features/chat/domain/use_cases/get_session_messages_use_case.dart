import 'package:injectable/injectable.dart';
import '../../../../config/base_response/base_response.dart';
import '../entities/chat_message_entity.dart';
import '../repo/chat_repo_contract.dart';

@lazySingleton
class GetSessionMessagesUseCase {
  final ChatRepoContract _repo;

  GetSessionMessagesUseCase(this._repo);

  Future<BaseResponse<List<ChatMessageEntity>>> call(String sessionId) {
    return _repo.getSessionMessages(sessionId);
  }
}
