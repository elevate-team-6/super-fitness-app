import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/app_routes.dart';
import '../../../../core/utils/app_strings.dart';
import '../../domain/entities/exercise_entity.dart';
import '../view_models/home_view_model/home_cubit.dart';
import '../view_models/home_view_model/home_event.dart';
import '../view_models/home_view_model/home_state.dart';
import 'home_card.dart';
import 'home_error_widget.dart';
import 'home_sections_shimmer.dart';
import 'section_header.dart';

class RecommendationTodaySection extends StatelessWidget {
  const RecommendationTodaySection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (p, c) =>
          p.recommendationTodayStatus != c.recommendationTodayStatus,
      builder: (context, state) {
        final status = state.recommendationTodayStatus;

        if (status.errorMessage != null) {
          return HomeErrorWidget(
            message: status.errorMessage!,
            onRetry: () => context.read<HomeCubit>().doEvent(
              const FetchRandomExercisesEvent(),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(title: AppStrings.recommendationToday.tr()),
            SizedBox(height: 8.h),
            if (status.isLoading)
              HomeSectionsShimmer.recommendationToday()
            else
              SizedBox(
                height: 104.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: status.data?.length ?? 0,
                  itemBuilder: (context, index) {
                    final exercise =
                        status.data?[index] ?? ExerciseEntity.empty;
                    return HomeCard(
                      title: exercise.name,
                      image: exercise.videoUrl,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.exerciseScreen,
                          arguments: exercise.id,
                        );
                      },
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
