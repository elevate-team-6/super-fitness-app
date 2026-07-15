import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Derives a deterministic password for a Google account.
///
/// TEMPORARY — remove once the backend exposes a proper `POST /auth/google`
/// endpoint that trades a Firebase ID token for one of our tokens.
///
/// Our signup/signin endpoints require a password, but Google never gives us
/// one. So we derive one from the account's Google uid, which is stable for the
/// same account across devices and reinstalls — meaning the user can sign back
/// in after switching phones.
///
/// This is NOT a secret: anything derived on the client can be reproduced by
/// the client. It is only acceptable because this is a training project against
/// a sandbox API. Do not ship this pattern to real users.
abstract class GooglePasswordDerivation {
  GooglePasswordDerivation._();

  /// Special character appended to satisfy the project's password policy.
  static const String _specialChar = '@';

  /// Builds a password that always satisfies AppValidations.validatePassword:
  /// 8+ characters, with a lowercase letter, an uppercase letter, a digit and
  /// a special character.
  static String fromUid(String uid) {
    final digest = sha256.convert(utf8.encode(uid));
    // Base64 gives us a mix of upper/lower/digits in a compact string.
    final base = base64Url.encode(digest.bytes).replaceAll('=', '');
    final core = base.substring(0, 16);

    // Guarantee each required character class is present regardless of what the
    // hash happened to produce.
    return 'A1$_specialChar${core.toLowerCase()}${core.toUpperCase()}'
        .substring(0, 20);
  }
}
