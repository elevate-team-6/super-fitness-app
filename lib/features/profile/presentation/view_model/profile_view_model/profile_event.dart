import 'package:equatable/equatable.dart';

sealed class ProfileEvents extends Equatable {
  const ProfileEvents();

  @override
  List<Object?> get props => [];
}

class LoadProfileEvent extends ProfileEvents {
  const LoadProfileEvent();
}

class RefreshProfileEvent extends ProfileEvents {
  const RefreshProfileEvent();
}
