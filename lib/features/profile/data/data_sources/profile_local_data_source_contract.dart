import 'package:super_fitness/features/auth/data/models/response/user_model.dart';
import 'package:super_fitness/features/auth/domain/entities/user_entity.dart';

abstract class ProfileLocalDataSourceContract {
  Future<UserEntity?> getCachedUser();

  /// Keeps the cached copy in step with the server so the app still has a user
  /// to show when `/auth/profile-data` can't be reached.
  Future<void> cacheUser(UserModel user);
}
