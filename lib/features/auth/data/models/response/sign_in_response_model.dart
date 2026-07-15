import 'package:super_fitness/core/utils/app_params.dart';
import 'package:super_fitness/features/auth/data/models/response/user_model.dart';
import 'package:super_fitness/features/auth/domain/entities/sign_in_entity.dart';

class SignInResponseModel {
  final String? message;
  final String? token;
  final UserModel? user;

  const SignInResponseModel({this.message, this.token, this.user});

  factory SignInResponseModel.fromJson(Map<String, dynamic> json) =>
      SignInResponseModel(
        message: json[ApiParameters.message] as String?,
        token: json[ApiParameters.token] as String?,
        user: json[ApiParameters.user] != null
            ? UserModel.fromJson(
                json[ApiParameters.user] as Map<String, dynamic>,
              )
            : null,
      );

  SignInEntity toEntity() =>
      SignInEntity(message: message, token: token, user: user?.toEntity());
}
