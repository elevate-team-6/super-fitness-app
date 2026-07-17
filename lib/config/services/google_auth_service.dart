import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
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

      final idToken = googleUser.authentication.idToken;
      if (idToken == null) {
        // This is usually due to missing SHA-1 in Firebase Console or wrong serverClientId.
        if (kDebugMode) {
          print(
            'GoogleAuthService: idToken is null. Check Firebase SHA-1 and google-services.json',
          );
        }
        return null;
      }

      final credential = GoogleAuthProvider.credential(idToken: idToken);
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      final user = userCredential.user;
      if (user == null || user.email == null) return null;

      final names = _splitName(user.displayName ?? googleUser.displayName);

      return SocialAccountData(
        uid: user.uid,
        email: user.email!,
        firstName: names.$1,
        lastName: names.$2,
        photo: user.photoURL ?? googleUser.photoUrl,
      );
    } on GoogleSignInException catch (e) {
      if (kDebugMode) {
        print('GoogleAuthService: GoogleSignInException: $e');
      }
      // Error code 16 is typically SIGN_IN_FAILED/CANCELED due to configuration issues.
      if (e.code == GoogleSignInExceptionCode.canceled) {
        if (e.toString().contains('[16]')) {
          throw Exception(
            'Google Sign-In failed [16]: This usually means a SHA-1 mismatch or missing Support Email in Firebase.',
          );
        }
        return null;
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print('GoogleAuthService: Unexpected Error: $e');
      }
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
