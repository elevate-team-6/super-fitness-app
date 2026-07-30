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
import 'package:skeletonizer/skeletonizer.dart';
import 'package:super_fitness/core/widgets/animated_state_switcher.dart';
import 'package:super_fitness/core/widgets/app_scaffold.dart';
import 'package:super_fitness/core/widgets/custom_grid_view.dart';
import 'package:super_fitness/core/widgets/custom_tab_bar.dart';
import '../view_model/workouts_view_model/workouts_cubit.dart';
import '../view_model/workouts_view_model/workouts_events.dart';
import '../view_model/workouts_view_model/workouts_state.dart';
import '../widgets/muscle_grid_item.dart';
import '../widgets/muscle_skeleton_placeholders.dart';

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
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Text(
                AppStrings.workouts.tr(),
                style: AppTextStyles.white24500,
              ),
            ),
            const _MuscleGroupsTabs(),
            const Expanded(child: _MusclesGrid()),
          ],
        ),
      ),
    );
  }
}

// The grid's three message states are all a Center around a Text, so the
// switcher can't tell them apart on type alone the way it can with the rest.
enum _MusclesMessage { error, noGroupSelected, empty }

class _MuscleGroupsTabs extends StatelessWidget {
  const _MuscleGroupsTabs();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkoutsCubit, WorkoutsState>(
      buildWhen: (previous, current) =>
          previous.muscleGroupsState != current.muscleGroupsState,
      builder: (context, state) {
        final groups = state.muscleGroupsState.data ?? [];

        final Widget content;

        if (state.muscleGroupsState.isLoading) {
          content = Skeletonizer(
            child: DefaultTabController(
              length: kSkeletonMuscleGroups.length,
              child: const CustomTabBar(tabs: kSkeletonMuscleGroups),
            ),
          );
        } else if (groups.isEmpty) {
          content = const SizedBox.shrink();
        } else {
          content = DefaultTabController(
            length: groups.length,
            child: CustomTabBar(
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
          content = Skeletonizer(
            child: CustomGridView(
              itemCount: skeletonMuscles.length,
              itemBuilder: (context, index) =>
                  MuscleGridItem(muscle: skeletonMuscles[index]),
            ),
          );
        } else if (musclesState.errorMessage != null && muscles.isEmpty) {
          content = Center(
            key: const ValueKey(_MusclesMessage.error),
            child: Text(
              musclesState.errorMessage!,
              style: AppTextStyles.white16500,
            ),
          );
        } else if (muscles.isEmpty && state.selectedMuscleGroupId == null) {
          content = Center(
            key: const ValueKey(_MusclesMessage.noGroupSelected),
            child: Text(
              AppStrings.selectMuscleGroup.tr(),
              style: AppTextStyles.white16500,
            ),
          );
        } else if (muscles.isEmpty) {
          content = Center(
            key: const ValueKey(_MusclesMessage.empty),
            child: Text(
              AppStrings.noMusclesFound.tr(),
              style: AppTextStyles.white16500,
            ),
          );
        } else {
          content = CustomGridView(
            itemCount: muscles.length,
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
