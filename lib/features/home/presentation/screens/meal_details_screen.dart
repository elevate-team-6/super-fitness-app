import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:super_fitness/core/utils/app_assets.dart';
import 'package:super_fitness/core/utils/app_routes.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/core/utils/app_text_styles.dart';
import 'package:super_fitness/core/utils/youtube_url.dart';
import 'package:super_fitness/core/widgets/app_scaffold.dart';
import 'package:super_fitness/core/widgets/custom_app_bar.dart';
import 'package:super_fitness/core/widgets/custom_error_state_view.dart';
import 'package:super_fitness/features/home/domain/entities/meal_details_entity.dart';
import 'package:super_fitness/features/home/domain/entities/meal_ingredient_entity.dart';
import 'package:super_fitness/features/home/presentation/view_model/meal_details_view_model/meal_details_cubit.dart';
import 'package:super_fitness/features/home/presentation/view_model/meal_details_view_model/meal_details_event.dart';
import 'package:super_fitness/features/home/presentation/view_model/meal_details_view_model/meal_details_state.dart';
import 'package:super_fitness/features/home/presentation/widgets/meal_details_section.dart';
import 'package:super_fitness/features/home/presentation/widgets/meal_ingredients_list.dart';
import 'package:super_fitness/features/home/presentation/widgets/meal_tags_wrap.dart';
import 'package:super_fitness/features/home/presentation/widgets/meal_video_preview.dart';

class MealDetailsScreen extends StatelessWidget {
  /// Shown in the app bar while the real record loads, so the title doesn't
  /// pop in — the grid already knows the meal's name when it navigates here.
  final String mealName;

  const MealDetailsScreen({super.key, required this.mealName});

  /// Stand-in shaped like a real recipe, rendered behind the skeleton shimmer.
  static const _skeletonDetails = MealDetailsEntity(
    id: '',
    name: 'Loading meal name',
    thumbnail: '',
    category: 'Category',
    area: 'Area',
    instructions:
        'Loading the recipe steps for this meal, which usually run to a '
        'few sentences across a couple of paragraphs.',
    ingredients: [
      MealIngredientEntity(name: 'Ingredient', measure: '100g'),
      MealIngredientEntity(name: 'Ingredient', measure: '2 tbs'),
      MealIngredientEntity(name: 'Ingredient', measure: '1 tsp'),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundImage: AppImages.homeBackground,
      blurSigma: 0,
      appBar: CustomAppBar(
        title: mealName,
        onBackPressed: () => Navigator.pop(context),
      ),
      body: BlocBuilder<MealDetailsCubit, MealDetailsState>(
        builder: (context, state) => switch (state.status) {
          MealDetailsStatus.initial ||
          MealDetailsStatus.loading => _buildContent(
            context,
            _skeletonDetails,
            isLoading: true,
          ),
          MealDetailsStatus.error => SingleChildScrollView(
            child: CustomErrorStateView(
              message: state.errorMessage.isNotEmpty
                  ? state.errorMessage
                  : AppStrings.mealDetailsNotFound,
              onRetry: () => context.read<MealDetailsCubit>().doIntent(
                const LoadMealDetailsEvent(),
              ),
            ),
          ),
          // `details` is non-null on success — the cubit downgrades an empty
          // payload to `error` precisely so this can't blow up.
          MealDetailsStatus.success => _buildContent(context, state.details!),
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    MealDetailsEntity details, {
    bool isLoading = false,
  }) {
    final embedUrl = YoutubeUrl.embedUrlOf(details.youtubeUrl);
    final tags = [
      if (details.category.isNotEmpty) details.category,
      if (details.area.isNotEmpty) details.area,
      ...details.tags,
    ];

    return Skeletonizer(
      enabled: isLoading,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MealVideoPreview(
              thumbnail: details.thumbnail,
              // No player while skeletonized — the tap target would be a lie,
              // and there's no url to open yet.
              onPlay: (isLoading || embedUrl == null)
                  ? null
                  : () => _openVideo(context, details.name, embedUrl),
            ),
            SizedBox(height: 16.h),
            Text(details.name, style: AppTextStyles.white24500),
            if (tags.isNotEmpty) ...[
              SizedBox(height: 12.h),
              MealTagsWrap(tags: tags),
            ],
            if (details.ingredients.isNotEmpty) ...[
              SizedBox(height: 24.h),
              MealDetailsSection(
                title: AppStrings.ingredients.tr(),
                child: MealIngredientsList(ingredients: details.ingredients),
              ),
            ],
            if (details.instructions.isNotEmpty) ...[
              SizedBox(height: 24.h),
              MealDetailsSection(
                title: AppStrings.description.tr(),
                child: Text(
                  details.instructions,
                  style: AppTextStyles.white2016500,
                ),
              ),
            ],
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  void _openVideo(BuildContext context, String title, String embedUrl) {
    Navigator.pushNamed(
      context,
      AppRoutes.mealVideo,
      arguments: MealVideoArgs(embedUrl: embedUrl, title: title),
    );
  }
}
