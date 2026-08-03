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

  @override
  Widget build(BuildContext context) {
    Localizations.localeOf(context);

    final screens = <WidgetBuilder>[
      (_) => HomeScreen(),
      (_) => ChatScreen(),
      (_) => WorkoutsScreen(),
      (_) => ProfileScreen(),
    ];

    return BlocProvider(
      create: (context) => MainLayoutCubit(),
      child: BlocBuilder<MainLayoutCubit, MainLayoutState>(
        builder: (context, state) {
          return Scaffold(
            body: _LazyIndexedStack(
              index: state.currentIndex,
              builders: screens,
            ),
            extendBody: true,
            bottomNavigationBar: Padding(
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
                            onTap: () =>
                                context.read<MainLayoutCubit>().changeTab(0),
                          ),
                          _NavBarItem(
                            key: const Key('chat_tab'),
                            index: 1,
                            currentIndex: state.currentIndex,
                            iconPath: AppIcons.chat,
                            label: AppStrings.chat.tr(),
                            onTap: () =>
                                context.read<MainLayoutCubit>().changeTab(1),
                          ),
                          _NavBarItem(
                            key: const Key('workouts_tab'),
                            index: 2,
                            currentIndex: state.currentIndex,
                            iconPath: AppIcons.workOut,
                            label: AppStrings.workouts.tr(),
                            onTap: () =>
                                context.read<MainLayoutCubit>().changeTab(2),
                          ),
                          _NavBarItem(
                            key: const Key('profile_tab'),
                            index: 3,
                            currentIndex: state.currentIndex,
                            iconPath: AppIcons.profile,
                            label: AppStrings.profile.tr(),
                            onTap: () =>
                                context.read<MainLayoutCubit>().changeTab(3),
                          ),
                        ],
                      ),
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
}

/// Builds a tab the first time it is opened, then keeps it alive like a plain
/// [IndexedStack] would. Building all four up front would run each screen's
/// first load at launch, so a tab's loading state would be over before anyone
/// switched to it.
class _LazyIndexedStack extends StatefulWidget {
  final int index;
  final List<WidgetBuilder> builders;

  const _LazyIndexedStack({required this.index, required this.builders});

  @override
  State<_LazyIndexedStack> createState() => _LazyIndexedStackState();
}

class _LazyIndexedStackState extends State<_LazyIndexedStack> {
  late final List<Widget?> _screens = List.filled(widget.builders.length, null);

  @override
  Widget build(BuildContext context) {
    _screens[widget.index] ??= widget.builders[widget.index](context);

    return IndexedStack(
      index: widget.index,
      children: [
        for (final screen in _screens) screen ?? const SizedBox.shrink(),
      ],
    );
  }
}

class _NavBarItem extends StatelessWidget {
  static const Duration _transition = Duration(milliseconds: 220);

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
            AnimatedScale(
              scale: isSelected ? 1.1 : 1,
              duration: _transition,
              curve: Curves.easeOut,
              child: TweenAnimationBuilder<Color?>(
                tween: ColorTween(
                  end: isSelected ? AppColors.primary : AppColors.white,
                ),
                duration: _transition,
                curve: Curves.easeOut,
                builder: (context, color, _) => CustomSvgIcon(
                  iconPath: iconPath,
                  color: color,
                  size: 40.sp,
                ),
              ),
            ),
            AnimatedSize(
              duration: _transition,
              curve: Curves.easeOut,
              child: !isSelected
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: EdgeInsets.only(top: 4.h),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          label,
                          style: AppTextStyles.primary13500.copyWith(
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
