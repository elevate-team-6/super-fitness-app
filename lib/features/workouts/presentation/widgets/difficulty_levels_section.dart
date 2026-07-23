import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:super_fitness/core/utils/app_colors.dart';
import 'package:super_fitness/core/utils/app_text_styles.dart';
import 'package:super_fitness/features/workouts/domain/entities/difficulty_level_entity.dart';
import 'package:super_fitness/features/workouts/presentation/view_models/exercise_view_model/exercise_cubit.dart';
import 'package:super_fitness/features/workouts/presentation/view_models/exercise_view_model/exercise_event.dart';
import 'package:super_fitness/features/workouts/presentation/view_models/exercise_view_model/exercise_state.dart';

class DifficultyLevelsSection extends StatelessWidget {
  const DifficultyLevelsSection({super.key});

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

        return SizedBox(
          height: 44.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: state.difficultyLevels.length,
            separatorBuilder: (context, i) => SizedBox(width: 32.w),
            itemBuilder: (context, index) {
              final level = state.difficultyLevels[index];
              return DifficultyChip(level: level);
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
        itemCount: 3,
        separatorBuilder: (context, i) => SizedBox(width: 32.w),
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
      height: 34.h,
      decoration: BoxDecoration(
        color: AppColors.black70,
        borderRadius: BorderRadius.circular(24.r),
      ),
    );
  }
}

class DifficultyChip extends StatelessWidget {
  final DifficultyLevelEntity level;

  const DifficultyChip({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ExerciseCubit, ExerciseState, bool>(
      selector: (state) => state.selectedDifficulty?.id == level.id,
      builder: (context, isSelected) {
        return GestureDetector(
          onTap: isSelected
              ? null
              : () => context
                  .read<ExerciseCubit>()
                  .doIntent(ChangeDifficulty(level)),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
            decoration: BoxDecoration(
              // Selected: solid orange pill. Unselected: transparent, no border.
              color: isSelected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: Text(
              level.name,
              style: isSelected
                  ? AppTextStyles.white13500.copyWith(
                      fontWeight: FontWeight.w700,
                    )
                  : AppTextStyles.white13500.copyWith(
                      color: AppColors.white60,
                    ),
            ),
          ),
        );
      },
    );
  }
}
