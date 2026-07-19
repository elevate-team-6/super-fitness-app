import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'user_model.dart';

part 'signup_response.g.dart';

@JsonSerializable()
class SignupResponse extends Equatable {
  final String? message;
  final String? error;
  final UserModel? user;
  final String? token;

  const SignupResponse({this.message, this.error, this.user, this.token});

  factory SignupResponse.fromJson(Map<String, dynamic> json) =>
      _$SignupResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SignupResponseToJson(this);

  @override
  List<Object?> get props => [message, error, user, token];
}
