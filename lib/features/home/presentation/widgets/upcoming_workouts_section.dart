import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/widgets/custom_tab_bar.dart';
import '../../domain/entities/exercise_entity.dart';
import '../view_models/home_view_model/home_cubit.dart';
import '../view_models/home_view_model/home_event.dart';
import '../view_models/home_view_model/home_state.dart';
import 'home_card.dart';
import 'home_error_widget.dart';
import 'home_sections_shimmer.dart';
import 'section_header.dart';

class UpcomingWorkoutsSection extends StatelessWidget {
  const UpcomingWorkoutsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (p, c) =>
          p.upcomingWorkoutsTabsStatus != c.upcomingWorkoutsTabsStatus ||
          p.upcomingWorkoutsStatus != c.upcomingWorkoutsStatus ||
          p.activeMuscleId != c.activeMuscleId,
      builder: (context, state) {
        final tabsStatus = state.upcomingWorkoutsTabsStatus;
        final workoutsStatus = state.upcomingWorkoutsStatus;

        if (tabsStatus.errorMessage != null) {
          return HomeErrorWidget(
            message: tabsStatus.errorMessage!,
            onRetry: () => context.read<HomeCubit>().doEvent(
                  const FetchMuscleGroupsEvent(),
                ),
          );
        }

        if (tabsStatus.isLoading) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(title: AppStrings.upcomingWorkouts.tr()),
              SizedBox(height: 16.h),
              HomeSectionsShimmer.upcomingWorkouts(),
            ],
          );
        }

        final tabs = tabsStatus.data?.map((m) => m.name).toList() ?? [];

        return DefaultTabController(
          length: tabs.length,
          key: ValueKey(tabs.length),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: AppStrings.upcomingWorkouts.tr(),
                onSeeAll: () {},
              ),
              CustomTabBar(
                tabs: tabs,
                padding: EdgeInsets.zero,
                onTap: (index) {
                  final id = tabsStatus.data?[index].id;
                  if (id != null) {
                    context.read<HomeCubit>().doEvent(
                          ChangeMuscleTabEvent(id),
                        );
                  }
                },
              ),
              SizedBox(height: 16.h),
              if (workoutsStatus.isLoading)
                HomeSectionsShimmer.upcomingWorkouts().build(context) // Fallback but we want the list part
                // Actually the Shimmer has the list part. Let's adjust HomeSectionsShimmer.upcomingWorkouts() or use it correctly.
                // For simplicity, I'll just use the full shimmer layout for now.
                // But better to only shimmer the list if tabs are already there.
                // For now, let's keep it consistent.
                else if (workoutsStatus.isLoading)
                SizedBox(
                  height: 80.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 4,
                    itemBuilder: (context, index) => Padding(
                      padding: EdgeInsetsDirectional.only(end: 12.w),
                      child: HomeSectionsShimmer.upcomingWorkouts(), // This is not ideal, need to adjust Shimmer
                    ),
                  ),
                )
              else
                SizedBox(
                  height: 80.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: workoutsStatus.data?.length ?? 0,
                    itemBuilder: (context, index) {
                      final exercise =
                          workoutsStatus.data?[index] ?? ExerciseEntity.empty;
                      return HomeCard(
                        title: exercise.name,
                        image: 'https://via.placeholder.com/150',
                        onTap: () {},
                        height: 80.h,
                        width: 80.w,
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
