import 'package:injectable/injectable.dart';
import 'package:super_fitness/config/services/facebook_auth_service.dart';
import 'package:super_fitness/config/services/google_auth_service.dart';
import 'package:super_fitness/features/auth/data/data_sources/social_auth_data_source_contract.dart';
import 'package:super_fitness/features/auth/data/models/response/social_account_model.dart';

@Injectable(as: SocialAuthDataSource)
class SocialAuthDataSourceImpl implements SocialAuthDataSource {
  final GoogleAuthService _googleAuthService;
  final FacebookAuthService _facebookAuthService;

  SocialAuthDataSourceImpl(this._googleAuthService, this._facebookAuthService);

  @override
  Future<SocialAccountModel?> signInWithGoogle() {
    return _googleAuthService.signIn();
  }

  @override
  Future<SocialAccountModel?> signInWithFacebook() {
    return _facebookAuthService.signIn();
  }
}
