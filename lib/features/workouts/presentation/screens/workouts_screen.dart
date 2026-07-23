import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:super_fitness/config/base_ui_event/base_ui_event.dart';
import 'package:super_fitness/config/base_ui_handler/ui_event_handler_mixin.dart';
import 'package:super_fitness/core/utils/app_assets.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/core/utils/app_text_styles.dart';
import 'package:super_fitness/core/widgets/app_scaffold.dart';
import 'package:super_fitness/core/widgets/custom_grid_view.dart';
import 'package:super_fitness/core/widgets/custom_loading.dart';
import 'package:super_fitness/core/widgets/custom_tab_bar.dart';
import '../view_model/workouts_view_model/workouts_cubit.dart';
import '../view_model/workouts_view_model/workouts_events.dart';
import '../view_model/workouts_view_model/workouts_state.dart';
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
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Text(
                AppStrings.workouts.tr(),
                style: AppTextStyles.white24500,
              ),
            ),
            const _MuscleGroupsTabs(),
            const Expanded(
              child: _MusclesGrid(),
            ),
          ],
        ),
      ),
    );
  }
}

class _MuscleGroupsTabs extends StatelessWidget {
  const _MuscleGroupsTabs();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkoutsCubit, WorkoutsState>(
      buildWhen: (previous, current) =>
          previous.muscleGroupsState != current.muscleGroupsState,
      builder: (context, state) {
        if (state.muscleGroupsState.isLoading) {
          return const CustomLoading(height: 50);
        }

        final groups = state.muscleGroupsState.data ?? [];

        if (groups.isEmpty) return const SizedBox.shrink();

        return DefaultTabController(
          length: groups.length,
          child: CustomTabBar(
            tabs: groups.map((group) => group.name).toList(),
            onTap: (index) {
              context
                  .read<WorkoutsCubit>()
                  .doEvent(GetMusclesByGroupIdEvent(groups[index].id));
            },
          ),
        );
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
        if (state.musclesState.isLoading) {
          return const CustomLoading();
        }

        if (state.musclesState.errorMessage != null &&
            (state.musclesState.data?.isEmpty ?? true)) {
          return Center(
            child: Text(
              state.musclesState.errorMessage!,
              style: AppTextStyles.white16500,
            ),
          );
        }

        final muscles = state.musclesState.data ?? [];

        if (muscles.isEmpty && state.selectedMuscleGroupId == null) {
          return Center(
            child: Text(
              AppStrings.selectMuscleGroup.tr(),
              style: AppTextStyles.white16500,
            ),
          );
        }

        if (muscles.isEmpty) {
          return Center(
            child: Text(
              AppStrings.noMusclesFound.tr(),
              style: AppTextStyles.white16500,
            ),
          );
        }

        return CustomGridView(
          itemCount: muscles.length,
          itemBuilder: (context, index) {
            return MuscleGridItem(
              muscle: muscles[index],
              onTap: () {},
            );
          },
        );
      },
    );
  }
}
