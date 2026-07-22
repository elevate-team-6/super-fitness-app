import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:super_fitness/core/utils/app_routes.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/widgets/custom_tab_bar.dart';
import '../../../main_layout/presentation/cubit/main_layout_cubit.dart';
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
              HomeSectionsShimmer.upcomingWorkoutsTabs(),
              SizedBox(height: 16.h),
              HomeSectionsShimmer.upcomingWorkoutsList(),
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
                onSeeAll: () {
                  context.read<MainLayoutCubit>().changeTab(2);
                },
              ),
              CustomTabBar(
                tabs: tabs,
                padding: EdgeInsets.zero,
                onTap: (index) {
                  final id = tabsStatus.data?[index].id;
                  if (id != null) {
                    context.read<HomeCubit>().doEvent(ChangeMuscleTabEvent(id));
                  }
                },
              ),
              SizedBox(height: 16.h),
              if (workoutsStatus.isLoading)
                HomeSectionsShimmer.upcomingWorkoutsList()
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
                        image: '',
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.exerciseScreen,
                            arguments: exercise.id,
                          );
                        },
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
