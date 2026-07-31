abstract class AppEndPoints {
  // Base URL:
  static const String baseUrl = "https://fitness.elevateegy.com/api/v1";

  // API EndPoints:-

  // Gateway
  // static const String chatGatewayUrl = "http://10.0.2.2:8001/v1/chat"; // local
  static const String chatGatewayUrl =
      "https://superfitnessgateway-7oev1bfs.b4a.run/v1/chat";

  // Auth
  static const String signin = "$baseUrl/auth/signin";
  static const String signup = "$baseUrl/auth/signup";
  static const String forgetPassword = "$baseUrl/auth/forgotPassword";
  static const String resetPassword = "$baseUrl/auth/resetPassword";
  static const String verifyOtp = "$baseUrl/auth/verifyResetCode";
  static const String changePassword = "$baseUrl/auth/change-password";
  static const String editProfile = "$baseUrl/auth/editProfile";
  static const String uploadPhoto = "$baseUrl/auth/upload-photo";
  // Workouts
  static const String getDifficultyLevelsByPrimeMover =
      "$baseUrl/levels/difficulty-levels/by-prime-mover";
  static const String getExercisesByMuscleDifficulty =
      "$baseUrl/exercises/by-muscle-difficulty";

  // Meals (TheMealDB)
  // Third-party API, so these are NOT prefixed with `baseUrl`. They are served
  // through the @Named('external') Dio, which carries no auth token.
  static const String mealDbBaseUrl = "https://www.themealdb.com/api/json/v1/1";
  static const String mealCategories = "$mealDbBaseUrl/categories.php";
  static const String mealsByCategory = "$mealDbBaseUrl/filter.php";
  static const String detailsFood = "$mealDbBaseUrl/lookup.php";

  // Workouts
  static const String muscles = "$baseUrl/muscles";
  static const String musclesGroup = "$baseUrl/musclesGroup";

  // Exercises
  static const String exercises = "$baseUrl/exercises";
  static const String exercisesByMuscleDifficulty =
      "$baseUrl/exercises/by-muscle-difficulty";

  // Muscles
  static const String randomMuscles = "$baseUrl/muscles/random";

  // Levels
  static const String levels = "$baseUrl/levels";

  // ---------------------------------------------------------------------------
  // TO ADD NEW ENDPOINTS:
  // 1. Group them by feature (e.g., // Products, // Cart).
  // 2. Use 'static const String' with camelCase naming.
  // 3. Always prefix the path with '$baseUrl'.
  // Example: static const String getProducts = "$baseUrl/products";
  // ---------------------------------------------------------------------------
}
