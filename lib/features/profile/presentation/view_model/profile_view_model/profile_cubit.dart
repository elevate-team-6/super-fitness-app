import 'package:injectable/injectable.dart';
import 'package:super_fitness/config/base_cubit/base_cubit.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/config/base_state/base_state.dart';
import 'package:super_fitness/config/base_ui_event/base_ui_event.dart';
import 'package:super_fitness/features/auth/domain/entities/user_entity.dart';
import 'package:super_fitness/features/profile/domain/use_cases/get_cached_user_use_case.dart';
import 'package:super_fitness/features/profile/domain/use_cases/get_profile_data_use_case.dart';
import 'package:super_fitness/features/profile/presentation/view_model/profile_view_model/profile_event.dart';
import 'package:super_fitness/features/profile/presentation/view_model/profile_view_model/profile_state.dart';

@injectable
class ProfileCubit extends BaseCubit<ProfileState, BaseUiEvent> {
  final GetCachedUserUseCase _getCachedUserUseCase;

  final GetProfileDataUseCase _getProfileDataUseCase;

  ProfileCubit(this._getCachedUserUseCase, this._getProfileDataUseCase)
    : super(const ProfileState());

  void doIntent(ProfileEvents event) {
    switch (event) {
      case LoadProfileEvent():
        _loadProfile();
      case RefreshProfileEvent():
        _fetchProfile();
    }
  }

  /// Only the first visit pays for the network — once the user is cached the
  /// tab opens straight onto it, so no shimmer either.
  Future<void> _loadProfile() async {
    final cachedUser = await _getCachedUserUseCase();

    if (isClosed) return;

    if (cachedUser != null) {
      emit(state.copyWith(profileState: BaseState(data: cachedUser)));
      return;
    }

    emit(state.copyWith(profileState: const BaseState(isLoading: true)));

    await _fetchProfile();
  }

  /// Goes past the cache — the fetched user replaces it. Runs without a
  /// loading state so a refresh doesn't flash the header back to a shimmer.
  Future<void> _fetchProfile() async {
    final response = await _getProfileDataUseCase();

    if (isClosed) return;

    switch (response) {
      case SuccessBaseResponse<UserEntity>():
        emit(state.copyWith(profileState: BaseState(data: response.data)));

      case ErrorBaseResponse<UserEntity>():
        // The header keeps whatever it was already showing; the failure is a
        // one-off message rather than a permanent empty state.
        emit(
          state.copyWith(
            profileState: BaseState(
              data: state.profileState.data,
              errorMessage: response.errorMessage,
            ),
          ),
        );
        emitUiEvent(DisplayErrorEvent(response.errorMessage));
    }
  }
}
