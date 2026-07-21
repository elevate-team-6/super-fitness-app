import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/entities/muscle_group_entity.dart';

class HomeCategoryItem extends StatelessWidget {
  final MuscleGroupEntity muscle;
  final String iconPath;
  final bool isSelected;
  final VoidCallback onTap;

  const HomeCategoryItem({
    super.key,
    required this.muscle,
    required this.iconPath,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.black80,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Image.asset(
                iconPath,
                width: 30.w,
                height: 30.w,
                color: AppColors.white,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            muscle.name,
            style: isSelected ? AppTextStyles.primary12500 : AppTextStyles.white6012500,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
