import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_assets.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../chat/presentation/screens/chat_screen.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../workouts/presentation/screens/workouts_screen.dart';
import '../cubit/main_layout_cubit.dart';
import '../widgets/custom_svg_icon.dart';

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
            body: IndexedStack(index: state.currentIndex, children: _screens),
            extendBody: true,
            bottomNavigationBar: _buildCustomBottomNavBar(context, state),
          );
        },
      ),
    );
  }

  Widget _buildCustomBottomNavBar(BuildContext context, MainLayoutState state) {
    return Padding(
      padding: EdgeInsets.fromLTRB(32.w, 0, 32.w, 32.h),
      child: Container(
        height: 70.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              color: AppColors.black80.withValues(alpha: 0.8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavBarItem(
                    key: const Key('home_tab'),
                    index: 0,
                    currentIndex: state.currentIndex,
                    iconPath: AppIcons.home,
                    label: AppStrings.explore.tr(),
                    onTap: () => context.read<MainLayoutCubit>().changeTab(0),
                  ),
                  _NavBarItem(
                    key: const Key('chat_tab'),
                    index: 1,
                    currentIndex: state.currentIndex,
                    iconPath: AppIcons.chat,
                    label: AppStrings.chat.tr(),
                    onTap: () => context.read<MainLayoutCubit>().changeTab(1),
                  ),
                  _NavBarItem(
                    key: const Key('workouts_tab'),
                    index: 2,
                    currentIndex: state.currentIndex,
                    iconPath: AppIcons.workOut,
                    label: AppStrings.workouts.tr(),
                    onTap: () => context.read<MainLayoutCubit>().changeTab(2),
                  ),
                  _NavBarItem(
                    key: const Key('profile_tab'),
                    index: 3,
                    currentIndex: state.currentIndex,
                    iconPath: AppIcons.profile,
                    label: AppStrings.profile.tr(),
                    onTap: () => context.read<MainLayoutCubit>().changeTab(3),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final int index;
  final int currentIndex;
  final String iconPath;
  final String label;
  final VoidCallback onTap;

  const _NavBarItem({
    super.key,
    required this.index,
    required this.currentIndex,
    required this.iconPath,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = index == currentIndex;
    return Flexible(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomSvgIcon(
              iconPath: iconPath,
              color: isSelected ? AppColors.primary : AppColors.white,
              size: 40.sp,
            ),
            if (isSelected) ...[
              SizedBox(height: 4.h),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: AppTextStyles.primary13500.copyWith(fontSize: 12.sp),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
