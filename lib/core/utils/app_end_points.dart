abstract class AppEndPoints {
  // Base URL:
  static const String baseUrl = "https://fitness.elevateegy.com/api/v1";

  // API EndPoints:-

  // Auth
  static const String signin = "$baseUrl/auth/signin";
  static const String signup = "$baseUrl/auth/signup";
  static const String forgetPassword = "$baseUrl/auth/forgotPassword";
  static const String resetPassword = "$baseUrl/auth/resetPassword";
  static const String verifyOtp = "$baseUrl/auth/verifyResetCode";

  // Meals (TheMealDB)
  // Third-party API, so these are NOT prefixed with `baseUrl`. They are served
  // through the @Named('external') Dio, which carries no auth token.
  static const String mealDbBaseUrl = "https://www.themealdb.com/api/json/v1/1";
  static const String mealCategories = "$mealDbBaseUrl/categories.php";
  static const String mealsByCategory = "$mealDbBaseUrl/filter.php";
  static const String detailsFood = "$mealDbBaseUrl/lookup.php";

  // Nutrition (Groq)
  // TheMealDB ships no macros, so they are estimated from the recipe's own
  // ingredient list. Also served through the @Named('external') Dio.
  //
  // Groq speaks the OpenAI wire format, hence the `/openai/` segment — the
  // request and response shapes here are OpenAI's, not Groq-specific.
  static const String groqBaseUrl = "https://api.groq.com/openai/v1";
  static const String groqChatCompletions = "$groqBaseUrl/chat/completions";

  /// One of the two models that honour `strict: true` on a JSON schema, which
  /// is what guarantees the reply parses. Swapping this for a Llama model
  /// silently drops that guarantee — check Groq's structured-outputs docs
  /// before changing it.
  static const String groqModel = "openai/gpt-oss-120b";

  // ---------------------------------------------------------------------------
  // TO ADD NEW ENDPOINTS:
  // 1. Group them by feature (e.g., // Products, // Cart).
  // 2. Use 'static const String' with camelCase naming.
  // 3. Always prefix the path with '$baseUrl'.
  // Example: static const String getProducts = "$baseUrl/products";
  // ---------------------------------------------------------------------------
}
