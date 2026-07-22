import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_assets.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_snack_bar.dart';
import '../../../main_layout/presentation/cubit/main_layout_cubit.dart';

class HomeCategoryIcons extends StatelessWidget {
  const HomeCategoryIcons({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _CategoryItem(
            icon: AppIcons.gym,
            label: AppStrings.gym.tr(),
            onTap: () => _showUpcoming(context),
          ),
          _buildDivider(),
          _CategoryItem(
            icon: AppIcons.fitness,
            label: AppStrings.fitness.tr(),
            onTap: () => _showUpcoming(context),
          ),
          _buildDivider(),
          _CategoryItem(
            icon: AppIcons.yoga,
            label: AppStrings.yoga.tr(),
            onTap: () => _showUpcoming(context),
          ),
          _buildDivider(),
          _CategoryItem(
            icon: AppIcons.aerobics,
            label: AppStrings.aerobics.tr(),
            onTap: () => _showUpcoming(context),
          ),
          _buildDivider(),
          _CategoryItem(
            icon: AppIcons.trainer,
            label: AppStrings.trainer.tr(),
            onTap: () {
              context.read<MainLayoutCubit>().changeTab(1);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40.h,
      width: 1.w,
      color: AppColors.white.withValues(alpha: 0.1),
    );
  }

  void _showUpcoming(BuildContext context) {
    CustomSnackBar.showSuccessMessage(AppStrings.upcomingFeature.tr());
  }
}

class _CategoryItem extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;

  const _CategoryItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(icon, width: 40.w, height: 40.w),
          SizedBox(height: 8.h),
          Text(label, style: AppTextStyles.white12500),
        ],
      ),
    );
  }
}
