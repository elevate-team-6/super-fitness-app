import 'package:injectable/injectable.dart';
import 'package:super_fitness/config/base_cubit/base_cubit.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/config/base_ui_event/base_ui_event.dart';
import 'package:super_fitness/features/home/domain/entities/meal_details_entity.dart';
import 'package:super_fitness/features/home/domain/use_cases/get_meal_details_use_case.dart';
import 'package:super_fitness/features/home/presentation/view_model/meal_details_view_model/meal_details_event.dart';
import 'package:super_fitness/features/home/presentation/view_model/meal_details_view_model/meal_details_state.dart';

@injectable
class MealDetailsCubit extends BaseCubit<MealDetailsState, BaseUiEvent> {
  final GetMealDetailsUseCase _getMealDetailsUseCase;

  /// Set by the route before the first load — the screen only ever shows the
  /// one meal it was opened with.
  String _mealId = '';

  MealDetailsCubit(this._getMealDetailsUseCase)
    : super(const MealDetailsState());

  void doIntent(MealDetailsEvents event) {
    switch (event) {
      case LoadMealDetailsEvent():
        _loadDetails();
    }
  }

  /// Called by the route right after construction, before the first intent.
  void setMealId(String id) => _mealId = id;

  Future<void> _loadDetails() async {
    emit(state.copyWith(status: MealDetailsStatus.loading));

    final result = await _getMealDetailsUseCase(_mealId);

    if (isClosed) return;

    switch (result) {
      case SuccessBaseResponse<MealDetailsEntity>():
        final details = result.data;

        // A success with no payload would otherwise leave the screen on
        // `success` with nothing to render.
        if (details == null) {
          emit(state.copyWith(status: MealDetailsStatus.error));
          return;
        }

        emit(
          state.copyWith(status: MealDetailsStatus.success, details: details),
        );

      case ErrorBaseResponse<MealDetailsEntity>():
        emit(
          state.copyWith(
            status: MealDetailsStatus.error,
            errorMessage: result.errorMessage,
          ),
        );
    }
  }
}
