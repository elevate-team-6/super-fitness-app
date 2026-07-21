import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:super_fitness/config/base_cubit/base_cubit.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/config/base_ui_event/base_ui_event.dart';
import 'package:super_fitness/core/utils/youtube_url.dart';
import 'package:super_fitness/features/home/domain/entities/details_food_entity.dart';
import 'package:super_fitness/features/home/domain/entities/meal_nutrition_entity.dart';
import 'package:super_fitness/features/home/domain/use_cases/get_details_food_use_case.dart';
import 'package:super_fitness/features/home/domain/use_cases/get_meal_nutrition_use_case.dart';
import 'package:super_fitness/features/home/presentation/view_model/details_food_view_model/details_food_event.dart';
import 'package:super_fitness/features/home/presentation/view_model/details_food_view_model/details_food_state.dart';

@injectable
class DetailsFoodCubit extends BaseCubit<DetailsFoodState, BaseUiEvent> {
  final GetDetailsFoodUseCase _getDetailsFoodUseCase;
  final GetMealNutritionUseCase _getMealNutritionUseCase;

  String _mealId = '';

  DetailsFoodCubit(this._getDetailsFoodUseCase, this._getMealNutritionUseCase)
    : super(const DetailsFoodState());

  void doIntent(DetailsFoodEvents event) {
    switch (event) {
      case LoadDetailsFoodEvent():
        _loadDetails();
      case OpenMealVideoEvent():
        _openVideo();
    }
  }

  void _openVideo() {
    final url = YoutubeUrl.watchUrlOf(state.details?.youtubeUrl);
    if (url != null) emitUiEvent(OpenUrlEvent(url));
  }

  void setMealId(String id) => _mealId = id;

  Future<void> _loadDetails() async {
    emit(state.copyWith(status: DetailsFoodStatus.loading));

    final result = await _getDetailsFoodUseCase(_mealId);

    if (isClosed) return;

    switch (result) {
      case SuccessBaseResponse<DetailsFoodEntity>():
        final details = result.data;

        if (details == null) {
          emit(state.copyWith(status: DetailsFoodStatus.error));
          return;
        }

        emit(
          state.copyWith(status: DetailsFoodStatus.success, details: details),
        );

        unawaited(_loadNutrition(details));

      case ErrorBaseResponse<DetailsFoodEntity>():
        emit(
          state.copyWith(
            status: DetailsFoodStatus.error,
            errorMessage: result.errorMessage,
          ),
        );
    }
  }

  Future<void> _loadNutrition(DetailsFoodEntity details) async {
    emit(state.copyWith(nutritionStatus: DetailsFoodStatus.loading));

    final result = await _getMealNutritionUseCase(details);

    if (isClosed) return;

    switch (result) {
      case SuccessBaseResponse<MealNutritionEntity>():
        final nutrition = result.data;

        if (nutrition == null) {
          emit(state.copyWith(nutritionStatus: DetailsFoodStatus.error));
          return;
        }

        emit(
          state.copyWith(
            nutritionStatus: DetailsFoodStatus.success,
            nutrition: nutrition,
          ),
        );

      case ErrorBaseResponse<MealNutritionEntity>():
        emit(state.copyWith(nutritionStatus: DetailsFoodStatus.error));
    }
  }
}
