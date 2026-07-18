import 'package:equatable/equatable.dart';

class ForgetPasswordEntity extends Equatable {
  // forgot password response fields
  final String? message;
  final String? info;
  final String? statusMsg;

  // verify reset code response fields
  final String? status;
  // reset password response fields
  final String? token;

  const ForgetPasswordEntity({
    this.message,
    this.info,
    this.statusMsg,
    this.status,
    this.token,
  });

  @override
  List<Object?> get props => [message, info, statusMsg, status, token];
}
