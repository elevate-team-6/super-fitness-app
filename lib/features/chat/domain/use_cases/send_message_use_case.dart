import 'package:injectable/injectable.dart';
import '../../../../config/base_response/base_response.dart';
import '../entities/chat_message_entity.dart';
import '../repo/chat_repo_contract.dart';

@lazySingleton
class SendMessageUseCase {
  final ChatRepoContract _repo;

  SendMessageUseCase(this._repo);

  Stream<BaseResponse<ChatMessageEntity>> call({
    required String sessionId,
    required String message,
  }) {
    return _repo.sendMessage(sessionId: sessionId, message: message);
  }
}
