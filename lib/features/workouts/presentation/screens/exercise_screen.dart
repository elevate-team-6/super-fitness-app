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
import 'package:super_fitness/features/workouts/domain/entities/difficulty_level_entity.dart';
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

class _ExerciseScreenState extends State<ExerciseScreen>
    with UiEventHandler, TickerProviderStateMixin {
  StreamSubscription<BaseUiEvent>? _uiEventSubscription;
  TabController? _tabController;

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

  void _updateTabController(List<DifficultyLevelEntity> levels) {
    if (levels.isEmpty) return;
    if (_tabController == null || _tabController!.length != levels.length) {
      _tabController?.dispose();
      _tabController = TabController(length: levels.length, vsync: this);
    }
  }

  @override
  void dispose() {
    _uiEventSubscription?.cancel();
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundImage: AppImages.homeBackground,
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        hasBottomBorderRadius: false,
        centerTitle: true,
        height: 260.h,
        backgroundImage: AppImages.homeBackground,
        title: BlocSelector<ExerciseCubit, ExerciseState, String>(
          selector: (state) => state.exercises.isNotEmpty
              ? state.exercises.first.primeMoverMuscle
              : '',
          builder: (context, primeMoverMuscle) {
            return Text(primeMoverMuscle, style: AppTextStyles.white24700);
          },
        ),
        subtitle: AppStrings.findBestExercisesForYou.tr(),
        onBackPressed: () => Navigator.pop(context),
        bottomContent: BlocSelector<ExerciseCubit, ExerciseState, int>(
          selector: (state) => state.totalExercises,
          builder: (context, total) {
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _InfoBadge(label: AppStrings.min30.tr()),
                    _InfoBadge(
                      label:
                          '$total ${total == 1 ? AppStrings.exerciseSingle.tr() : AppStrings.exercisePlural.tr()}',
                      isPrimary: true,
                    ),
                  ],
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
            BlocSelector<
              ExerciseCubit,
              ExerciseState,
              List<DifficultyLevelEntity>
            >(
              selector: (state) => state.difficultyLevels,
              builder: (context, levels) {
                _updateTabController(levels);
                return DifficultyLevelsSection(tabController: _tabController);
              },
            ),
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
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.transparent,
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
