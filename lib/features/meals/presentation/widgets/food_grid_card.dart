import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/app_glass_card.dart';
import '../../../../core/widgets/custom_cached_image.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../domain/entities/meal_entity.dart';

class FoodGridCard extends StatelessWidget {
  final MealEntity meal;
  final VoidCallback onTap;

  const FoodGridCard({
    super.key,
    required this.meal,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: AspectRatio(
          aspectRatio: 1,
          child: Stack(
            children: [
              // Image
              Positioned.fill(
                child: CustomCachedImage(
                  imageUrl: meal.image,
                  fit: BoxFit.cover,
                ),
              ),
              
              // Center Glass Card
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: AppGlassCard(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                    child: Text(
                      meal.name,
                      style: AppTextStyles.white14700,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
