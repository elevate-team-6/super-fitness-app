abstract class CatalogDbConstants {
  // Database Names
  static const String exercisesDb = 'exercises.db';
  static const String mealsDb = 'meals.db';

  // Tables
  static const String tableExercise = 'exercise';
  static const String tableMuscle = 'muscle';
  static const String tableMuscleGroup = 'muscle_group';
  static const String tableDifficultyLevel = 'difficulty_level';
  static const String tableEquipment = 'equipment';
  static const String tableBodyRegion = 'body_region';
  static const String tableMeal = 'meal';
  static const String tableMealCategory = 'meal_category';
  static const String tableMealArea = 'meal_area';
  static const String tableIngredient = 'ingredient';
  static const String tableMealIngredient = 'meal_ingredient';
  static const String tableMeta = 'meta';

  // Columns - Shared / General
  static const String columnId = 'id';
  static const String columnName = 'name';
  static const String columnNameAr = 'name_ar';
  static const String columnImage = 'image';
  static const String columnLegacyIds = 'legacy_ids';
  static const String columnRank = 'rank';
  static const String columnPosition = 'position';

  // Columns - Exercise Table Specific
  static const String columnDifficultyId = 'difficulty_id';
  static const String columnMuscleGroupId = 'muscle_group_id';
  static const String columnPrimeMoverId = 'prime_mover_id';
  static const String columnPrimaryEquipmentId = 'primary_equipment_id';
  static const String columnSecondaryEquipmentId = 'secondary_equipment_id';
  static const String columnBodyRegionId = 'body_region_id';
  static const String columnDemoUrl = 'demo_url';
  static const String columnExplainUrl = 'explain_url';
  static const String columnPopularity = 'popularity';
  static const String columnPosture = 'posture';
  static const String columnGrip = 'grip';
  static const String columnLaterality = 'laterality';
  static const String columnMechanics = 'mechanics';
  static const String columnForceType = 'force_type';
  static const String columnArmsMode = 'arms_mode';
  static const String columnLegsMode = 'legs_mode';
  static const String columnFootElevation = 'foot_elevation';
  static const String columnLoadPositionEnding = 'load_position_ending';
  static const String columnCombinationExercises = 'combination_exercises';
  static const String columnClassification = 'classification';
  static const String columnSecondaryMuscle = 'secondary_muscle';
  static const String columnTertiaryMuscle = 'tertiary_muscle';
  static const String columnPrimaryItems = 'primary_items';
  static const String columnSecondaryEquipment = 'secondary_equipment';
  static const String columnSecondaryItems = 'secondary_items';
  static const String columnSingleOrDoubleArm = 'single_or_double_arm';
  static const String columnMovementPattern1 = 'movement_pattern_1';
  static const String columnMovementPattern2 = 'movement_pattern_2';
  static const String columnMovementPattern3 = 'movement_pattern_3';
  static const String columnPlaneOfMotion1 = 'plane_of_motion_1';
  static const String columnPlaneOfMotion2 = 'plane_of_motion_2';
  static const String columnPlaneOfMotion3 = 'plane_of_motion_3';
  static const String columnBodyRegion = 'body_region';

  // Columns - Meal Table Specific
  static const String columnIdMeal = 'idMeal';
  static const String columnStrMeal = 'strMeal';
  static const String columnStrMealThumb = 'strMealThumb';
  static const String columnStrCategory = 'strCategory';
  static const String columnStrArea = 'strArea';
  static const String columnStrInstructions = 'strInstructions';
  static const String columnStrTags = 'strTags';
  static const String columnStrYoutube = 'strYoutube';
  static const String columnCategoryId = 'category_id';
  static const String columnAreaId = 'area_id';
  static const String columnThumb = 'thumb';
  static const String columnQty = 'qty';
  static const String columnUnit = 'unit';
  static const String columnIngredientId = 'ingredient_id';
  static const String columnStrCountry = 'strCountry';

  // Locale codes
  static const String localeAr = 'ar';
  static const String localeEn = 'en';

  // Aliases used in SQL and Models
  static const String aliasExerciseName = 'exercise';
  static const String aliasDifficultyLevel = 'difficulty_level';
  static const String aliasTargetMuscleGroup = 'target_muscle_group';
  static const String aliasPrimeMoverMuscle = 'prime_mover_muscle';
  static const String aliasPrimaryEquipment = 'primary_equipment';
  static const String aliasShortYoutubeLink =
      'short_youtube_demonstration_link';
  static const String aliasInDepthYoutubeLink =
      'in_depth_youtube_explanation_link';
  static const String aliasEnglishName = 'englishName';
  static const String aliasIdCategory = 'idCategory';
  static const String aliasMeasure = 'measure';
}
