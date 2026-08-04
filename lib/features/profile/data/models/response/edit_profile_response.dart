import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:super_fitness/features/auth/data/models/response/user_model.dart';

part 'edit_profile_response.g.dart';

@JsonSerializable()
class EditProfileResponse extends Equatable {
  final String? message;
  final UserModel? user;

  const EditProfileResponse({this.message, this.user});

  factory EditProfileResponse.fromJson(Map<String, dynamic> json) =>
      _$EditProfileResponseFromJson(json);

  Map<String, dynamic> toJson() => _$EditProfileResponseToJson(this);

  @override
  List<Object?> get props => [message, user];
}
