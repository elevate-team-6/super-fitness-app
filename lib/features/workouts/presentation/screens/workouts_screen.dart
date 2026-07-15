import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/app_assets.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_scaffold.dart';

class WorkoutsScreen extends StatelessWidget {
  const WorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundImage: AppImages
          .onboardingBackground, // Using onboarding as placeholder for workouts
      body: Center(
        child: Text(AppStrings.workouts.tr(), style: AppTextStyles.white20500),
      ),
    );
  }
}
