import 'package:equatable/equatable.dart';
import 'package:super_fitness/config/base_state/base_state.dart';
import 'package:super_fitness/features/auth/domain/entities/user_entity.dart';

final class ProfileState extends Equatable {
  final BaseState<UserEntity> profileState;

  const ProfileState({this.profileState = const BaseState()});

  ProfileState copyWith({BaseState<UserEntity>? profileState}) =>
      ProfileState(profileState: profileState ?? this.profileState);

  String get fullName {
    final user = profileState.data;
    if (user == null) return '';

    return '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim();
  }

  String get photo => profileState.data?.photo ?? '';

  @override
  List<Object?> get props => [profileState];
}
