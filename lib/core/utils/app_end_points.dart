abstract class AppEndPoints {
  // Base URL:
  static const String baseUrl = "https://fitness.elevateegy.com/api/v1";

  // API EndPoints:-
  static const String auth = "$baseUrl/auth";
  static const String forgetPassword = "$auth/forgotPassword";
  static const String resetPassword = "$auth/resetPassword";
  static const String verifyOtp = "$auth/verifyResetCode";

  // Auth
  static const String signin = "$baseUrl/auth/signin";
  // ---------------------------------------------------------------------------
  // TO ADD NEW ENDPOINTS:
  // 1. Group them by feature (e.g., // Products, // Cart).
  // 2. Use 'static const String' with camelCase naming.
  // 3. Always prefix the path with '$baseUrl'.
  // Example: static const String getProducts = "$baseUrl/products";
  // ---------------------------------------------------------------------------
}
