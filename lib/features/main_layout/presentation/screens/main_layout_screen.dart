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
    final navBarTheme = Theme.of(context).navigationBarTheme;

    return BlocProvider(
      create: (context) => MainLayoutCubit(),
      child: BlocBuilder<MainLayoutCubit, MainLayoutState>(
        builder: (context, state) {
          return Scaffold(
            body: IndexedStack(index: state.currentIndex, children: _screens),
            extendBody: true,
            bottomNavigationBar: Padding(
              padding: EdgeInsets.fromLTRB(32.w, 0, 32.w, 32.h),
              child: Container(
                width: 311.w,
                height: 70.h,
                decoration: BoxDecoration(
                  color: navBarTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.r),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 4.h,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildNavItem(
                          context,
                          index: 0,
                          selectedIndex: state.currentIndex,
                          iconPath: AppIcons.home,
                          label: AppStrings.explore.tr(),
                          navBarTheme: navBarTheme,
                        ),
                        _buildNavItem(
                          context,
                          index: 1,
                          selectedIndex: state.currentIndex,
                          iconPath: AppIcons.chat,
                          label: AppStrings.chat.tr(),
                          navBarTheme: navBarTheme,
                        ),
                        _buildNavItem(
                          context,
                          index: 2,
                          selectedIndex: state.currentIndex,
                          iconPath: AppIcons.workOut,
                          label: AppStrings.workouts.tr(),
                          navBarTheme: navBarTheme,
                        ),
                        _buildNavItem(
                          context,
                          index: 3,
                          selectedIndex: state.currentIndex,
                          iconPath: AppIcons.profile,
                          label: AppStrings.profile.tr(),
                          navBarTheme: navBarTheme,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required int selectedIndex,
    required String iconPath,
    required String label,
    required NavigationBarThemeData navBarTheme,
  }) {
    final isSelected = index == selectedIndex;

    final states = isSelected ? {WidgetState.selected} : <WidgetState>{};
    final labelStyle = navBarTheme.labelTextStyle?.resolve(states);
    final iconColor = isSelected ? AppColors.primary : AppColors.white;

    return InkWell(
      onTap: () => context.read<MainLayoutCubit>().changeTab(index),
      borderRadius: BorderRadius.circular(12.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 60.w,
        height: 64.h,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: AnimatedScale(
                scale: isSelected ? 1.15 : 1.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                child: SizedBox(
                  width: 40.w,
                  height: 40.h,
                  child: SvgPicture.asset(
                    iconPath,
                    fit: BoxFit.contain,
                    colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                  ),
                ),
              ),
            ),
            if (isSelected) ...[
              SizedBox(height: 2.h),
              Flexible(
                child: Text(
                  label,
                  style: labelStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
