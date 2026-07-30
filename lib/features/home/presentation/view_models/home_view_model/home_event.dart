sealed class HomeEvent {
  const HomeEvent();
}

class FetchAllHomeDataEvent extends HomeEvent {
  const FetchAllHomeDataEvent();
}

class FetchHomeUserEvent extends HomeEvent {
  const FetchHomeUserEvent();
}

class FetchRandomExercisesEvent extends HomeEvent {
  const FetchRandomExercisesEvent();
}

class FetchMuscleGroupsEvent extends HomeEvent {
  const FetchMuscleGroupsEvent();
}

class FetchMealCategoriesEvent extends HomeEvent {
  const FetchMealCategoriesEvent();
}

class FetchPopularExercisesEvent extends HomeEvent {
  const FetchPopularExercisesEvent();
}

class ChangeMuscleTabEvent extends HomeEvent {
  final String muscleId;
  const ChangeMuscleTabEvent(this.muscleId);
}
