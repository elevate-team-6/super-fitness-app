import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:super_fitness/core/utils/app_assets.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/core/utils/app_text_styles.dart';
import 'package:super_fitness/core/widgets/app_scaffold.dart';
import 'package:super_fitness/core/widgets/custom_app_bar.dart';
import 'package:super_fitness/core/widgets/custom_card.dart';
import 'package:super_fitness/core/widgets/custom_error_state_view.dart';
import 'package:super_fitness/core/widgets/custom_grid_view.dart';
import 'package:super_fitness/core/widgets/custom_tab_bar.dart';
import 'package:super_fitness/features/home/domain/entities/meal_time.dart';
import 'package:super_fitness/features/home/presentation/view_model/food_view_model/food_cubit.dart';
import 'package:super_fitness/features/home/presentation/view_model/food_view_model/food_event.dart';
import 'package:super_fitness/features/home/presentation/view_model/food_view_model/food_state.dart';
import 'package:super_fitness/features/home/presentation/widgets/meal_skeleton_placeholders.dart';

class FoodScreen extends StatelessWidget {
  const FoodScreen({super.key});

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
              DefaultTabController(
                length: MealTime.values.length,
                initialIndex: MealTime.values.indexOf(
                  context.read<FoodCubit>().state.selectedMealTime,
                ),
                child: CustomTabBar(
                  padding: EdgeInsets.zero,
                  tabs: MealTime.values.map((m) => m.labelKey.tr()).toList(),
                  onTap: (index) => context.read<FoodCubit>().doIntent(
                    SelectMealTimeEvent(MealTime.values[index]),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: BlocBuilder<FoodCubit, FoodState>(
                    builder: (context, state) {
                      final isLoading =
                          state.status == FoodStatus.initial ||
                          state.status == FoodStatus.loading;
                      final meals = isLoading ? skeletonMeals : state.meals;

                      return switch (state.status) {
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
                        _ => Skeletonizer(
                          enabled: isLoading,
                          child: CustomGridView(
                            itemCount: meals.length,
                            padding: EdgeInsets.zero,
                            crossAxisSpacing: 12.w,
                            mainAxisSpacing: 12.h,
                            itemBuilder: (context, index) => CustomCard(
                              title: meals[index].name,
                              image: meals[index].thumbnail,
                            ),
                          ),
                        ),
                      };
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
