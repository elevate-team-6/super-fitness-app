import 'package:easy_localization/easy_localization.dart';
import 'package:injectable/injectable.dart';
import 'package:super_fitness/config/base_cubit/base_cubit.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/config/base_state/base_state.dart';
import 'package:super_fitness/config/base_ui_event/base_ui_event.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/features/auth/domain/entities/user_entity.dart';
import 'package:super_fitness/features/profile/data/models/request/edit_profile_request.dart';
import 'package:super_fitness/features/profile/domain/use_cases/edit_profile_use_case.dart';
import 'package:super_fitness/features/profile/domain/use_cases/upload_profile_photo_use_case.dart';
import 'package:super_fitness/features/profile/presentation/view_model/edit_profile_view_model/edit_profile_event.dart';
import 'package:super_fitness/features/profile/presentation/view_model/edit_profile_view_model/edit_profile_state.dart';

@injectable
class EditProfileCubit extends BaseCubit<EditProfileState, BaseUiEvent> {
  final EditProfileUseCase _editProfileUseCase;
  final UploadProfilePhotoUseCase _uploadProfilePhotoUseCase;

  EditProfileCubit(this._editProfileUseCase, this._uploadProfilePhotoUseCase)
    : super(const EditProfileState());

  void doEvent(EditProfileEvents event) {
    switch (event) {
      case InitializeProfileEvent():
        _initializeProfile(event.user);
      case UpdateFirstNameEvent():
        emit(state.copyWith(firstName: event.firstName));
      case UpdateLastNameEvent():
        emit(state.copyWith(lastName: event.lastName));
      case UpdateEmailEvent():
        emit(state.copyWith(email: event.email));
      case UpdateImageEvent():
        emit(state.copyWith(selectedImage: event.image));
      case UpdateGenderEvent():
        emit(state.copyWith(gender: event.gender));
      case UpdateAgeEvent():
        emit(state.copyWith(age: event.age));
      case UpdateWeightEvent():
        emit(state.copyWith(weight: event.weight));
      case UpdateHeightEvent():
        emit(state.copyWith(height: event.height));
      case UpdateGoalEvent():
        emit(state.copyWith(goal: event.goal));
      case UpdateActivityEvent():
        emit(state.copyWith(activityLevel: event.activityLevel));
      case SaveProfileEvent():
        _saveProfile();
    }
  }

  void _initializeProfile(UserEntity user) {
    String displayActivityLevel = user.activityLevel ?? '';
    switch (displayActivityLevel) {
      case 'level1':
        displayActivityLevel = AppStrings.sedentary;
      case 'level2':
        displayActivityLevel = AppStrings.lightlyActive;
      case 'level3':
        displayActivityLevel = AppStrings.moderatelyActive;
      case 'level4':
        displayActivityLevel = AppStrings.veryActive;
      case 'level5':
        displayActivityLevel = AppStrings.extraActive;
    }

    emit(
      state.copyWith(
        originalUser: user,
        firstName: user.firstName ?? '',
        lastName: user.lastName ?? '',
        email: user.email ?? '',
        gender: user.gender ?? '',
        age: user.age ?? 20,
        weight: user.weight?.toInt() ?? 70,
        height: user.height?.toInt() ?? 170,
        goal: user.goal ?? '',
        activityLevel: displayActivityLevel,
        clearSelectedImage: true,
      ),
    );
  }

  bool _hasFieldsChanged() {
    final orig = state.originalUser;
    if (orig == null) return false;

    if (state.firstName.trim() != (orig.firstName ?? '').trim()) return true;
    if (state.lastName.trim() != (orig.lastName ?? '').trim()) return true;
    if (state.email.trim() != (orig.email ?? '').trim()) return true;
    if (state.gender != (orig.gender ?? '')) return true;
    if (state.age != (orig.age ?? 20)) return true;
    if (state.weight != (orig.weight?.toInt() ?? 70)) return true;
    if (state.height != (orig.height?.toInt() ?? 170)) return true;
    if (state.goal != (orig.goal ?? '')) return true;

    final currentApiLevel = _mapToApiActivityLevel(state.activityLevel);
    final origApiLevel = _mapToApiActivityLevel(orig.activityLevel ?? '');
    if (currentApiLevel != origApiLevel) return true;

    return false;
  }

  static String _mapToApiActivityLevel(String level) {
    switch (level) {
      case AppStrings.sedentary:
      case 'level1':
        return 'level1';
      case AppStrings.lightlyActive:
      case 'level2':
        return 'level2';
      case AppStrings.moderatelyActive:
      case 'level3':
        return 'level3';
      case AppStrings.veryActive:
      case 'level4':
        return 'level4';
      case AppStrings.extraActive:
      case 'level5':
        return 'level5';
      default:
        return level;
    }
  }

