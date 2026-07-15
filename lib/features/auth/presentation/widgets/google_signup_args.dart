/// Account data carried over from a Google sign-in, so the user only has to
/// fill in the fitness details Google can't give us.
class GoogleSignupArgs {
  final String firstName;
  final String lastName;
  final String email;
  final String password;

  const GoogleSignupArgs({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
  });
}
