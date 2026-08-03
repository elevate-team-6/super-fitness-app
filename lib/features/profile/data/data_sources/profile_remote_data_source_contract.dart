import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/features/profile/data/models/response/profile_data_response.dart';

abstract class ProfileRemoteDataSourceContract {
  Future<BaseResponse<ProfileDataResponse>> getProfileData();
}
