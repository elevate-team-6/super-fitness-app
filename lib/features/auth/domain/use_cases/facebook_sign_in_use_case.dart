import 'package:injectable/injectable.dart';
import 'package:super_fitness/config/base_response/base_response.dart';
import 'package:super_fitness/features/auth/data/models/request/sign_in_request_model.dart';
import 'package:super_fitness/features/auth/domain/entities/sign_in_entity.dart';
import 'package:super_fitness/features/auth/domain/entities/social_account_entity.dart';
import 'package:super_fitness/features/auth/domain/entities/social_signup_entity.dart';
import 'package:super_fitness/features/auth/domain/repo/auth_repo_contract.dart';
import 'package:super_fitness/features/auth/domain/utils/social_password_generator.dart';

@injectable
class FacebookSignInUseCase {
  final AuthRepoContract _repo;

  FacebookSignInUseCase(this._repo);

  Future<BaseResponse<dynamic>> call() async {
    final result = await _repo.signInWithFacebook();

    switch (result) {
      case SuccessBaseResponse<SocialAccountEntity>():
        final socialAccount = result.data!;
        final password =
            SocialPasswordGenerator.deriveFromEmail(socialAccount.email);

        final loginResult = await _repo.signIn(
          SignInRequestModel(
            email: socialAccount.email,
            password: password,
          ),
        );

        switch (loginResult) {
          case SuccessBaseResponse<SignInEntity>():
            return loginResult;
          case ErrorBaseResponse<SignInEntity>():
            // If sign-in fails after social success, assume user is not registered.
            return SuccessBaseResponse<SocialSignupEntity>(
              SocialSignupEntity(
                firstName: socialAccount.firstName ?? '',
                lastName: socialAccount.lastName ?? '',
                email: socialAccount.email,
                password: password,
              ),
            );
        }

      case ErrorBaseResponse<SocialAccountEntity>():
        return ErrorBaseResponse(result.errorMessage);
    }
  }
}
