import 'package:equatable/equatable.dart';
import 'package:super_fitness/features/auth/domain/entities/forget_password_entity.dart';

class VerifyResetCodeResponse extends Equatable {
  final String? status;
  final String? message;

  const VerifyResetCodeResponse({this.status, this.message});

  factory VerifyResetCodeResponse.fromJson(Map<String, dynamic> json) {
    return VerifyResetCodeResponse(
      status: json['status'] as String?,
      message: json['message'] as String?,
    );
  }

  ForgetPasswordEntity toEntity() => ForgetPasswordEntity(
    status: status ?? '',
    message: message ?? '',
    info: '',
    statusMsg: '',
    token: '',
  );

  @override
  List<Object?> get props => [status, message];
}
