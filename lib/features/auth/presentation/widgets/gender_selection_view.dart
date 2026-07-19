import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:super_fitness/core/utils/app_assets.dart';
import 'package:super_fitness/core/utils/app_colors.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/core/utils/app_text_styles.dart';

class GenderSelectionView extends StatelessWidget {
  final String selectedGender;
  final ValueChanged<String> onGenderSelected;

  const GenderSelectionView({
    super.key,
    required this.selectedGender,
    required this.onGenderSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _GenderIcon(
          gender: AppStrings.male,
          iconPath: AppIcons.male,
          isSelected: selectedGender == AppStrings.male,
          label: AppStrings.male,
          onTap: () => onGenderSelected(AppStrings.male),
        ),
        SizedBox(height: 24.h),
        _GenderIcon(
          gender: AppStrings.female,
          iconPath: AppIcons.female,
          isSelected: selectedGender == AppStrings.female,
          label: AppStrings.female,
          onTap: () => onGenderSelected(AppStrings.female),
        ),
      ],
    );
  }
}

class _GenderIcon extends StatelessWidget {
  final String gender;
  final String iconPath;
  final bool isSelected;
  final String label;
  final VoidCallback onTap;

  const _GenderIcon({
    required this.gender,
    required this.iconPath,
    required this.isSelected,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 95.w,
        height: 95.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? AppColors.primary : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.white,
            width: 1.w,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              iconPath,
              width: 45.w,
              height: 45.w,
              colorFilter: const ColorFilter.mode(
                AppColors.white,
                BlendMode.srcIn,
              ),
            ),
            SizedBox(height: 8.h),
            Text(label.tr(), style: AppTextStyles.white13500),
          ],
        ),
      ),
    );
  }
}
