import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'package:super_fitness/config/services/social_account_data.dart';

/// Wraps Google Sign-In + Firebase Auth so the rest of the app never touches
/// either SDK directly.
@lazySingleton
class GoogleAuthService {
  final FirebaseAuth _firebaseAuth;

  GoogleAuthService(this._firebaseAuth);

  /// Must be awaited once before any other method (google_sign_in 7.x).
  /// [serverClientId] is required on Android for an idToken to be returned —
  /// it's the *Web* client ID from the Firebase console, not the Android one.
  static Future<void> initialize({String? serverClientId}) {
    return GoogleSignIn.instance.initialize(serverClientId: serverClientId);
  }

  /// Opens the Google account picker and signs the user into Firebase.
  /// Returns null if the user dismisses the picker.
  Future<SocialAccountData?> signIn() async {
    try {
      final googleUser = await GoogleSignIn.instance.authenticate(
        scopeHint: const ['email', 'profile'],
      );

      final authentication = googleUser.authentication;
      final idToken = authentication.idToken;

      if (idToken == null) {
        // This is usually due to missing SHA-1 in Firebase Console or wrong serverClientId.
        const errorMsg =
            'GoogleAuthService: idToken is null. Check Firebase SHA-1, Support Email, and google-services.json';
        throw Exception(errorMsg);
      }

      final credential = GoogleAuthProvider.credential(idToken: idToken);
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      final user = userCredential.user;

      // FALLBACK LOGIC: If Firebase user email is null (happens in some edge cases),
      // we use the email from the GoogleSignInAccount we just authenticated with.
      final effectiveEmail = user?.email ?? googleUser.email;

      if (user == null || effectiveEmail.trim().isEmpty) {
        return null;
      }

      final names = _splitName(user.displayName ?? googleUser.displayName);

      return SocialAccountData(
        uid: user.uid,
        email: effectiveEmail,
        firstName: names.$1,
        lastName: names.$2,
        photo: user.photoURL ?? googleUser.photoUrl,
      );
    } on GoogleSignInException catch (e) {
      // Error code 10 is DEVELOPER_ERROR, often SHA-1 mismatch.
      if (e.code.name == 'developerError' || e.code.toString().contains('10')) {
        throw Exception(
          'Google Sign-In Developer Error [10]: Usually a SHA-1 mismatch or wrong package name in Firebase.',
        );
      }

      if (e.code == GoogleSignInExceptionCode.canceled) {
        return null;
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await GoogleSignIn.instance.signOut();
    await _firebaseAuth.signOut();
  }

  /// Google gives one display name; the API wants first + last separately.
  (String?, String?) _splitName(String? displayName) {
    if (displayName == null || displayName.trim().isEmpty) {
      return (null, null);
    }
    final parts = displayName.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return (parts.first, null);
    return (parts.first, parts.sublist(1).join(' '));
  }
}
