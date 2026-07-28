import 'package:injectable/injectable.dart';
import 'package:super_fitness/config/services/auth_service.dart';
import 'package:super_fitness/features/auth/domain/entities/user_entity.dart';

@injectable
class GetCachedUserUseCase {
  const GetCachedUserUseCase();

  Future<UserEntity?> call() => AuthService.getCachedUser();
}
