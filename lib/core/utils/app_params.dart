abstract class ApiParameters {
  // Auth
  static const String email = 'email';
  static const String password = 'password';
  static const String message = 'message';
  static const String token = 'token';

  // User
  static const String user = 'user';
  static const String id = '_id';
  static const String firstName = 'firstName';
  static const String lastName = 'lastName';
  static const String gender = 'gender';
  static const String age = 'age';
  static const String weight = 'weight';
  static const String height = 'height';
  static const String activityLevel = 'activityLevel';
  static const String goal = 'goal';
  static const String photo = 'photo';
  static const String createdAt = 'createdAt';

  // Meals (TheMealDB)
  static const String meals = 'meals';
  static const String idMeal = 'idMeal';
  static const String strMeal = 'strMeal';
  static const String strMealThumb = 'strMealThumb';
  static const String strArea = 'strArea';
  static const String strCountry = 'strCountry';

  // Meal details (lookup.php)
  static const String strCategory = 'strCategory';
  static const String strInstructions = 'strInstructions';
  static const String strTags = 'strTags';
  static const String strYoutube = 'strYoutube';
  static const String strSource = 'strSource';

  /// TheMealDB spreads ingredients across `strIngredient1..20` / `strMeasure1..20`
  /// instead of nesting them in a list, so these are prefixes joined with an
  /// index rather than whole keys.
  static const String strIngredientPrefix = 'strIngredient';
  static const String strMeasurePrefix = 'strMeasure';
  static const int mealIngredientSlots = 20;

  // Meals query params
  static const String category = 'c';
  static const String mealId = 'i';

  // Nutrition (Groq chat completions — OpenAI wire format)
  static const String model = 'model';
  static const String messages = 'messages';
  static const String role = 'role';
  static const String content = 'content';
  static const String systemRole = 'system';
  static const String userRole = 'user';
  static const String temperature = 'temperature';
  static const String responseFormat = 'response_format';
  static const String jsonSchemaType = 'json_schema';
  static const String name = 'name';
  static const String strict = 'strict';
  static const String schema = 'schema';
  static const String choices = 'choices';
  static const String type = 'type';
  static const String properties = 'properties';
  static const String required = 'required';
  static const String additionalProperties = 'additionalProperties';

  // Nutrition payload (the JSON the model is constrained to return)
  static const String caloriesKcal = 'calories_kcal';
  static const String proteinG = 'protein_g';
  static const String carbsG = 'carbs_g';
  static const String fatG = 'fat_g';
}
