import 'package:equatable/equatable.dart';

sealed class ProfileEvents extends Equatable {
  const ProfileEvents();

  @override
  List<Object?> get props => [];
}

class LoadProfileEvent extends ProfileEvents {
  final bool isFromRemote;
  const LoadProfileEvent({this.isFromRemote = false});

  @override
  List<Object?> get props => [isFromRemote];
}

class LogoutEvent extends ProfileEvents {
  const LogoutEvent();
}
