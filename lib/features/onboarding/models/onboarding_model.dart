import 'package:easy_localization/easy_localization.dart';
import 'package:super_fitness/core/utils/app_assets.dart';
import 'package:super_fitness/core/utils/app_strings.dart';

class OnboardingModel {
  final String title;
  final String description;
  final String image;

  OnboardingModel({
    required this.title,
    required this.description,
    required this.image,
  });
}

List<OnboardingModel> onBoardingList = [
  OnboardingModel(
    title: AppStrings.onboardingTitle1.tr(),
    description: AppStrings.onboardingDesc1.tr(),
    image: AppImages.onboarding1,
  ),
  OnboardingModel(
    title: AppStrings.onboardingTitle2.tr(),
    description: AppStrings.onboardingDesc2.tr(),
    image: AppImages.onboarding2,
  ),
  OnboardingModel(
    title: AppStrings.onboardingTitle3.tr(),
    description: AppStrings.onboardingDesc3.tr(),
    image: AppImages.onboarding3,
  ),
];
