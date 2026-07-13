import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:super_fitness/config/services/auth_service.dart';
import 'package:super_fitness/core/utils/app_assets.dart';
import 'package:super_fitness/core/utils/app_routes.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/core/widgets/app_scaffold.dart';
import 'package:super_fitness/features/onboarding/widgets/onboarding_info.dart';
import 'package:super_fitness/features/onboarding/widgets/onboarding_skip_button.dart';

import '../../../config/services/exit_app_dialog.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _pageController;
  int _currentIndex = 0;
  late final List<OnboardingModel> _onboardingData;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _onboardingData = onBoardingList;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _onNext() async {
    if (_currentIndex < _onboardingData.length - 1) {
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      await AuthService.setOnboardingCompleted();
      if (mounted) {
        await Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    }
  }

  void _onBack() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (_currentIndex > 0) {
          _onBack();
          return;
        }
        final shouldExit = await ExitAppDialog.show(context);
        if (shouldExit == true) await SystemNavigator.pop();
      },
      child: AppScaffold(
        backgroundImage: AppImages.onboardingBackground,
        body: Column(
          children: [
            // Skip Button
            OnboardingSkipButton(
              pageController: _pageController,
              currentIndex: _currentIndex,
              itemCount: _onboardingData.length,
            ),

            // Images PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentIndex = index),
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) => Image.asset(
                  _onboardingData[index].image,
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomCenter,
                ),
              ),
            ),

            // Bottom Content
            OnboardingInfo(
              model: _onboardingData[_currentIndex],
              itemCount: _onboardingData.length,
              currentIndex: _currentIndex,
              onNext: _onNext,
              onBack: _onBack,
            ),
          ],
        ),
      ),
    );
  }
}

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