  Future<void> _saveProfile() async {
    if (!state.hasChanges || !state.isFormValid) return;

    final bool hasImage = state.selectedImage != null;
    final bool hasFields = _hasFieldsChanged();

    if (!hasImage && !hasFields) return;

    emit(state.copyWith(updateProfileState: const BaseState(isLoading: true)));
    emitUiEvent(ShowLoadingEvent());

    // Case 1: Only image changed
    if (hasImage && !hasFields) {
      final uploadResult = await _uploadProfilePhotoUseCase(
        state.selectedImage!,
      );
      emitUiEvent(HideLoadingEvent());

      switch (uploadResult) {
        case SuccessBaseResponse<String>():
          emit(
            state.copyWith(
              clearSelectedImage: true,
              updateProfileState: const BaseState(),
            ),
          );
          emitUiEvent(
            DisplaySuccessEvent(uploadResult.data ?? AppStrings.success),
          );
          emitUiEvent(
            NavigateEvent(
              '',
              navigationType: NavigationType.pop,
              arguments: true,
            ),
          );
        case ErrorBaseResponse<String>():
          emit(
            state.copyWith(
              updateProfileState: BaseState(
                errorMessage: uploadResult.errorMessage,
              ),
            ),
          );
          emitUiEvent(DisplayErrorEvent(uploadResult.errorMessage));
      }
      return;
    }

    // Case 3 (First Step): Both image and fields changed -> Upload image first
    if (hasImage && hasFields) {
      final uploadResult = await _uploadProfilePhotoUseCase(
        state.selectedImage!,
      );
      if (uploadResult is ErrorBaseResponse<String>) {
        emitUiEvent(HideLoadingEvent());
        emit(
          state.copyWith(
            updateProfileState: BaseState(
              errorMessage: uploadResult.errorMessage,
            ),
          ),
        );
        emitUiEvent(DisplayErrorEvent(uploadResult.errorMessage));
        return; // Do NOT continue to editProfile if upload fails
      }
      // Clear image since upload succeeded
      emit(state.copyWith(clearSelectedImage: true));
    }

    // Case 2 or Case 3 (Second Step): Call editProfile
    final request = _buildEditProfileRequest();
    final editResult = await _editProfileUseCase(request);
    emitUiEvent(HideLoadingEvent());

    switch (editResult) {
      case SuccessBaseResponse<UserEntity>():
        final updatedUser = editResult.data ?? _buildLocalUpdatedUser();
        emit(
          state.copyWith(
            originalUser: updatedUser,
            updateProfileState: BaseState(data: updatedUser),
          ),
        );
        emitUiEvent(
          DisplaySuccessEvent(AppStrings.profileUpdatedSuccessfully.tr()),
        );
        emitUiEvent(
          NavigateEvent(
            '',
            navigationType: NavigationType.pop,
            arguments: true,
          ),
        );
      case ErrorBaseResponse<UserEntity>():
        emit(
          state.copyWith(
            updateProfileState: BaseState(
              errorMessage: editResult.errorMessage,
            ),
          ),
        );
        emitUiEvent(DisplayErrorEvent(editResult.errorMessage));
    }
  }

  EditProfileRequest _buildEditProfileRequest() {
    final orig = state.originalUser;
    final apiActivityLevel = _mapToApiActivityLevel(state.activityLevel);

    return EditProfileRequest(
      firstName: state.firstName.trim() != (orig?.firstName ?? '').trim()
          ? state.firstName.trim()
          : null,
      lastName: state.lastName.trim() != (orig?.lastName ?? '').trim()
          ? state.lastName.trim()
          : null,
      email: state.email.trim() != (orig?.email ?? '').trim()
          ? state.email.trim()
          : null,
      gender: state.gender != orig?.gender ? state.gender : null,
      age: state.age != (orig?.age ?? 20) ? state.age : null,
      weight: state.weight != (orig?.weight?.toInt() ?? 70)
          ? state.weight
          : null,
      height: state.height != (orig?.height?.toInt() ?? 170)
          ? state.height
          : null,
      goal: state.goal != orig?.goal ? state.goal : null,
      activityLevel: apiActivityLevel != orig?.activityLevel
          ? apiActivityLevel
          : null,
    );
  }

  UserEntity _buildLocalUpdatedUser() {
    final orig = state.originalUser;
    return UserEntity(
      id: orig?.id,
      firstName: state.firstName,
      lastName: state.lastName,
      email: state.email,
      gender: state.gender,
      age: state.age,
      weight: state.weight,
      height: state.height,
      activityLevel: state.activityLevel,
      goal: state.goal,
      photo: orig?.photo,
      createdAt: orig?.createdAt,
    );
  }
}
