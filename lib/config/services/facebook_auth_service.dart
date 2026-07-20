import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:injectable/injectable.dart';

import '../../features/auth/data/models/response/social_account_model.dart';

/// Wraps Facebook Login + Firebase Auth so the rest of the app never touches
/// either SDK directly.
@lazySingleton
class FacebookAuthService {
  final FirebaseAuth _firebaseAuth;

  FacebookAuthService(this._firebaseAuth);

  /// Opens the Facebook login flow and signs the user into Firebase.
  /// Returns null if the user cancels or Facebook withholds the email.
  Future<SocialAccountModel?> signIn() async {
    try {
      final result = await FacebookAuth.instance.login(
        permissions: const ['email', 'public_profile'],
      );

      if (result.status != LoginStatus.success) {
        if (result.status == LoginStatus.failed) {
          await FirebaseCrashlytics.instance.log(
            'Facebook Login Failed: ${result.message}',
          );
          await FirebaseCrashlytics.instance.recordError(
            Exception('Facebook Login Failed: ${result.message}'),
            StackTrace.current,
            reason: 'Facebook Login Status Failed',
          );
        }
        // Cancelled or failed — nothing to report, the caller stays put.
        return null;
      }

      final accessToken = result.accessToken;
      if (accessToken == null) {
        await FirebaseCrashlytics.instance.log(
          'Facebook Login Success but AccessToken is null',
        );
        return null;
      }

      // Renamed from `.token` in flutter_facebook_auth 7.x.
      final credential = FacebookAuthProvider.credential(
        accessToken.tokenString,
      );
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      final user = userCredential.user;
      if (user == null) {
        await FirebaseCrashlytics.instance.log(
          'Firebase User is null after Facebook Sign-In',
        );
        return null;
      }

      // Facebook doesn't always pass the email through the Firebase credential,
      // so fall back to the Graph API before giving up on the account.
      final profile = await FacebookAuth.instance.getUserData(
        fields: 'email,first_name,last_name,picture.width(400)',
      );

      final email = user.email ?? profile['email'] as String?;
      // Our signup keys off the email, so an account without one is unusable.
      if (email == null || email.isEmpty) {
        await FirebaseCrashlytics.instance.log(
          'Facebook Email is null/empty after Graph API call',
        );
        return null;
      }

      final names = _splitName(user.displayName);

      return SocialAccountModel(
        uid: user.uid,
        email: email,
        firstName: names.$1 ?? profile['first_name'] as String?,
        lastName: names.$2 ?? profile['last_name'] as String?,
        photo: user.photoURL,
      );
    } catch (e, stack) {
      await FirebaseCrashlytics.instance.recordError(
        e,
        stack,
        reason: 'Unexpected error in FacebookAuthService.signIn',
      );
      rethrow;
    }
  }

  Future<void> signOut() async {
    await FacebookAuth.instance.logOut();
    await _firebaseAuth.signOut();
  }

  /// Facebook gives one display name; the API wants first + last separately.
  (String?, String?) _splitName(String? displayName) {
    if (displayName == null || displayName.trim().isEmpty) {
      return (null, null);
    }
    final parts = displayName.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return (parts.first, null);
    return (parts.first, parts.sublist(1).join(' '));
  }
}
