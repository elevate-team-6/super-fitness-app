import 'package:equatable/equatable.dart';

sealed class DetailsFoodEvents extends Equatable {
  const DetailsFoodEvents();

  @override
  List<Object?> get props => [];
}

/// Fetches the meal the screen was opened with — also what the retry button
/// fires, so it carries no id of its own.
class LoadDetailsFoodEvent extends DetailsFoodEvents {
  const LoadDetailsFoodEvent();
}

/// Fired when the user taps the play button — the cubit resolves the loaded
/// meal's YouTube link and asks the screen to open it externally.
class OpenMealVideoEvent extends DetailsFoodEvents {
  const OpenMealVideoEvent();
}
