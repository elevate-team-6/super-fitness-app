import 'package:super_fitness/core/utils/app_params.dart';

class LogoutResponseModel {
  final String? message;

  const LogoutResponseModel({this.message});

  factory LogoutResponseModel.fromJson(Map<String, dynamic> json) =>
      LogoutResponseModel(
        message: json[ApiParameters.message] as String?,
      );
}
