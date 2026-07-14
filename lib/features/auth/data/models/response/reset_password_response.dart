import 'package:equatable/equatable.dart';
import 'package:super_fitness/features/auth/domain/entities/forget_password_entity.dart';

class ResetPasswordResponse extends Equatable {
  final String? message;
  final String? token;

  const ResetPasswordResponse({this.message, this.token});

  factory ResetPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ResetPasswordResponse(
      message: json['message'] as String?,
      token: json['token'] as String?,
    );
  }

  ForgetPasswordEntity toEntity() => ForgetPasswordEntity(
    message: message ?? '',
    token: token ?? '',
    info: '',
    statusMsg: '',
    status: '',
  );

  @override
  List<Object?> get props => [message, token];
}
