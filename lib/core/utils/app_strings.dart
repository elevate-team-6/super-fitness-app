abstract class AppStrings {
  // ===========================================================================
  // Configuration Keys (Keys used in JSON files)
  // ===========================================================================

  // SnackBar
  static const String success = 'success';
  static const String oops = 'oops';

  // Error Messages
  static const String someThingWentWrong = 'someThingWentWrong';
  static const String connectionTimeout = 'connectionTimeout';
  static const String sendTimeout = 'sendTimeout';
  static const String receiveTimeout = 'receiveTimeout';
  static const String requestCancelled = 'requestCancelled';
  static const String noInternetConnection = 'noInternetConnection';
  static const String unexpectedError = 'unexpectedError';
  static const String unknownError = 'unknownError';
  static const String invalidRequest = 'invalidRequest';
  static const String authFailed = 'authFailed';
  static const String forbidden = 'forbidden';
  static const String notFound = 'notFound';
  static const String serverError = 'serverError';
  static const String profileDataNotFound = 'profileDataNotFound';
  static const String defaultError = 'defaultError';
  static const String defaultErrorTryAgain = 'defaultErrorTryAgain';
  static const String unexpectedErrorTryAgain = 'unexpectedErrorTryAgain';
  static const String userAlreadyExists = 'userAlreadyExists';
  static const String invalidGender = 'invalidGender';
  static const String invalidPhoneFormat = 'invalidPhoneFormat';
  static const String retry = 'retry';

  // Validation Messages
  static const String emailRequired = 'emailRequired';
  static const String invalidEmail = 'invalidEmail';
  static const String invalidPassword = 'invalidPassword';
  static const String passwordRequired = 'passwordRequired';
  static const String passwordTooShort = 'passwordTooShort';
  static const String passwordLowercase = 'passwordLowercase';
  static const String passwordUppercase = 'passwordUppercase';
  static const String passwordNumber = 'passwordNumber';
  static const fileDoesNotExist = 'fileDoesNotExist';
  static const appMultipartFileRequiresEitherFilePathOrBytes =
      'appMultipartFileRequiresEitherFilePathOrBytes';
  static const String passwordSpecialCharacter = 'passwordSpecialCharacter';
  static const String passwordNotMatched = 'passwordNotMatched';
  static const String confirmPasswordRequired = 'confirmPasswordRequired';
  static const String usernameRequired = 'usernameRequired';
  static const String usernameTooShort = 'usernameTooShort';
  static const String usernameInvalid = 'usernameInvalid';
  static const String firstNameRequired = 'firstNameRequired';
  static const String lastNameRequired = 'lastNameRequired';
  static const String nameTooShort = 'nameTooShort';
  static const String nameNoNumbers = 'nameNoNumbers';
  static const String phoneRequired = 'phoneRequired';
  static const String phoneRequiredEgyptian = 'phoneRequiredEgyptian';
  static const String invalidPhone = 'invalidPhone';
  static const String phoneMustStartWithCountryCode =
      'phoneMustStartWithCountryCode';
  static const String recipientNameRequired = 'recipientNameRequired';
  static const String isRequired = 'isRequired';
  static const String fieldRequired = 'fieldRequired';
  static const String vehicleNumberRequired = 'vehicleNumberRequired';
  static const String idNumberRequired = 'idNumberRequired';
  static const String invalidIdNumber = 'invalidIdNumber';
  static const String pleaseUploadNationalId = 'pleaseUploadNationalId';
  static const String pleaseUploadDrivingLicense = 'pleaseUploadDrivingLicense';
  static const String loginSuccess = 'login_success';

  // Exit App Dialog
  static const String exitAppTitle = 'exitAppTitle';
  static const String exitAppMessage = 'exitAppMessage';
  static const String yes = 'yes';
  static const String no = 'no';
  static const String cancel = 'cancel';

  // Onboarding
  static const String onboardingTitle1 = 'onboardingTitle1';
  static const String onboardingDesc1 = 'onboardingDesc1';
  static const String onboardingTitle2 = 'onboardingTitle2';
  static const String onboardingDesc2 = 'onboardingDesc2';
  static const String onboardingTitle3 = 'onboardingTitle3';
  static const String onboardingDesc3 = 'onboardingDesc3';
  static const String skip = 'skip';
  static const String back = 'back';
  static const String next = 'next';
  static const String doIt = 'doIt';

  // forget password
  static const String forgetPassword = 'forgetPassword';
  static const String enterEmail = 'enterEmail';
  static const String confirm = 'confirm';
  static const String dontRecieveCode = 'dontRecieveCode';
  static const String sentOtP = 'sentOtP';
  static const String createNewPassword = 'createNewPassword';
  static const String passwordMoreCharacter = 'passwordMoreCharacter';
  static const String otpCode = 'otpCode';
  static const String resendCode = 'resendCode';
  static const String enterOtp = 'enterOtp';
  static const String verificationCodeSentToYourEmail =
      'verificationCodeSentToYourEmail';
  static const String verificationCodeIsCorrect = 'verificationCodeIsCorrect';
  static const String passwordResetSuccessfully = 'passwordResetSuccessfully';
  static const String otpCodeInvalid = 'otpCodeInvalid';

  // Login screen
  static const String heyThere = 'hey_there';
  static const String welcomeBack = 'welcome_back';
  static const String login = 'login';
  static const String orText = 'or';
  static const String appleSignInIsComingSoon = 'apple_sign_in_is_coming_soon';
  static const String googleLoginCancelled = 'google_login_cancelled';
  static const String facebookLoginCancelled = 'facebook_login_cancelled';
  static const String dontHaveAccount = 'dont_have_account';
  static const String register = 'register';
  static const String explore = 'explore';
  static const String workouts = 'workouts';
  static const String chat = 'chat';
  static const String profile = 'profile';
  static const String selectMuscleGroup = 'selectMuscleGroup';
  static const String noMusclesFound = 'noMusclesFound';
  static const String exitConfirmation = 'exit_confirmation';

  // Signup
  static const String registerFailed = 'registerFailed';
  static const String registerSuccess = 'registerSuccess';

  // Auth Flow UI
  static const String loginWelcome = 'loginWelcome';
  static const String email = 'email';
  static const String password = 'password';
  static const String forgotYourPassword = 'forgotYourPassword';
  static const String registerPrompt = 'registerPrompt';
  static const String signupWelcome = 'signupWelcome';
  static const String signupCreateAccount = 'signupCreateAccount';
  static const String firstName = 'firstName';
  static const String lastName = 'lastName';
  static const String loginPrompt = 'loginPrompt';
  static const String tellUsAboutYourself = 'tellUsAboutYourself';
  static const String genderTitle = 'genderTitle';
  static const String male = 'male';
  static const String female = 'female';
  static const String ageTitle = 'ageTitle';
  static const String personalizationDesc = 'personalizationDesc';
  static const String weightTitle = 'weightTitle';
  static const String heightTitle = 'heightTitle';
  static const String year = 'year';
  static const String kg = 'kg';
  static const String cm = 'cm';
  static const String done = 'done';
  static const String goalTitle = 'goalTitle';
  static const String gainWeight = 'gainWeight';
  static const String loseWeight = 'loseWeight';
  static const String getFitter = 'getFitter';
  static const String gainMoreFlexible = 'gainMoreFlexible';
  static const String learnTheBasic = 'learnTheBasic';
  static const String activityLevelTitle = 'activityLevelTitle';
  static const String sedentary = 'sedentary';
  static const String lightlyActive = 'lightlyActive';
  static const String moderatelyActive = 'moderatelyActive';
  static const String veryActive = 'veryActive';
  static const String extraActive = 'extraActive';
  static const String or = 'or';

  // Food
  static const String recommendationForYou = 'recommendationForYou';
  static const String breakfast = 'breakfast';
  static const String lunch = 'lunch';
  static const String dinner = 'dinner';
  static const String noMealsFound = 'noMealsFound';
  static const String seeAll = 'seeAll';
  static const String foodRecommendation = 'foodRecommendation';

  // Meal details
  static const String detailsFood = 'detailsFood';
  static const String detailsFoodNotFound = 'detailsFoodNotFound';
  static const String ingredients = 'ingredients';
  static const String description = 'description';
  static const String watchVideo = 'watchVideo';
}
