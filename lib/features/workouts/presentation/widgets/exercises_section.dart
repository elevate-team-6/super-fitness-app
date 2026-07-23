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
import 'package:super_fitness/features/workouts/presentation/widgets/pagination_loader.dart';

class ExercisesSection extends StatefulWidget {
  const ExercisesSection({super.key});

  @override
  State<ExercisesSection> createState() => _ExercisesSectionState();
}

class _ExercisesSectionState extends State<ExercisesSection> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    const threshold = 200.0;

    if (currentScroll >= maxScroll - threshold) {
      final state = context.read<ExerciseCubit>().state;

      if (!state.isLoadingMore &&
          !state.isLoadingExercises &&
          !state.isRefreshing &&
          !state.hasReachedMax) {
        context.read<ExerciseCubit>().doIntent(const LoadMoreExercises());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExerciseCubit, ExerciseState>(
      buildWhen: (previous, current) =>
          previous.isLoadingLevels != current.isLoadingLevels ||
          previous.isLoadingExercises != current.isLoadingExercises ||
          previous.isRefreshing != current.isRefreshing ||
          previous.exercises != current.exercises ||
          previous.isLoadingMore != current.isLoadingMore,
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
            controller: _scrollController,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            itemCount: state.exercises.length + (state.isLoadingMore ? 1 : 0),

            itemBuilder: (context, index) {
              if (index == state.exercises.length) {
                return const PaginationLoader();
              }

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
