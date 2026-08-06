import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/features/auth/domain/entities/user_entity.dart';

/// Contract for the Chat Local Data Source (Local Cache/Secure Storage).
abstract interface class ChatLocalDataSourceContract {
  /// Retrieves the cached user data if available.
  Future<BaseResponse<UserEntity?>> getCachedUser();
}
