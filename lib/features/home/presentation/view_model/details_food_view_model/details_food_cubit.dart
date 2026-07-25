import 'package:injectable/injectable.dart';
import 'package:super_fitness/config/base_cubit/base_cubit.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/config/base_state/base_state.dart';
import 'package:super_fitness/config/base_ui_event/base_ui_event.dart';
import 'package:super_fitness/core/utils/youtube_url.dart';
import 'package:super_fitness/features/home/domain/entities/details_food_entity.dart';
import 'package:super_fitness/features/home/domain/use_cases/get_details_food_use_case.dart';
import 'package:super_fitness/features/home/presentation/view_model/details_food_view_model/details_food_event.dart';
import 'package:super_fitness/features/home/presentation/view_model/details_food_view_model/details_food_state.dart';

@injectable
class DetailsFoodCubit extends BaseCubit<DetailsFoodState, BaseUiEvent> {
  final GetDetailsFoodUseCase _getDetailsFoodUseCase;

  DetailsFoodCubit(this._getDetailsFoodUseCase)
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
    final url = YoutubeUrl.watchUrlOf(state.detailsState.data?.youtubeUrl);
    if (url != null) emitUiEvent(OpenUrlEvent(url));
  }

  /// Called by the route right after construction, before the first intent.
  void setMealId(String id) => emit(state.copyWith(mealId: id));

  Future<void> _loadDetails() async {
    emit(state.copyWith(detailsState: const BaseState(isLoading: true)));

    final result = await _getDetailsFoodUseCase(state.mealId);

    if (isClosed) return;

    switch (result) {
      case SuccessBaseResponse<DetailsFoodEntity>():
        final details = result.data;

        // A success with no payload can't be rendered, so downgrade it to an
        // error; the empty message lets the screen fall back to its default.
        if (details == null) {
          emit(state.copyWith(detailsState: const BaseState(errorMessage: '')));
          return;
        }

        emit(state.copyWith(detailsState: BaseState(data: details)));

      case ErrorBaseResponse<DetailsFoodEntity>():
        emit(
          state.copyWith(
            detailsState: BaseState(errorMessage: result.errorMessage),
          ),
        );
    }
  }
}
