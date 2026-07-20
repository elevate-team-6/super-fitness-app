import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:super_fitness/core/utils/app_colors.dart';
import 'package:super_fitness/core/utils/app_routes.dart';
import 'package:super_fitness/core/utils/app_text_styles.dart';
import 'package:super_fitness/core/widgets/custom_cached_image.dart';
import 'package:super_fitness/features/home/domain/entities/meal_entity.dart';

/// TODO(SF-19): placeholder — replace with the shared meal-card widget once it
/// lands. Only [FoodScreen] builds this, so the swap is a one-line change.
class MealCard extends StatelessWidget {
  final MealEntity meal;

  const MealCard({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openDetails(context),
      child: _buildCard(),
    );
  }

  void _openDetails(BuildContext context) {
    Navigator.pushNamed(
      context,
      AppRoutes.detailsFood,
      arguments: DetailsFoodArgs(mealId: meal.id, mealName: meal.name),
    );
  }

  Widget _buildCard() {
    return Container(
      width: 160.w,
      margin: EdgeInsetsDirectional.only(end: 12.w),
      decoration: BoxDecoration(
        color: AppColors.black80,
        borderRadius: BorderRadius.circular(16.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomCachedImage(
            imageUrl: meal.thumbnail,
            width: 160.w,
            height: 110.h,
            // Static rather than the default spinner — an endless animation
            // makes `pumpAndSettle` hang in widget tests.
            placeholder: const ColoredBox(color: AppColors.black80),
          ),
          Padding(
            padding: EdgeInsets.all(10.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.white13500,
                ),
                if (meal.country != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    meal.country!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.white2010500,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
