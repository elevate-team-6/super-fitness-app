import 'package:injectable/injectable.dart';
import 'package:super_fitness/config/base_cubit/base_cubit.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/config/base_state/base_state.dart';
import 'package:super_fitness/config/base_ui_event/base_ui_event.dart';
import 'package:super_fitness/core/utils/app_routes.dart';
import 'package:super_fitness/features/auth/domain/use_cases/logout_use_case.dart';
import 'package:super_fitness/features/profile/domain/use_cases/get_cached_user_use_case.dart';
import 'package:super_fitness/features/profile/presentation/view_model/profile_view_model/profile_event.dart';
import 'package:super_fitness/features/profile/presentation/view_model/profile_view_model/profile_state.dart';

@injectable
class ProfileCubit extends BaseCubit<ProfileState, BaseUiEvent> {
  final GetCachedUserUseCase _getCachedUserUseCase;
  final LogoutUseCase _logoutUseCase;

  ProfileCubit(this._getCachedUserUseCase, this._logoutUseCase)
    : super(const ProfileState());

  void doIntent(ProfileEvents event) {
    switch (event) {
      case LoadProfileEvent():
        _loadProfile();
      case RefreshProfileEvent():
        _loadProfile(showLoading: false);
      case LogoutEvent():
        _logout();
    }
  }

  Future<void> _loadProfile({bool showLoading = true}) async {
    if (showLoading) {
      emit(state.copyWith(profileState: const BaseState(isLoading: true)));
    }

    final user = await _getCachedUserUseCase();

    if (isClosed) return;

    emit(state.copyWith(profileState: BaseState(data: user)));
  }

  Future<void> _logout() async {
    emitUiEvent(ShowLoadingEvent());

    await _logoutUseCase();

    emitUiEvent(HideLoadingEvent());

    emitUiEvent(
      NavigateEvent(
        AppRoutes.login,
        navigationType: NavigationType.pushAndRemoveUntil,
        predicate: (_) => false,
      ),
    );
  }
}
