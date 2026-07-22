import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/base_ui_handler/ui_event_handler_mixin.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../domain/entities/home_user_entity.dart';
import '../view_models/home_view_model/home_cubit.dart';
import '../view_models/home_view_model/home_event.dart';
import '../view_models/home_view_model/home_state.dart';
import '../widgets/home_category_icons.dart';
import '../widgets/home_profile_image.dart';
import '../widgets/home_sections_shimmer.dart';
import '../widgets/popular_training_section.dart';
import '../widgets/recommendation_for_you_section.dart';
import '../widgets/recommendation_today_section.dart';
import '../widgets/upcoming_workouts_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with UiEventHandler {
  StreamSubscription? _uiEventSubscription;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<HomeCubit>();
    _uiEventSubscription = cubit.eventStream.listen(handleUiEvent);
  }

  @override
  void dispose() {
    _uiEventSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (p, c) => p.homeUserStatus != c.homeUserStatus,
      builder: (context, state) {
        final status = state.homeUserStatus;
        final user = status.data ?? HomeUserEntity.empty;

        return AppScaffold(
          backgroundImage: AppImages.homeBackground,
          appBar: CustomAppBar(
            centerTitle: false,
            title: status.isLoading
                ? HomeSectionsShimmer.userInfoShimmer()
                : AppStrings.hi.tr(args: [user.name]),
            subtitle: status.isLoading
                ? null
                : AppStrings.letsStartYourDay.tr(),
            actions: [
              HomeProfileImage(
                userPhoto: user.image,
                isLoading: status.isLoading,
              ),
            ],
          ),
          body: SafeArea(
            bottom: false,
            child: RefreshIndicator(
              onRefresh: () async => context.read<HomeCubit>().doEvent(
                const FetchAllHomeDataEvent(),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 16.w,
                  right: 16.w,
                  bottom: 100.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const HomeCategoryIcons(),
                    SizedBox(height: 24.h),
                    const RecommendationTodaySection(),
                    SizedBox(height: 16.h),
                    const UpcomingWorkoutsSection(),
                    SizedBox(height: 16.h),
                    const RecommendationForYouSection(),
                    SizedBox(height: 24.h),
                    const PopularTrainingSection(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
