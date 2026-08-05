import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:super_fitness/config/base_ui_event/base_ui_event.dart';
import 'package:super_fitness/config/base_ui_handler/ui_event_handler_mixin.dart';
import 'package:super_fitness/core/utils/app_assets.dart';
import 'package:super_fitness/core/utils/app_routes.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/core/utils/app_text_styles.dart';
import 'package:super_fitness/core/widgets/animated_state_switcher.dart';
import 'package:super_fitness/core/widgets/app_scaffold.dart';
import 'package:super_fitness/core/widgets/custom_grid_view.dart';
import 'package:super_fitness/core/widgets/custom_tab_bar.dart';
import 'package:super_fitness/features/home/presentation/widgets/home_error_widget.dart';
import 'package:super_fitness/features/home/presentation/widgets/home_sections_shimmer.dart';

import '../view_models/workouts_view_model/workouts_cubit.dart';
import '../view_models/workouts_view_model/workouts_events.dart';
import '../view_models/workouts_view_model/workouts_state.dart';
import '../widgets/muscle_grid_item.dart';

class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> with UiEventHandler {
  late final StreamSubscription<BaseUiEvent> _uiEventSubscription;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<WorkoutsCubit>();
    _uiEventSubscription = cubit.eventStream.listen(handleUiEvent);
    cubit.doEvent(GetMuscleGroupsEvent());
  }

  @override
  void dispose() {
    _uiEventSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundImage: AppImages.onboardingBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
              child: Text(
                AppStrings.workouts.tr(),
                style: AppTextStyles.white24500,
              ),
            ),
            const _MuscleGroupsTabs(),
            SizedBox(height: 16.h),
            const Expanded(child: _MusclesGrid()),
          ],
        ),
      ),
    );
  }
}

// The grid's message states need keys to help AnimatedSwitcher
enum _MusclesContent { loading, error, empty, data }

class _MuscleGroupsTabs extends StatelessWidget {
  const _MuscleGroupsTabs();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkoutsCubit, WorkoutsState>(
      buildWhen: (previous, current) =>
          previous.muscleGroupsState != current.muscleGroupsState ||
          previous.selectedMuscleGroupId != current.selectedMuscleGroupId,
      builder: (context, state) {
        final groups = state.muscleGroupsState.data ?? [];

        final Widget content;

        if (state.muscleGroupsState.isLoading) {
          content = Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: HomeSectionsShimmer.upcomingWorkoutsTabs(),
          );
        } else if (state.muscleGroupsState.errorMessage != null ||
            groups.isEmpty) {
          content = const SizedBox.shrink();
        } else {
          final selectedIndex = groups.indexWhere(
            (g) => g.id == state.selectedMuscleGroupId,
          );

          content = DefaultTabController(
            length: groups.length,
            initialIndex: selectedIndex != -1 ? selectedIndex : 0,
            child: CustomTabBar(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              tabs: groups.map((group) => group.name).toList(),
              onTap: (index) {
                context.read<WorkoutsCubit>().doEvent(
                  GetMusclesByGroupIdEvent(groups[index].id),
                );
              },
            ),
          );
        }

        return AnimatedStateSwitcher(child: content);
      },
    );
  }
}

class _MusclesGrid extends StatelessWidget {
  const _MusclesGrid();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkoutsCubit, WorkoutsState>(
      buildWhen: (previous, current) =>
          previous.musclesState != current.musclesState ||
          previous.selectedMuscleGroupId != current.selectedMuscleGroupId,
      builder: (context, state) {
        final musclesState = state.musclesState;
        final muscles = musclesState.data ?? [];

        final Widget content;

        if (musclesState.isLoading) {
          content = CustomGridView(
            key: const ValueKey(_MusclesContent.loading),
            itemCount: 6,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemBuilder: (context, index) =>
                HomeSectionsShimmer.muscleGridItemShimmer(),
          );
        } else if (musclesState.errorMessage != null) {
          content = HomeErrorWidget(
            key: const ValueKey(_MusclesContent.error),
            message: musclesState.errorMessage!,
            onRetry: () {
              final cubit = context.read<WorkoutsCubit>();
              if (state.muscleGroupsState.errorMessage != null) {
                cubit.doEvent(GetMuscleGroupsEvent());
              } else {
                cubit.doEvent(
                  GetMusclesByGroupIdEvent(state.selectedMuscleGroupId ?? ''),
                );
              }
            },
          );
        } else if (muscles.isEmpty) {
          content = Center(
            key: const ValueKey(_MusclesContent.empty),
            child: Text(
              AppStrings.noMusclesFound.tr(),
              style: AppTextStyles.white16500,
            ),
          );
        } else {
          content = CustomGridView(
            key: const ValueKey(_MusclesContent.data),
            itemCount: muscles.length,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemBuilder: (context, index) {
              final muscle = muscles[index];
              return MuscleGridItem(
                muscle: muscle,
                onTap: () {
                  Navigator.of(context).pushNamed(
                    AppRoutes.exerciseScreen,
                    arguments: ExerciseArgs(
                      primeMoverMuscleId: muscle.id,
                      primeMoverMuscleName: muscle.name,
                    ),
                  );
                },
              );
            },
          );
        }

        return AnimatedStateSwitcher(child: content);
      },
    );
  }
}
