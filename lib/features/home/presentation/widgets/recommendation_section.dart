import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:super_fitness/core/utils/app_routes.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/core/utils/app_text_styles.dart';
import 'package:super_fitness/features/home/domain/entities/meal_time.dart';
import 'package:super_fitness/features/home/presentation/widgets/meal_time_card.dart';

/// Home's "Recommendation For You" row (SF-19). Purely a launcher — the meals
/// themselves live on [AppRoutes.food], so this holds no cubit of its own.
class RecommendationSection extends StatelessWidget {
  const RecommendationSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                AppStrings.recommendationForYou.tr(),
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.white20500,
              ),
            ),
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: () => _openFood(context, MealTime.breakfast),
              child: Text(
                AppStrings.seeAll.tr(),
                style: AppTextStyles.primary13500,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        SizedBox(
          height: 100.h,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: MealTime.values
                .map(
                  (mealTime) => MealTimeCard(
                    mealTime: mealTime,
                    onTap: () => _openFood(context, mealTime),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  void _openFood(BuildContext context, MealTime mealTime) {
    Navigator.pushNamed(
      context,
      AppRoutes.food,
      arguments: FoodScreenArgs(mealTime),
    );
  }
}
