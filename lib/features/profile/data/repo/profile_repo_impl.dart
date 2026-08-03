import 'package:easy_localization/easy_localization.dart';
import 'package:injectable/injectable.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/features/auth/domain/entities/user_entity.dart';
import 'package:super_fitness/features/profile/data/data_sources/profile_local_data_source_contract.dart';
import 'package:super_fitness/features/profile/data/data_sources/profile_remote_data_source_contract.dart';
import 'package:super_fitness/features/profile/data/models/response/profile_data_response.dart';
import 'package:super_fitness/features/profile/domain/repo/profile_repo_contract.dart';

@Injectable(as: ProfileRepoContract)
class ProfileRepoImpl implements ProfileRepoContract {
  final ProfileRemoteDataSourceContract _remoteDataSource;

  final ProfileLocalDataSourceContract _localDataSource;

  const ProfileRepoImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<UserEntity?> getCachedUser() => _localDataSource.getCachedUser();

  /// Caching the result is what makes this a first-visit-only call — every
  /// later visit is served by [getCachedUser] without touching the network.
  @override
  Future<BaseResponse<UserEntity>> getProfileData() async {
    final response = await _remoteDataSource.getProfileData();

    switch (response) {
      case SuccessBaseResponse<ProfileDataResponse>(data: final profileData):
        final user = profileData?.user;
        if (user == null) {
          return ErrorBaseResponse(AppStrings.unexpectedError.tr());
        }

        await _localDataSource.cacheUser(user);

        return SuccessBaseResponse(user.toEntity());

      case ErrorBaseResponse<ProfileDataResponse>():
        return ErrorBaseResponse(response.errorMessage);
    }
  }
}
