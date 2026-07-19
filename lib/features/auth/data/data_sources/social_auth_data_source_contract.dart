import '../models/response/social_account_model.dart';

abstract interface class SocialAuthDataSource {
  Future<SocialAccountModel?> signInWithGoogle();
  Future<SocialAccountModel?> signInWithFacebook();
}
