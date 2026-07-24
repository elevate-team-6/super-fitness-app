import 'package:super_fitness/features/home/domain/entities/meal_entity.dart';

const MealEntity kSkeletonMeal = MealEntity(
  id: '',
  name: 'Loading meal name',
  thumbnail: '',
);

const int kSkeletonMealCount = 6;

List<MealEntity> get skeletonMeals =>
    List.filled(kSkeletonMealCount, kSkeletonMeal);
