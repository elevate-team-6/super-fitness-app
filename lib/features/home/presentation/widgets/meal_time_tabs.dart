import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:super_fitness/core/utils/app_colors.dart';
import 'package:super_fitness/core/utils/app_text_styles.dart';
import 'package:super_fitness/features/home/domain/entities/meal_time.dart';

/// TODO(SF-19): placeholder — replace with the shared filter-chips widget once
/// it lands. Only [FoodScreen] builds this, so the swap is a one-line change.
class MealTimeTabs extends StatelessWidget {
  final MealTime selected;
  final ValueChanged<MealTime> onSelected;

  const MealTimeTabs({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Scrollable so the chips never overflow on narrow screens or when a
    // locale renders the labels longer than English does.
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: MealTime.values.map((mealTime) {
        final isSelected = mealTime == selected;

        return Padding(
          padding: EdgeInsetsDirectional.only(end: 12.w),
          child: GestureDetector(
            onTap: () => onSelected(mealTime),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.white40,
                ),
              ),
              child: Text(
                mealTime.labelKey.tr(),
                style: isSelected
                    ? AppTextStyles.white16500
                    : AppTextStyles.white2016500,
              ),
            ),
          ),
        );
      }).toList(),
      ),
    );
  }
}
