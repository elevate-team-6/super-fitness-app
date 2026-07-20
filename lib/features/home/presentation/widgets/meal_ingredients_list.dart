import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:super_fitness/core/utils/app_colors.dart';
import 'package:super_fitness/core/utils/app_text_styles.dart';
import 'package:super_fitness/features/home/domain/entities/meal_ingredient_entity.dart';

class MealIngredientsList extends StatelessWidget {
  final List<MealIngredientEntity> ingredients;

  const MealIngredientsList({super.key, required this.ingredients});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final ingredient in ingredients) ...[
          _MealIngredientRow(ingredient: ingredient),
          SizedBox(height: 8.h),
        ],
      ],
    );
  }
}

class _MealIngredientRow extends StatelessWidget {
  final MealIngredientEntity ingredient;

  const _MealIngredientRow({required this.ingredient});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.black80,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(ingredient.name, style: AppTextStyles.white16500),
          ),
          if (ingredient.measure.isNotEmpty) ...[
            SizedBox(width: 12.w),
            Text(ingredient.measure, style: AppTextStyles.primary13500),
          ],
        ],
      ),
    );
  }
}
