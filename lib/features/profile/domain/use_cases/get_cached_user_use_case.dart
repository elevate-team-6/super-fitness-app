import 'package:injectable/injectable.dart';
import 'package:super_fitness/features/auth/domain/entities/user_entity.dart';
import 'package:super_fitness/features/profile/domain/repo/profile_repo_contract.dart';

@injectable
class GetCachedUserUseCase {
  final ProfileRepoContract _repo;

  const GetCachedUserUseCase(this._repo);

  Future<UserEntity?> call() => _repo.getCachedUser();
}
