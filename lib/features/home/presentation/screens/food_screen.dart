import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:super_fitness/core/utils/app_assets.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/core/utils/app_text_styles.dart';
import 'package:super_fitness/core/widgets/app_scaffold.dart';
import 'package:super_fitness/core/widgets/custom_error_state_view.dart';
import 'package:super_fitness/features/home/domain/entities/meal_entity.dart';
import 'package:super_fitness/features/home/presentation/view_model/food_view_model/food_cubit.dart';
import 'package:super_fitness/features/home/presentation/view_model/food_view_model/food_event.dart';
import 'package:super_fitness/features/home/presentation/view_model/food_view_model/food_state.dart';
import 'package:super_fitness/features/home/presentation/widgets/meal_card.dart';
import 'package:super_fitness/features/home/presentation/widgets/meal_time_tabs.dart';

class FoodScreen extends StatelessWidget {
  const FoodScreen({super.key});

  /// Placeholders shaped like real cards, shown behind the skeleton shimmer.
  static const _skeletonMeals = [
    MealEntity(id: '1', name: 'Loading meal name', thumbnail: ''),
    MealEntity(id: '2', name: 'Loading meal name', thumbnail: ''),
    MealEntity(id: '3', name: 'Loading meal name', thumbnail: ''),
    MealEntity(id: '4', name: 'Loading meal name', thumbnail: ''),
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundImage: AppImages.homeBackground,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.foodRecommendation.tr(),
              style: AppTextStyles.white20500,
            ),
            SizedBox(height: 16.h),
            BlocBuilder<FoodCubit, FoodState>(
              buildWhen: (previous, current) =>
                  previous.selectedMealTime != current.selectedMealTime,
              builder: (context, state) => MealTimeTabs(
                selected: state.selectedMealTime,
                onSelected: (mealTime) => context.read<FoodCubit>().doIntent(
                  SelectMealTimeEvent(mealTime),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: BlocBuilder<FoodCubit, FoodState>(
                builder: (context, state) => switch (state.status) {
                  FoodStatus.initial ||
                  FoodStatus.loading => _buildGrid(
                    _skeletonMeals,
                    isLoading: true,
                  ),
                  // Scrollable because the shared error view is taller than the
                  // space left under the header on short screens.
                  FoodStatus.error => SingleChildScrollView(
                    child: CustomErrorStateView(
                      message: state.errorMessage,
                      onRetry: () => context.read<FoodCubit>().doIntent(
                        const LoadMealsEvent(),
                      ),
                    ),
                  ),
                  FoodStatus.success when state.meals.isEmpty => Center(
                    child: Text(
                      AppStrings.noMealsFound.tr(),
                      style: AppTextStyles.white2016500,
                    ),
                  ),
                  FoodStatus.success => _buildGrid(state.meals),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(List<MealEntity> meals, {bool isLoading = false}) {
    return Skeletonizer(
      enabled: isLoading,
      child: GridView.builder(
        itemCount: meals.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          childAspectRatio: 0.85,
        ),
        itemBuilder: (context, index) => MealCard(meal: meals[index]),
      ),
    );
  }
}
