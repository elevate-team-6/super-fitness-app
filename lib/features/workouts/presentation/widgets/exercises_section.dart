import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:super_fitness/core/utils/app_colors.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/core/widgets/custom_empty_state_view.dart';
import 'package:super_fitness/features/workouts/presentation/view_models/exercise_view_model/exercise_cubit.dart';
import 'package:super_fitness/features/workouts/presentation/view_models/exercise_view_model/exercise_event.dart';
import 'package:super_fitness/features/workouts/presentation/view_models/exercise_view_model/exercise_state.dart';
import 'package:super_fitness/features/workouts/presentation/widgets/exercise_card.dart';
import 'package:super_fitness/features/workouts/presentation/widgets/exercise_skeleton.dart';

class ExercisesSection extends StatefulWidget {
  const ExercisesSection({super.key});

  @override
  State<ExercisesSection> createState() => _ExercisesSectionState();
}

class _ExercisesSectionState extends State<ExercisesSection> {
  Widget build(BuildContext context) {
    return BlocBuilder<ExerciseCubit, ExerciseState>(
      buildWhen: (previous, current) =>
          previous.isLoadingLevels != current.isLoadingLevels ||
          previous.isLoadingExercises != current.isLoadingExercises ||
          previous.isRefreshing != current.isRefreshing ||
          previous.exercises != current.exercises,
      builder: (context, state) {
        final isLoading = state.isLoadingLevels || state.isLoadingExercises;

        if (isLoading) {
          return _buildSkeletonList();
        }

        if (state.exercises.isEmpty) {
          return Center(
            child: CustomEmptyStateView(
              message: AppStrings.noExercisesFound.tr(),
            ),
          );
        }
        return RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.black80,
          onRefresh: () async {
            context.read<ExerciseCubit>().doIntent(const RefreshExercises());

            // Wait until refreshing completes.
            await context.read<ExerciseCubit>().stream.firstWhere(
              (s) => !s.isRefreshing,
            );
          },
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            itemCount: state.exercises.length,
            itemBuilder: (context, index) {
              return ExerciseCard(exercise: state.exercises[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildSkeletonList() {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      itemCount: 5,
      separatorBuilder: (context, i) => SizedBox(height: 4.h),
      itemBuilder: (context, i) => const ExerciseSkeleton(),
    );
  }
}
