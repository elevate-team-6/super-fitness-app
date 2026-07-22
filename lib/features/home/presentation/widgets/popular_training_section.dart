import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/app_strings.dart';
import '../../domain/entities/exercise_entity.dart';
import '../view_models/home_view_model/home_cubit.dart';
import '../view_models/home_view_model/home_event.dart';
import '../view_models/home_view_model/home_state.dart';
import 'home_error_widget.dart';
import 'home_sections_shimmer.dart';
import 'popular_training_card.dart';
import 'section_header.dart';

class PopularTrainingSection extends StatelessWidget {
  const PopularTrainingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (p, c) => p.popularTrainingStatus != c.popularTrainingStatus,
      builder: (context, state) {
        final status = state.popularTrainingStatus;

        if (status.errorMessage != null) {
          return HomeErrorWidget(
            message: status.errorMessage!,
            onRetry: () => context.read<HomeCubit>().doEvent(
                  const FetchPopularExercisesEvent(),
                ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(title: AppStrings.popularTraining.tr()),
            SizedBox(height: 16.h),
            if (status.isLoading)
              HomeSectionsShimmer.popularTraining()
            else
              SizedBox(
                height: 175.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: status.data?.length ?? 0,
                  itemBuilder: (context, index) {
                    final exercise =
                        status.data?[index] ?? ExerciseEntity.empty;
                    return PopularTrainingCard(
                      title: exercise.name,
                      image: '',
                      tasks: '24',
                      difficulty: exercise.difficulty,
                      onTap: () {},
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}
