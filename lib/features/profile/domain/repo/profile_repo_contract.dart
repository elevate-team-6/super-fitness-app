import 'package:super_fitness/features/auth/domain/entities/user_entity.dart';

abstract class ProfileRepoContract {
  Future<UserEntity?> getCachedUser();
}
