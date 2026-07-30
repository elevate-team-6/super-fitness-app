import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:super_fitness/core/utils/app_assets.dart';
import 'package:super_fitness/core/utils/app_colors.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/core/utils/app_text_styles.dart';
import 'package:super_fitness/core/widgets/app_scaffold.dart';
import 'package:super_fitness/core/widgets/custom_app_bar.dart';
import 'package:super_fitness/features/workouts/domain/entities/exercise_entity.dart';
import 'package:super_fitness/features/workouts/presentation/widgets/exercise_details_hero.dart';
import 'package:super_fitness/features/workouts/presentation/widgets/muscle_targeting_section.dart';
import 'package:super_fitness/features/workouts/presentation/widgets/required_equipment_section.dart';
import 'package:super_fitness/features/workouts/presentation/widgets/technical_specs_grid.dart';

class ExerciseDetailsScreen extends StatelessWidget {
  final ExerciseEntity exercise;

  const ExerciseDetailsScreen({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundImage: AppImages.homeBackground,
      appBar: CustomAppBar(
        title: Text(AppStrings.exerciseDetails.tr()),
        centerTitle: true,
        onBackPressed: () => Navigator.pop(context),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: ExerciseDetailsHero(exercise: exercise),
              ),
              SizedBox(height: 24.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(exercise.exercise, style: AppTextStyles.white24700),
                    SizedBox(height: 4.h),
                    Text(
                      '${exercise.targetMuscleGroup} • ${exercise.difficultyLevel}',
                      style: AppTextStyles.white16500.copyWith(
                        color: AppColors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32.h),
              TechnicalSpecsGrid(exercise: exercise),
              SizedBox(height: 32.h),
              MuscleTargetingSection(exercise: exercise),
              SizedBox(height: 32.h),
              RequiredEquipmentSection(exercise: exercise),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }
}
