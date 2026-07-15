import 'package:super_fitness/core/utils/app_params.dart';
import 'package:super_fitness/features/auth/domain/entities/user_entity.dart';

class UserModel {
  final String? id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? gender;
  final int? age;
  final num? weight;
  final num? height;
  final String? activityLevel;
  final String? goal;
  final String? photo;
  final String? createdAt;

  const UserModel({
    this.id,
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
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json[ApiParameters.id] as String?,
    firstName: json[ApiParameters.firstName] as String?,
    lastName: json[ApiParameters.lastName] as String?,
    email: json[ApiParameters.email] as String?,
    gender: json[ApiParameters.gender] as String?,
    age: json[ApiParameters.age] as int?,
    weight: json[ApiParameters.weight] as num?,
    height: json[ApiParameters.height] as num?,
    activityLevel: json[ApiParameters.activityLevel] as String?,
    goal: json[ApiParameters.goal] as String?,
    photo: json[ApiParameters.photo] as String?,
    createdAt: json[ApiParameters.createdAt] as String?,
  );

  Map<String, dynamic> toJson() => {
    ApiParameters.id: id,
    ApiParameters.firstName: firstName,
    ApiParameters.lastName: lastName,
    ApiParameters.email: email,
    ApiParameters.gender: gender,
    ApiParameters.age: age,
    ApiParameters.weight: weight,
    ApiParameters.height: height,
    ApiParameters.activityLevel: activityLevel,
    ApiParameters.goal: goal,
    ApiParameters.photo: photo,
    ApiParameters.createdAt: createdAt,
  };

  UserEntity toEntity() => UserEntity(
    id: id,
    firstName: firstName,
    lastName: lastName,
    email: email,
    gender: gender,
    age: age,
    weight: weight,
    height: height,
    activityLevel: activityLevel,
    goal: goal,
    photo: photo,
    createdAt: createdAt,
  );
}
