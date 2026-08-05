import 'package:super_fitness/features/auth/domain/entities/user_entity.dart';

import '../../../auth/data/models/response/user_model.dart';

abstract class ProfileLocalDataSourceContract {
  Future<UserEntity?> getCachedUser();

  Future<void> cacheUser(UserModel user);
}
