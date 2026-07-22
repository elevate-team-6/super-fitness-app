import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:super_fitness/core/utils/app_routes.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/utils/app_strings.dart';
import '../../domain/entities/meal_category_entity.dart';
import '../view_models/home_view_model/home_cubit.dart';
import '../view_models/home_view_model/home_event.dart';
import '../view_models/home_view_model/home_state.dart';
import 'home_card.dart';
import 'home_error_widget.dart';
import 'home_sections_shimmer.dart';
import 'section_header.dart';

class RecommendationForYouSection extends StatelessWidget {
  const RecommendationForYouSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (p, c) =>
          p.recommendationForYouTabsStatus != c.recommendationForYouTabsStatus,
      builder: (context, state) {
        final status = state.recommendationForYouTabsStatus;

        if (status.errorMessage != null) {
          return HomeErrorWidget(
            message: status.errorMessage!,
            onRetry: () => context.read<HomeCubit>().doEvent(
              const FetchMealCategoriesEvent(),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: AppStrings.recommendationForYou.tr(),
              onSeeAll: () {
                Navigator.pushNamed(context, AppRoutes.food);
              },
            ),
            if (status.isLoading)
              HomeSectionsShimmer.recommendationForYou()
            else
              SizedBox(
                height: 104.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: status.data?.length ?? 0,
                  itemBuilder: (context, index) {
                    final category =
                        status.data?[index] ?? MealCategoryEntity.empty;
                    return HomeCard(
                      title: category.name,
                      image: category.image,
                      placeholderIcon: AppIcons.meal,
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.detailsFood);
                      },
                      height: 104.h,
                      width: 104.w,
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
