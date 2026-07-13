import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/utils/app_assets.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../chat/presentation/screens/chat_screen.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../workouts/presentation/screens/workouts_screen.dart';
import '../cubit/main_layout_cubit.dart';

class MainLayoutScreen extends StatelessWidget {
  const MainLayoutScreen({super.key});

  final List<Widget> _screens = const [
    HomeScreen(),
    ChatScreen(),
    WorkoutsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MainLayoutCubit(),
      child: BlocBuilder<MainLayoutCubit, MainLayoutState>(
        builder: (context, state) {
          return Scaffold(
            body: IndexedStack(
              index: state.currentIndex,
              children: _screens,
            ),
            extendBody: true,
            bottomNavigationBar: _buildBottomNavigationBar(context, state.currentIndex),
          );
        },
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, int currentIndex) {
    return Container(
      margin: EdgeInsets.fromLTRB(24.w, 0, 24.w, 20.h),
      height: 66.h,
      decoration: BoxDecoration(
        color: AppColors.black90.withOpacity(0.8),
        borderRadius: BorderRadius.circular(33.r),
        border: Border.all(color: AppColors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            context: context,
            index: 0,
            iconPath: AppIcons.home,
            label: AppStrings.home.tr(),
            isSelected: currentIndex == 0,
          ),
          _buildNavItem(
            context: context,
            index: 1,
            iconPath: AppIcons.chat,
            label: AppStrings.smartCoach.tr(),
            isSelected: currentIndex == 1,
          ),
          _buildNavItem(
            context: context,
            index: 2,
            iconPath: AppIcons.workOut,
            label: AppStrings.workouts.tr(),
            isSelected: currentIndex == 2,
          ),
          _buildNavItem(
            context: context,
            index: 3,
            iconPath: AppIcons.person,
            label: AppStrings.profile.tr(),
            isSelected: currentIndex == 3,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required String iconPath,
    required String label,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => context.read<MainLayoutCubit>().changeTab(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            iconPath,
            colorFilter: ColorFilter.mode(
              isSelected ? AppColors.primary : AppColors.white,
              BlendMode.srcIn,
            ),
            width: 24.w,
            height: 24.h,
          ),
          if (isSelected) ...[
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
