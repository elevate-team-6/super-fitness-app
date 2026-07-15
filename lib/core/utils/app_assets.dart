// ---------------------------------------------------------------------------
// TEAM INSTRUCTIONS - HOW TO ADD NEW ASSETS:
// 1. Add the asset to 'assets/icons/'.
// 2. Add the asset name to the appropriate class below.
// 3. Use lowerCamelCase for variable names.
// 4. Always use the path constants (_iconsPath).
// ---------------------------------------------------------------------------

abstract class AppIcons {
  static const String _iconsPath = 'assets/icons/';

  // Example: static const String yourIcon = '${_iconsPath}icon_name.svg';
  static const String fitnessAppIcon = '${_iconsPath}fitness_app_icon.png';
  static const String home = '${_iconsPath}home.svg';
  static const String arrowLeft = '${_iconsPath}arrow_left.svg';
  static const String back = '${_iconsPath}back.svg';
  static const String chat = '${_iconsPath}chat.svg';
  static const String edit = '${_iconsPath}edit.svg';
  static const String email = '${_iconsPath}email.svg';
  static const String eye = '${_iconsPath}eye.svg';
  static const String lock = '${_iconsPath}lock.svg';
  static const String person = '${_iconsPath}person.svg';
  static const String profile = '${_iconsPath}profile.svg';
  static const String workOut = '${_iconsPath}work_out.svg';
  static const String google = '${_iconsPath}Google.png';
  static const String facebook = '${_iconsPath}Vector.png';
}

abstract class AppImages {
  static const String _imagesPath = 'assets/images/';

  // Example: static const String yourIcon = '${_imagesPath}image_name.svg';
  static const String fitnessAppLogo = '${_imagesPath}lancher_logo.png';
  static const String authBackground = '${_imagesPath}auth_background.png';
  static const String chatBackground = '${_imagesPath}chat_background.jpg';
  static const String homeBackground = '${_imagesPath}home_background.jpg';
  static const String onboardingBackground =
      '${_imagesPath}onboarding_background.jpg';
  static const String onboarding1 = '${_imagesPath}onboarding1.png';
  static const String onboarding2 = '${_imagesPath}onboarding2.png';
  static const String onboarding3 = '${_imagesPath}onboarding3.png';
}

abstract class AppLottie {
  static const String _lottiePath = 'assets/lottie_files/';

  static const String loading = '${_lottiePath}loading.json';
}
