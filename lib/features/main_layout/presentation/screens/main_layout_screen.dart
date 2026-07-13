import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_assets.dart';
import '../../../../core/utils/app_strings.dart';
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
            bottomNavigationBar: Padding(
              padding: EdgeInsets.fromLTRB(32.w, 0, 32.w, 32.h),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.r),
                child: NavigationBar(
                  selectedIndex: state.currentIndex,
                  onDestinationSelected: (index) {
                    context.read<MainLayoutCubit>().changeTab(index);
                  },
                  destinations: [
                    NavigationDestination(
                      icon: const CustomSvgIcon(iconPath: AppIcons.home),
                      label: AppStrings.explore.tr(),
                    ),
                    NavigationDestination(
                      icon: const CustomSvgIcon(iconPath: AppIcons.chat),
                      label: AppStrings.chat.tr(),
                    ),
                    NavigationDestination(
                      icon: const CustomSvgIcon(iconPath: AppIcons.workOut),
                      label: AppStrings.workouts.tr(),
                    ),
                    NavigationDestination(
                      icon: const CustomSvgIcon(iconPath: AppIcons.profile),
                      label: AppStrings.profile.tr(),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
