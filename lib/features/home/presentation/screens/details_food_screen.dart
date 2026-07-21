import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:super_fitness/config/base_ui_event/base_ui_event.dart';
import 'package:super_fitness/config/base_ui_handler/ui_event_handler_mixin.dart';
import 'package:super_fitness/core/utils/app_assets.dart';
import 'package:super_fitness/core/utils/app_colors.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/core/utils/app_text_styles.dart';
import 'package:super_fitness/core/utils/youtube_url.dart';
import 'package:super_fitness/core/widgets/app_scaffold.dart';
import 'package:super_fitness/core/widgets/custom_error_state_view.dart';
import 'package:super_fitness/features/home/domain/entities/details_food_entity.dart';
import 'package:super_fitness/features/home/presentation/view_model/details_food_view_model/details_food_cubit.dart';
import 'package:super_fitness/features/home/presentation/view_model/details_food_view_model/details_food_event.dart';
import 'package:super_fitness/features/home/presentation/view_model/details_food_view_model/details_food_state.dart';
import 'package:super_fitness/features/home/presentation/widgets/details_food_hero.dart';
import 'package:super_fitness/features/home/presentation/widgets/details_food_placeholders.dart';
import 'package:super_fitness/features/home/presentation/widgets/details_food_section.dart';
import 'package:super_fitness/features/home/presentation/widgets/meal_ingredients_list.dart';
import 'package:super_fitness/features/home/presentation/widgets/meal_nutrition_bar.dart';

class DetailsFoodScreen extends StatefulWidget {
  /// Rendered in the hero while the real record loads, so the name doesn't pop
  /// in — the grid already knows it when it navigates here.
  final String mealName;

  const DetailsFoodScreen({super.key, required this.mealName});

  @override
  State<DetailsFoodScreen> createState() => _DetailsFoodScreenState();
}

class _DetailsFoodScreenState extends State<DetailsFoodScreen>
    with UiEventHandler {
  StreamSubscription<BaseUiEvent>? _sideEffectSubscription;

  @override
  void initState() {
    super.initState();
    _sideEffectSubscription = context
        .read<DetailsFoodCubit>()
        .eventStream
        .listen(handleUiEvent);
  }

  @override
  void dispose() {
    _sideEffectSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundImage: AppImages.homeBackground,
      body: BlocBuilder<DetailsFoodCubit, DetailsFoodState>(
        builder: (context, state) => switch (state.status) {
          DetailsFoodStatus.initial ||
          DetailsFoodStatus.loading => _buildContent(
            context,
            DetailsFoodPlaceholders.skeleton,
            isLoading: true,
            // Already inside the whole-screen Skeletonizer, so it needs no
            // shimmer of its own here.
            nutrition: const MealNutritionBar(
              stats: DetailsFoodPlaceholders.nutrition,
            ),
          ),
          DetailsFoodStatus.error => _buildError(context, state),
          DetailsFoodStatus.success => _buildContent(
            context,
            state.details!,
            nutrition: _buildNutritionBar(state),
          ),
        },
      ),
    );
  }

  Widget? _buildNutritionBar(DetailsFoodState state) {
    final nutrition = state.nutrition;

    if (state.nutritionStatus == DetailsFoodStatus.error) return null;

    if (nutrition == null) {
      return const Skeletonizer(
        child: MealNutritionBar(stats: DetailsFoodPlaceholders.nutrition),
      );
    }

    return MealNutritionBar(stats: MealNutritionStat.listOf(nutrition));
  }

  Widget _buildContent(
    BuildContext context,
    DetailsFoodEntity details, {
    bool isLoading = false,
    Widget? nutrition,
  }) {
    final videoUrl = YoutubeUrl.watchUrlOf(details.youtubeUrl);

    return Skeletonizer(
      enabled: isLoading,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DetailsFoodHero(
              thumbnail: details.thumbnail,
              name: isLoading ? widget.mealName : details.name,
              onBack: () => Navigator.pop(context),
              onPlay: (isLoading || videoUrl == null)
                  ? null
                  : () => context.read<DetailsFoodCubit>().doIntent(
                      const OpenMealVideoEvent(),
                    ),
              footer: nutrition,
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 32.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (details.ingredients.isNotEmpty) ...[
                    DetailsFoodSection(
                      title: AppStrings.ingredients.tr(),
                      child: MealIngredientsList(
                        ingredients: details.ingredients,
                      ),
                    ),
                    SizedBox(height: 24.h),
                  ],
                  if (details.instructions.isNotEmpty)
                    DetailsFoodSection(
                      title: AppStrings.description.tr(),
                      child: Text(
                        details.instructions,
                        style: AppTextStyles.white2016500,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, DetailsFoodState state) {
    return SafeArea(
      child: Column(
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: BackButton(color: AppColors.white),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: CustomErrorStateView(
                message: state.errorMessage.isNotEmpty
                    ? state.errorMessage
                    : AppStrings.detailsFoodNotFound,
                onRetry: () => context.read<DetailsFoodCubit>().doIntent(
                  const LoadDetailsFoodEvent(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
