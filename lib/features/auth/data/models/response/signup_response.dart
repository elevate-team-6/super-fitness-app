import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../domain/entities/user_entity.dart';

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

@JsonSerializable()
class UserModel extends Equatable {
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? gender;
  final int? age;
  final int? weight;
  final int? height;
  final String? activityLevel;
  final String? goal;
  final String? photo;
  @JsonKey(name: '_id')
  final String? id;
  final String? createdAt;

  const UserModel({
    this.firstName,
    this.lastName,
    this.email,
    this.gender,
    this.age,
    this.weight,
    this.height,
    this.activityLevel,
    this.goal,
    this.photo,
    this.id,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  @override
  List<Object?> get props => [
    firstName,
    lastName,
    email,
    gender,
    age,
    weight,
    height,
    activityLevel,
    goal,
    photo,
    id,
    createdAt,
  ];

  UserEntity toEntity() => UserEntity(
    id: id ?? '',
    firstName: firstName ?? '',
    lastName: lastName ?? '',
    email: email ?? '',
    gender: gender ?? '',
    age: age ?? 0,
    weight: weight ?? 0,
    height: height ?? 0,
    activityLevel: activityLevel ?? '',
    goal: goal ?? '',
    photo: photo ?? '',
  );
}
