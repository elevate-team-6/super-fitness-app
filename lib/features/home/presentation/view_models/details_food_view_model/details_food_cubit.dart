import 'package:injectable/injectable.dart';
import 'package:super_fitness/config/base_cubit/base_cubit.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/config/base_state/base_state.dart';
import 'package:super_fitness/config/base_ui_event/base_ui_event.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/core/utils/youtube_url.dart';
import 'package:super_fitness/features/home/domain/entities/details_food_entity.dart';
import 'package:super_fitness/features/home/domain/use_cases/get_details_food_use_case.dart';
import 'package:super_fitness/features/home/presentation/view_models/details_food_view_model/details_food_event.dart';
import 'package:super_fitness/features/home/presentation/view_models/details_food_view_model/details_food_state.dart';

@injectable
class DetailsFoodCubit extends BaseCubit<DetailsFoodState, BaseUiEvent> {
  final GetDetailsFoodUseCase _getDetailsFoodUseCase;

  DetailsFoodCubit(this._getDetailsFoodUseCase)
    : super(const DetailsFoodState());

  void doIntent(DetailsFoodEvents event) {
    switch (event) {
      case LoadDetailsFoodEvent():
        _loadDetails(event.mealId);
      case OpenMealVideoEvent():
        _openVideo();
    }
  }

  void _openVideo() {
    final url = YoutubeUrl.watchUrlOf(state.detailsState.data?.youtubeUrl);
    if (url != null) emitUiEvent(OpenUrlEvent(url));
  }

  Future<void> _loadDetails(String mealId) async {
    emit(
      state.copyWith(
        mealId: mealId,
        detailsState: const BaseState(isLoading: true),
      ),
    );

    final result = await _getDetailsFoodUseCase(mealId);

    if (isClosed) return;

    switch (result) {
      case SuccessBaseResponse<DetailsFoodEntity>():
        final details = result.data;

        if (details == null) {
          emit(
            state.copyWith(
              detailsState: const BaseState(
                errorMessage: AppStrings.detailsFoodNotFound,
              ),
            ),
          );
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
