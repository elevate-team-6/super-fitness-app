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
import 'package:super_fitness/core/widgets/custom_app_bar.dart';
import 'package:super_fitness/features/workouts/presentation/view_models/exercise_view_model/exercise_cubit.dart';
import 'package:super_fitness/features/workouts/presentation/view_models/exercise_view_model/exercise_event.dart';
import 'package:super_fitness/features/workouts/presentation/view_models/exercise_view_model/exercise_state.dart';
import 'package:super_fitness/features/workouts/presentation/widgets/difficulty_levels_section.dart';
import 'package:super_fitness/features/workouts/presentation/widgets/exercises_section.dart';

class ExerciseScreen extends StatefulWidget {
  final String primeMoverMuscleId;

  const ExerciseScreen({super.key, required this.primeMoverMuscleId});

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> with UiEventHandler {
  StreamSubscription<BaseUiEvent>? _uiEventSubscription;

  @override
  void initState() {
    super.initState();
    _uiEventSubscription = context.read<ExerciseCubit>().eventStream.listen(
      handleUiEvent,
    );

    context.read<ExerciseCubit>().doIntent(
      InitializeExerciseScreen(widget.primeMoverMuscleId),
    );
  }

  @override
  void dispose() {
    _uiEventSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundImage: AppImages.homeBackground,
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        centerTitle: true,
        height: 260.h,
        backgroundImage: AppImages.homeBackground,
        title: BlocSelector<ExerciseCubit, ExerciseState, String>(
          selector: (state) =>
              state.selectedDifficulty?.name ?? AppStrings.workouts.tr(),
          builder: (context, title) {
            return Text(
              AppStrings.workouts.tr(),
              style: AppTextStyles.white24700,
            );
          },
        ),
        subtitle: 'Find the best exercises for you',
        onBackPressed: () => Navigator.pop(context),
        bottomContent: BlocSelector<ExerciseCubit, ExerciseState, int>(
          selector: (state) => state.totalExercises,
          builder: (context, total) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _InfoBadge(label: '30 MIN'),
                _InfoBadge(
                  label: '$total ${total == 1 ? 'Exercise' : 'Exercises'}',
                  isPrimary: true,
                ),
              ],
            );
          },
        ),
      ),
      body: SafeArea(
        top: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),
            const DifficultyLevelsSection(),
            SizedBox(height: 16.h),
            const Expanded(child: ExercisesSection()),
          ],
        ),
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final String label;
  final bool isPrimary;

  const _InfoBadge({required this.label, this.isPrimary = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: isPrimary ? Colors.transparent : Colors.transparent,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isPrimary
              ? Colors.white.withValues(alpha: 0.8)
              : Colors.white.withValues(alpha: 0.5),
        ),
      ),
      child: Text(
        label,
        style: isPrimary
            ? AppTextStyles.white13500.copyWith(fontWeight: FontWeight.w700)
            : AppTextStyles.white13500,
      ),
    );
  }
}
