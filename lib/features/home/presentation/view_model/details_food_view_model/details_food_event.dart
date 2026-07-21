import 'package:equatable/equatable.dart';

sealed class DetailsFoodEvents extends Equatable {
  const DetailsFoodEvents();

  @override
  List<Object?> get props => [];
}

class LoadDetailsFoodEvent extends DetailsFoodEvents {
  const LoadDetailsFoodEvent();
}

class OpenMealVideoEvent extends DetailsFoodEvents {
  const OpenMealVideoEvent();
}
