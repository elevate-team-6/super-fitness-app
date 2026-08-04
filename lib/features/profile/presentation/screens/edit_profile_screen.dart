import 'dart:async';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:super_fitness/config/base_ui_event/base_ui_event.dart';
import 'package:super_fitness/config/base_ui_handler/ui_event_handler_mixin.dart';
import 'package:super_fitness/config/validations/app_validations.dart';
import 'package:super_fitness/core/utils/app_assets.dart';
import 'package:super_fitness/core/utils/app_routes.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/core/utils/app_text_styles.dart';
import 'package:super_fitness/core/widgets/app_scaffold.dart';
import 'package:super_fitness/core/widgets/custom_app_bar.dart';
import 'package:super_fitness/core/widgets/custom_text_field.dart';
import 'package:super_fitness/features/auth/domain/entities/user_entity.dart';
import 'package:super_fitness/features/profile/domain/entities/complete_register_mode.dart';
import 'package:super_fitness/features/profile/domain/entities/edit_profile_section.dart';
import 'package:super_fitness/features/profile/presentation/view_model/edit_profile_view_model/edit_profile_cubit.dart';
import 'package:super_fitness/features/profile/presentation/view_model/edit_profile_view_model/edit_profile_event.dart';
import 'package:super_fitness/features/profile/presentation/view_model/edit_profile_view_model/edit_profile_state.dart';
import 'package:super_fitness/features/profile/presentation/widgets/edit_profile_avatar.dart';
import 'package:super_fitness/features/profile/presentation/widgets/tappable_edit_field.dart';

class EditProfileScreen extends StatefulWidget {
  final UserEntity user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with UiEventHandler {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  StreamSubscription<BaseUiEvent>? _sideEffectSubscription;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(
      text: widget.user.firstName ?? '',
    );
    _lastNameController = TextEditingController(
      text: widget.user.lastName ?? '',
    );
    _emailController = TextEditingController(text: widget.user.email ?? '');

    _sideEffectSubscription = context
        .read<EditProfileCubit>()
        .eventStream
        .listen(handleUiEvent);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _sideEffectSubscription?.cancel();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null && mounted) {
      context.read<EditProfileCubit>().doEvent(
        UpdateImageEvent(File(picked.path)),
      );
    }
  }

  Future<void> _navigateToSection(EditProfileSection section) async {
    final cubit = context.read<EditProfileCubit>();
    await Navigator.pushNamed(
      context,
      AppRoutes.completeRegister,
      arguments: CompleteRegisterArgs(
        mode: CompleteRegisterMode.edit,
        section: section,
        editProfileCubit: cubit,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundImage: AppImages.authBackground,
      appBar: CustomAppBar(
        title: AppStrings.editProfile.tr(),
        onBackPressed: () => Navigator.pop(context),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
          child: BlocBuilder<EditProfileCubit, EditProfileState>(
            builder: (context, state) {
              final fullName = '${state.firstName} ${state.lastName}'.trim();

              return Form(
                key: _formKey,
                child: Column(
                  children: [
                    EditProfileAvatar(
                      name: fullName,
                      photoUrl: state.originalUser?.photo ?? '',
                      selectedImage: state.selectedImage,
                      onPickImage: _pickImage,
                    ),
                    SizedBox(height: 24.h),
                    CustomTextField(
                      controller: _firstNameController,
                      hintText: AppStrings.firstName.tr(),
                      prefixIconPath: AppIcons.person,
                      validator: AppValidations.validateFirstName,
                      onChanged: (val) {
                        context.read<EditProfileCubit>().doEvent(
                          UpdateFirstNameEvent(val),
                        );
                      },
                    ),
                    SizedBox(height: 16.h),
                    CustomTextField(
                      controller: _lastNameController,
                      hintText: AppStrings.lastName.tr(),
                      prefixIconPath: AppIcons.person,
                      validator: AppValidations.validateLastName,
                      onChanged: (val) {
                        context.read<EditProfileCubit>().doEvent(
                          UpdateLastNameEvent(val),
                        );
                      },
                    ),
                    SizedBox(height: 16.h),
                    CustomTextField(
                      controller: _emailController,
                      hintText: AppStrings.email.tr(),
                      prefixIconPath: AppIcons.email,
                      validator: AppValidations.validateEmail,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (val) {
                        context.read<EditProfileCubit>().doEvent(
                          UpdateEmailEvent(val),
                        );
                      },
                    ),
                    SizedBox(height: 24.h),
                    TappableEditField(
                      label: AppStrings.yourWeight.tr(),
                      value: '${state.weight} ${AppStrings.kg.tr()}',
                      onTap: () =>
                          _navigateToSection(EditProfileSection.weight),
                    ),
                    SizedBox(height: 16.h),
                    TappableEditField(
                      label: AppStrings.yourGoal.tr(),
                      value: state.goal.isNotEmpty ? state.goal.tr() : '-',
                      onTap: () => _navigateToSection(EditProfileSection.goal),
                    ),
                    SizedBox(height: 16.h),
                    TappableEditField(
                      label: AppStrings.yourActivityLevel.tr(),
                      value: state.activityLevel.isNotEmpty
                          ? state.activityLevel.tr()
                          : '-',
                      onTap: () =>
                          _navigateToSection(EditProfileSection.activity),
                    ),
                    SizedBox(height: 16.h),
                    TappableEditField(
                      label: AppStrings.yourGender.tr(),
                      value: state.gender.isNotEmpty ? state.gender.tr() : '-',
                      onTap: () =>
                          _navigateToSection(EditProfileSection.gender),
                    ),
                    SizedBox(height: 16.h),
                    TappableEditField(
                      label: AppStrings.yourAge.tr(),
                      value: '${state.age} ${AppStrings.year.tr()}',
                      onTap: () => _navigateToSection(EditProfileSection.age),
                    ),
                    SizedBox(height: 16.h),
                    TappableEditField(
                      label: AppStrings.yourHeight.tr(),
                      value: '${state.height} ${AppStrings.cm.tr()}',
                      onTap: () =>
                          _navigateToSection(EditProfileSection.height),
                    ),
                    SizedBox(height: 32.h),
                    ElevatedButton(
                      onPressed: (state.isFormValid && state.hasChanges)
                          ? () {
                              if (_formKey.currentState?.validate() ?? false) {
                                context.read<EditProfileCubit>().doEvent(
                                  const SaveProfileEvent(),
                                );
                              }
                            }
                          : null,
                      child: Text(
                        AppStrings.update.tr(),
                        style: AppTextStyles.white20500,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
