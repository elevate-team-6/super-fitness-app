import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:super_fitness/core/utils/app_colors.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/core/widgets/custom_empty_state_view.dart';
import 'package:super_fitness/core/widgets/custom_glass_container.dart';
import 'package:super_fitness/features/workouts/presentation/view_models/exercise_view_model/exercise_cubit.dart';
import 'package:super_fitness/features/workouts/presentation/view_models/exercise_view_model/exercise_state.dart';
import 'package:super_fitness/features/workouts/presentation/widgets/exercise_card.dart';
import 'package:super_fitness/features/workouts/presentation/widgets/exercise_skeleton.dart';

class ExercisesSection extends StatelessWidget {
  const ExercisesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExerciseCubit, ExerciseState>(
      buildWhen: (previous, current) =>
          previous.isLoadingLevels != current.isLoadingLevels ||
          previous.isLoadingExercises != current.isLoadingExercises ||
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

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: CustomGlassContainer(
            padding: EdgeInsets.zero,
            margin: EdgeInsets.zero,
            opacity: .1,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: AppColors.white.withValues(alpha: .08)),
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: state.exercises.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                thickness: 1,
                color: AppColors.white.withValues(alpha: .08),
              ),
              itemBuilder: (context, index) {
                return ExerciseCard(
                  exercise: state.exercises[index],
                  isFirst: index == 0,
                  isLast: index == state.exercises.length - 1,
                );
              },
            ),
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
      separatorBuilder: (_, __) => SizedBox(height: 4.h),
      itemBuilder: (_, __) => const ExerciseSkeleton(),
    );
  }
}
