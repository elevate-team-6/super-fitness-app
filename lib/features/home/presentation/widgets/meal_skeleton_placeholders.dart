import 'package:super_fitness/features/home/domain/entities/meal_entity.dart';

/// Placeholder data for the meal grid's loading state.
///
/// Skeletonizer traces the real [MealCard], so the placeholder only has to be
/// shaped like one — the strings are never read, they just size the bones.
const MealEntity kSkeletonMeal = MealEntity(
  id: '',
  name: 'Loading meal name',
  thumbnail: '',
  country: 'Country',
);

/// Enough to fill the grid on the tallest phone we support.
const int kSkeletonMealCount = 6;

/// The list handed to the grid while meals are loading.
List<MealEntity> get skeletonMeals =>
    List.filled(kSkeletonMealCount, kSkeletonMeal);
