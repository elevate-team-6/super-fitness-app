import 'package:injectable/injectable.dart';
import '../../../../config/base_response/base_response.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../repo/chat_repo_contract.dart';

@lazySingleton
class GetChatUserUseCase {
  final ChatRepoContract _repo;

  GetChatUserUseCase(this._repo);

  Future<UserEntity?> call() async {
    final result = await _repo.getCachedUser();
    if (result is SuccessBaseResponse<UserEntity?>) {
      return result.data;
    }
    return null;
  }
}
