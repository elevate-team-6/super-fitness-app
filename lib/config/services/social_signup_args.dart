/// Account data carried over from a social sign-in, so the user only has to
/// fill in the fitness details the social provider can't give us.
class SocialSignupArgs {
  final String firstName;
  final String lastName;
  final String email;
  final String password;

  const SocialSignupArgs({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
  });
}
