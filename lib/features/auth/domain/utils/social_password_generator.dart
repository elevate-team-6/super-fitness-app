import 'dart:convert';
import 'package:crypto/crypto.dart';

/// [SocialPasswordGenerator] encapsulates the domain logic for deriving
/// deterministic passwords from social media accounts.
///
/// This is a temporary measure until the backend supports direct social
/// authentication tokens. It ensures that a stable, repeatable password
/// can be generated from the same social identity across devices.
abstract class SocialPasswordGenerator {
  SocialPasswordGenerator._();

  static const String _requiredSpecialChar = '@';

  /// Derives a deterministic password based on the user's social email.
  /// The resulting password satisfies standard complexity requirements.
  static String deriveFromEmail(String email) {
    final bytes = utf8.encode(email.trim().toLowerCase());
    final digest = sha256.convert(bytes);

    // Base64Url encoding provides a compact mix of alphanumeric characters.
    final base64String = base64Url.encode(digest.bytes).replaceAll('=', '');
    final seed = base64String.substring(0, 16);

    // Guaranteed inclusion of required character classes: Uppercase, digit, special, lowercase.
    return 'A1$_requiredSpecialChar${seed.toLowerCase()}${seed.toUpperCase()}'
        .substring(0, 20);
  }
}
