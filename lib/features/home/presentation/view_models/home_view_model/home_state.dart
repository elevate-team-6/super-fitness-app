import 'package:equatable/equatable.dart';
import '../../../../../config/base_state/base_state.dart';
import '../../../domain/entities/exercise_entity.dart';
import '../../../domain/entities/meal_category_entity.dart';
import '../../../domain/entities/muscle_entity.dart';

class HomeState extends Equatable {
  final BaseState<List<ExerciseEntity>> recommendationTodayStatus;
  final BaseState<List<MuscleEntity>> upcomingWorkoutsTabsStatus;
  final BaseState<List<ExerciseEntity>> upcomingWorkoutsStatus;
  final BaseState<List<MealCategoryEntity>> recommendationForYouTabsStatus;
  final BaseState<List<ExerciseEntity>> popularTrainingStatus;

  final String activeMuscleId;
  final String activeMealCategoryId;

  const HomeState({
    this.recommendationTodayStatus = const BaseState(),
    this.upcomingWorkoutsTabsStatus = const BaseState(),
    this.upcomingWorkoutsStatus = const BaseState(),
    this.recommendationForYouTabsStatus = const BaseState(),
    this.popularTrainingStatus = const BaseState(),
    this.activeMuscleId = '',
    this.activeMealCategoryId = '',
  });

  HomeState copyWith({
    BaseState<List<ExerciseEntity>>? recommendationTodayStatus,
    BaseState<List<MuscleEntity>>? upcomingWorkoutsTabsStatus,
    BaseState<List<ExerciseEntity>>? upcomingWorkoutsStatus,
    BaseState<List<MealCategoryEntity>>? recommendationForYouTabsStatus,
    BaseState<List<ExerciseEntity>>? popularTrainingStatus,
    String? activeMuscleId,
    String? activeMealCategoryId,
  }) {
    return HomeState(
      recommendationTodayStatus:
          recommendationTodayStatus ?? this.recommendationTodayStatus,
      upcomingWorkoutsTabsStatus:
          upcomingWorkoutsTabsStatus ?? this.upcomingWorkoutsTabsStatus,
      upcomingWorkoutsStatus:
          upcomingWorkoutsStatus ?? this.upcomingWorkoutsStatus,
      recommendationForYouTabsStatus:
          recommendationForYouTabsStatus ?? this.recommendationForYouTabsStatus,
      popularTrainingStatus:
          popularTrainingStatus ?? this.popularTrainingStatus,
      activeMuscleId: activeMuscleId ?? this.activeMuscleId,
      activeMealCategoryId: activeMealCategoryId ?? this.activeMealCategoryId,
    );
  }

  @override
  List<Object?> get props => [
        recommendationTodayStatus,
        upcomingWorkoutsTabsStatus,
        upcomingWorkoutsStatus,
        recommendationForYouTabsStatus,
        popularTrainingStatus,
        activeMuscleId,
        activeMealCategoryId,
      ];
}
