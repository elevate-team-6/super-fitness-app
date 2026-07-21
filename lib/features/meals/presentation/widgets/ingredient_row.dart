import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../domain/entities/ingredient_entity.dart';

class IngredientRow extends StatelessWidget {
  final IngredientEntity ingredient;

  const IngredientRow({
    super.key,
    required this.ingredient,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                ingredient.name,
                style: AppTextStyles.white14700,
              ),
              Text(
                ingredient.measure,
                style: AppTextStyles.white14500.copyWith(color: AppColors.primary),
              ),
            ],
          ),
        ),
        Divider(
          color: AppColors.white.withValues(alpha: 0.1),
          height: 1,
        ),
      ],
    );
  }
}
