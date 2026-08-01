import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:super_fitness/core/utils/app_assets.dart';
import 'package:super_fitness/core/utils/app_routes.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/core/utils/app_text_styles.dart';
import 'package:super_fitness/core/widgets/animated_state_switcher.dart';
import 'package:super_fitness/core/widgets/app_scaffold.dart';
import 'package:super_fitness/core/widgets/custom_app_bar.dart';
import 'package:super_fitness/core/widgets/custom_grid_view.dart';
import 'package:super_fitness/core/widgets/custom_tab_bar.dart';
import 'package:super_fitness/features/home/presentation/view_models/food_view_model/food_cubit.dart';
import 'package:super_fitness/features/home/presentation/view_models/food_view_model/food_event.dart';
import 'package:super_fitness/features/home/presentation/view_models/food_view_model/food_state.dart';
import 'package:super_fitness/features/home/presentation/widgets/home_sections_shimmer.dart';
import 'package:super_fitness/features/home/presentation/widgets/meal_card.dart';

import '../widgets/home_error_widget.dart';

class FoodScreen extends StatefulWidget {
  const FoodScreen({super.key});

  @override
  State<FoodScreen> createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen> {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundImage: AppImages.homeBackground,
      blurSigma: 0,
      appBar: CustomAppBar(
        title: Text(
          AppStrings.foodRecommendation.tr(),
          style: AppTextStyles.white24500.copyWith(fontWeight: FontWeight.w600),
        ),
        onBackPressed: () => Navigator.pop(context),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: 8, bottom: 8.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _CategoryTabs(),
              SizedBox(height: 16.h),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: const _MealsGrid(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// The skeleton and the loaded grid are both a CustomGridView, so the switcher
// can't tell those two states apart on type alone.
enum _MealsContent { loading, error, empty, data }

class _CategoryTabs extends StatelessWidget {
  const _CategoryTabs();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FoodCubit, FoodState>(
      buildWhen: (previous, current) =>
          previous.categoriesState != current.categoriesState ||
          previous.selectedCategory != current.selectedCategory,
      builder: (context, state) {
        final categoriesState = state.categoriesState;
        final categories = categoriesState.data ?? [];

        final Widget content;

        if (categoriesState.isLoading) {
          content = Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: HomeSectionsShimmer.upcomingWorkoutsTabs(),
          );
        } else if (categoriesState.errorMessage != null || categories.isEmpty) {
          content = const SizedBox.shrink();
        } else {
          final selectedIndex = categories.indexWhere(
            (element) => element.name == state.selectedCategory,
          );

          content = DefaultTabController(
            length: categories.length,
            initialIndex: selectedIndex != -1 ? selectedIndex : 0,
            child: CustomTabBar(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              tabs: categories.map((c) => c.name).toList(),
              onTap: (index) => context.read<FoodCubit>().doIntent(
                ChangeCategoryEvent(categories[index].name),
              ),
            ),
          );
        }

        return AnimatedStateSwitcher(child: content);
      },
    );
  }
}

class _MealsGrid extends StatelessWidget {
  const _MealsGrid();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FoodCubit, FoodState>(
      buildWhen: (previous, current) =>
          previous.mealsState != current.mealsState ||
          previous.categoriesState != current.categoriesState ||
          previous.selectedCategory != current.selectedCategory,
      builder: (context, state) {
        final mealsState = state.mealsState;
        final meals = mealsState.data ?? [];

        final Widget content;

        if (mealsState.isLoading) {
          content = CustomGridView(
            key: const ValueKey(_MealsContent.loading),
            itemCount: 6,
            padding: EdgeInsets.zero,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            itemBuilder: (context, index) =>
                HomeSectionsShimmer.mealCardShimmer(),
          );
        } else if (mealsState.errorMessage != null) {
          content = HomeErrorWidget(
            key: const ValueKey(_MealsContent.error),
            message: mealsState.errorMessage!,
            onRetry: () {
              final cubit = context.read<FoodCubit>();
              if (state.categoriesState.errorMessage != null) {
                cubit.doIntent(const GetMealsCategoriesEvent());
              } else {
                cubit.doIntent(
                  ChangeCategoryEvent(state.selectedCategory ?? ''),
                );
              }
            },
          );
        } else if (meals.isEmpty) {
          content = Center(
            key: const ValueKey(_MealsContent.empty),
            child: Text(
              AppStrings.noMealsFound.tr(),
              style: AppTextStyles.white2016500,
            ),
          );
        } else {
          content = CustomGridView(
            key: const ValueKey(_MealsContent.data),
            itemCount: meals.length,
            padding: EdgeInsets.zero,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            itemBuilder: (context, index) => MealCard(
              name: meals[index].name,
              image: meals[index].thumbnail,
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.detailsFood,
                arguments: DetailsFoodArgs(
                  mealId: meals[index].id,
                  mealName: meals[index].name,
                ),
              ),
            ),
          );
        }

        return AnimatedStateSwitcher(child: content);
      },
    );
  }
}
