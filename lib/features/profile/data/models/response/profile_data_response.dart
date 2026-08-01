import 'package:super_fitness/core/utils/app_params.dart';
import 'package:super_fitness/features/auth/data/models/response/user_model.dart';

/// `GET /auth/profile-data` — the signed-in user, straight from the server.
class ProfileDataResponse {
  final String? message;
  final UserModel? user;

  const ProfileDataResponse({this.message, this.user});

  factory ProfileDataResponse.fromJson(Map<String, dynamic> json) =>
      ProfileDataResponse(
        message: json[ApiParameters.message] as String?,
        user: json[ApiParameters.user] != null
            ? UserModel.fromJson(
                json[ApiParameters.user] as Map<String, dynamic>,
              )
            : null,
      );
}
