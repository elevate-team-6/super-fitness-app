import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:super_fitness/config/base_ui_event/base_ui_event.dart';
import 'package:super_fitness/config/base_ui_handler/ui_event_handler_mixin.dart';
import 'package:super_fitness/config/di/di.dart';
import 'package:super_fitness/core/utils/app_assets.dart';
import 'package:super_fitness/core/utils/app_colors.dart';
import 'package:super_fitness/core/utils/app_constants.dart';
import 'package:super_fitness/core/utils/app_routes.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/core/utils/app_text_styles.dart';
import 'package:super_fitness/core/widgets/app_scaffold.dart';
import 'package:super_fitness/core/widgets/custom_glass_container.dart';
import 'package:super_fitness/features/profile/presentation/view_model/profile_view_model/profile_cubit.dart';
import 'package:super_fitness/features/profile/presentation/view_model/profile_view_model/profile_event.dart';
import 'package:super_fitness/features/profile/presentation/view_model/profile_view_model/profile_state.dart';
import 'package:super_fitness/features/profile/presentation/widgets/profile_header.dart';
import 'package:super_fitness/features/profile/presentation/widgets/profile_menu_item.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProfileCubit>()..doIntent(const LoadProfileEvent()),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatefulWidget {
  const _ProfileView();

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> with UiEventHandler {
  static const _nameSkeleton = 'Firstname Lastname';

  StreamSubscription<BaseUiEvent>? _sideEffectSubscription;

  @override
  void initState() {
    super.initState();
    _sideEffectSubscription = context.read<ProfileCubit>().eventStream.listen(
      handleUiEvent,
    );
  }

  @override
  void dispose() {
    _sideEffectSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic =
        Localizations.localeOf(context).languageCode == AppConstants.arabicCode;
    final nextLocale = Locale(
      isArabic ? AppConstants.englishCode : AppConstants.arabicCode,
    );
    final divider = Divider(
      height: 1,
      thickness: 1,
      indent: 16,
      endIndent: 16,
      color: AppColors.white.withValues(alpha: 0.08),
    );

    return AppScaffold(
      backgroundImage: AppImages.homeBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 120.h),
          child: Column(
            children: [
              Text(AppStrings.profile.tr(), style: AppTextStyles.white24700),
              SizedBox(height: 24.h),

              BlocBuilder<ProfileCubit, ProfileState>(
                builder: (context, state) {
                  final isLoading = state.profileState.isLoading;

                  return Skeletonizer(
                    enabled: isLoading,
                    child: ProfileHeader(
                      name: isLoading ? _nameSkeleton : state.fullName,
                      photo: state.photo,
                    ),
                  );
                },
              ),
              SizedBox(height: 32.h),

              CustomGlassContainer(
                blur: 20,
                opacity: 0.5,
                border: Border.all(
                  color: AppColors.white.withValues(alpha: 0.08),
                ),
                padding: EdgeInsets.zero,
                borderRadius: BorderRadius.circular(24.r),
                child: Column(
                  children: [
                    ProfileMenuItem(
                      icon: Icons.person_outline,
                      label: AppStrings.editProfile.tr(),
                      // TODO(team): point this at the edit profile route and
                      // refresh on the way back, so the header picks up the
                      // saved values:
                      //   await Navigator.pushNamed(context, AppRoutes.editProfile);
                      //   if (!mounted) return;
                      //   context.read<ProfileCubit>()
                      //       .doIntent(const RefreshProfileEvent());
                      // That refresh re-reads the cache, so the save has to
                      // write the updated user there — same as
                      // AuthRepoImpl._cacheUser does at sign-in.
                    ),
                    divider,
                    ProfileMenuItem(
                      icon: Icons.lock_outline,
                      label: AppStrings.changePassword.tr(),
                      onTap: () => Navigator.of(
                        context,
                      ).pushNamed(AppRoutes.changePassword),
                    ),
                    divider,
                    ProfileMenuItem(
                      icon: Icons.language_outlined,
                      label: AppStrings.selectLanguage.tr(),
                      highlight:
                          (isArabic ? AppStrings.arabic : AppStrings.english)
                              .tr(),
                      trailing: Transform.scale(
                        scale: 0.85,
                        child: Switch(
                          value: !isArabic,
                          onChanged: (_) => context.setLocale(nextLocale),
                        ),
                      ),
                      onTap: () => context.setLocale(nextLocale),
                    ),
                    divider,
                    ProfileMenuItem(
                      icon: Icons.shield_outlined,
                      label: AppStrings.security.tr(),
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.webView,
                        arguments: WebViewArgs(
                          title: AppStrings.security.tr(),
                          url: AppConstants.securityUrl,
                        ),
                      ),
                    ),
                    divider,
                    ProfileMenuItem(
                      icon: Icons.privacy_tip_outlined,
                      label: AppStrings.privacyPolicy.tr(),
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.webView,
                        arguments: WebViewArgs(
                          title: AppStrings.privacyPolicy.tr(),
                          url: AppConstants.privacyPolicyUrl,
                        ),
                      ),
                    ),
                    divider,
                    ProfileMenuItem(
                      icon: Icons.help_outline,
                      label: AppStrings.help.tr(),
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.webView,
                        arguments: WebViewArgs(
                          title: AppStrings.help.tr(),
                          url: AppConstants.helpUrl,
                        ),
                      ),
                    ),
                    divider,
                    ProfileMenuItem(
                      icon: Icons.logout,
                      label: AppStrings.logout.tr(),
                      isHighlighted: true,
                      // TODO(team): wire to AuthService.logout + back to login.
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
