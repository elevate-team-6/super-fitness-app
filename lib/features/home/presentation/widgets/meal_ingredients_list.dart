import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:super_fitness/core/utils/app_colors.dart';
import 'package:super_fitness/core/utils/app_text_styles.dart';
import 'package:super_fitness/core/widgets/custom_glass_container.dart';
import 'package:super_fitness/features/home/domain/entities/meal_ingredient_entity.dart';

class MealIngredientsList extends StatelessWidget {
  final List<MealIngredientEntity> ingredients;

  const MealIngredientsList({super.key, required this.ingredients});

  @override
  Widget build(BuildContext context) {
    return CustomGlassContainer(
      blur: 20,
      opacity: 0.8,
      borderRadius: BorderRadius.circular(20.r),
      padding: EdgeInsets.all(8.w),
      child: Column(
        children: [
          for (var index = 0; index < ingredients.length; index++)
            _MealIngredientRow(
              ingredient: ingredients[index],
              showDivider: index < ingredients.length - 1,
            ),
        ],
      ),
    );
  }
}

class _MealIngredientRow extends StatelessWidget {
  final MealIngredientEntity ingredient;
  final bool showDivider;

  const _MealIngredientRow({
    required this.ingredient,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(8.w, 4.h, 8.w, 4.h),
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(bottom: BorderSide(color: AppColors.black70))
            : null,
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
