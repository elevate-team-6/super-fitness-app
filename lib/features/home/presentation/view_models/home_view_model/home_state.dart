import 'package:equatable/equatable.dart';
import '../../../../../config/base_state/base_state.dart';
import '../../../domain/entities/exercise_entity.dart';
import '../../../domain/entities/home_user_entity.dart';
import '../../../domain/entities/meal_category_entity.dart';
import '../../../domain/entities/muscle_entity.dart';

class HomeState extends Equatable {
  final BaseState<HomeUserEntity> homeUserStatus;
  final BaseState<List<ExerciseEntity>> recommendationTodayStatus;
  final BaseState<List<MuscleEntity>> upcomingWorkoutsTabsStatus;
  final BaseState<List<ExerciseEntity>> upcomingWorkoutsStatus;
  final BaseState<List<MealCategoryEntity>> recommendationForYouTabsStatus;
  final BaseState<List<ExerciseEntity>> popularTrainingStatus;

  final String activeMuscleId;

  const HomeState({
    this.homeUserStatus = const BaseState(),
    this.recommendationTodayStatus = const BaseState(),
    this.upcomingWorkoutsTabsStatus = const BaseState(),
    this.upcomingWorkoutsStatus = const BaseState(),
    this.recommendationForYouTabsStatus = const BaseState(),
    this.popularTrainingStatus = const BaseState(),
    this.activeMuscleId = '',
  });

  HomeState copyWith({
    BaseState<HomeUserEntity>? homeUserStatus,
    BaseState<List<ExerciseEntity>>? recommendationTodayStatus,
    BaseState<List<MuscleEntity>>? upcomingWorkoutsTabsStatus,
    BaseState<List<ExerciseEntity>>? upcomingWorkoutsStatus,
    BaseState<List<MealCategoryEntity>>? recommendationForYouTabsStatus,
    BaseState<List<ExerciseEntity>>? popularTrainingStatus,
    String? activeMuscleId,
  }) {
    return HomeState(
      homeUserStatus: homeUserStatus ?? this.homeUserStatus,
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
    );
  }

  @override
  List<Object?> get props => [
    homeUserStatus,
    recommendationTodayStatus,
    upcomingWorkoutsTabsStatus,
    upcomingWorkoutsStatus,
    recommendationForYouTabsStatus,
    popularTrainingStatus,
    activeMuscleId,
  ];
}
