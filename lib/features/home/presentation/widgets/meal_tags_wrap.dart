import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:super_fitness/core/utils/app_colors.dart';
import 'package:super_fitness/core/utils/app_text_styles.dart';

/// Category, area and recipe tags as chips. These come straight from
/// TheMealDB (`Seafood`, `British`, `Paleo`, ...) so they stay untranslated.
class MealTagsWrap extends StatelessWidget {
  final List<String> tags;

  const MealTagsWrap({super.key, required this.tags});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: [
        for (final tag in tags)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(tag, style: AppTextStyles.white13500),
          ),
      ],
    );
  }
}
