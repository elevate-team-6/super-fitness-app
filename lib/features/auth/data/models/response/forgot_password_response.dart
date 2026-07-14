import 'package:equatable/equatable.dart';
import 'package:super_fitness/features/auth/domain/entities/forget_password_entity.dart';
class ForgetPasswordResponse extends Equatable {
  final String? message;
  final String? info;
  final String? statusMsg;

  const ForgetPasswordResponse({this.message, this.info, this.statusMsg});

  factory ForgetPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ForgetPasswordResponse(
      message: json['message'] as String?,
      info: json['info'] as String?,
      statusMsg: json['statusMsg'] as String?,
    );
  }
  ForgetPasswordEntity toEntity() => ForgetPasswordEntity(
    message: message ?? '',
    info: info ?? '',
    statusMsg: statusMsg ?? '',
    status: '',
    token: '',
  );

  @override
  List<Object?> get props => [message, info, statusMsg];
}