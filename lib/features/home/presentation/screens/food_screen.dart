import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:super_fitness/core/utils/app_assets.dart';
import 'package:super_fitness/core/utils/app_routes.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/core/utils/app_text_styles.dart';
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
          child: BlocBuilder<FoodCubit, FoodState>(
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTabBar(state),
                  SizedBox(height: 16.h),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: _buildMealsGrid(state),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar(FoodState state) {
    final categoriesState = state.categoriesState;

    if (categoriesState.isLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: HomeSectionsShimmer.upcomingWorkoutsTabs(),
      );
    }

    if (categoriesState.errorMessage != null) {
      return const SizedBox.shrink();
    }

    final categories = categoriesState.data ?? [];
    if (categories.isEmpty) return const SizedBox.shrink();

    final selectedIndex = categories.indexWhere(
      (element) => element.name == state.selectedCategory,
    );

    return DefaultTabController(
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

  Widget _buildMealsGrid(FoodState state) {
    final mealsState = state.mealsState;

    if (mealsState.isLoading) {
      return CustomGridView(
        itemCount: 6,
        padding: EdgeInsets.zero,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        itemBuilder: (context, index) => HomeSectionsShimmer.mealCardShimmer(),
      );
    }

    if (mealsState.errorMessage != null) {
      return HomeErrorWidget(
        message: mealsState.errorMessage!,
        onRetry: () {
          final cubit = context.read<FoodCubit>();
          if (state.categoriesState.errorMessage != null) {
            cubit.doIntent(const GetMealsCategoriesEvent());
          } else {
            cubit.doIntent(ChangeCategoryEvent(state.selectedCategory ?? ''));
          }
        },
      );
    }

    final meals = mealsState.data ?? [];
    if (meals.isEmpty) {
      return Center(
        child: Text(
          AppStrings.noMealsFound.tr(),
          style: AppTextStyles.white2016500,
        ),
      );
    }

    return CustomGridView(
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
}
