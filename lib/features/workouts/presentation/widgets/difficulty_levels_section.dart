import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:super_fitness/core/utils/app_colors.dart';
import 'package:super_fitness/core/widgets/custom_tab_bar.dart';
import 'package:super_fitness/features/workouts/presentation/view_models/exercise_view_model/exercise_cubit.dart';
import 'package:super_fitness/features/workouts/presentation/view_models/exercise_view_model/exercise_event.dart';
import 'package:super_fitness/features/workouts/presentation/view_models/exercise_view_model/exercise_state.dart';

class DifficultyLevelsSection extends StatelessWidget {
  final TabController? tabController;

  const DifficultyLevelsSection({super.key, this.tabController});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExerciseCubit, ExerciseState>(
      buildWhen: (previous, current) =>
          previous.isLoadingLevels != current.isLoadingLevels ||
          previous.difficultyLevels != current.difficultyLevels,
      builder: (context, state) {
        if (state.isLoadingLevels) {
          return _buildSkeleton();
        }

        if (state.difficultyLevels.isEmpty) {
          return const SizedBox.shrink();
        }

        final tabTitles = state.difficultyLevels.map((l) => l.name).toList();

        return DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.black80.withValues(alpha: 0.85),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(12.r)),
          ),
          child: CustomTabBar(
            tabs: tabTitles,
            controller: tabController,
            onTap: (index) {
              if (index >= 0 && index < state.difficultyLevels.length) {
                final selectedLevel = state.difficultyLevels[index];
                context.read<ExerciseCubit>().doIntent(
                  ChangeDifficulty(selectedLevel),
                );
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildSkeleton() {
    return SizedBox(
      height: 44.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: 4,
        separatorBuilder: (context, i) => SizedBox(width: 16.w),
        itemBuilder: (context, i) => const _SkeletonChip(),
      ),
    );
  }
}

class _SkeletonChip extends StatelessWidget {
  const _SkeletonChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80.w,
      height: 30.h,
      decoration: BoxDecoration(
        color: AppColors.black70,
        borderRadius: BorderRadius.circular(20.r),
      ),
    );
  }
}
