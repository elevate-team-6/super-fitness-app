import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:super_fitness/core/utils/app_assets.dart';
import 'package:super_fitness/core/widgets/app_scaffold.dart';
import 'package:super_fitness/core/widgets/custom_app_bar.dart';
import 'package:super_fitness/core/widgets/custom_glass_container.dart';
import 'package:super_fitness/core/widgets/custom_loading.dart';
import 'package:super_fitness/core/widgets/custom_snack_bar.dart';

import 'config/services/exit_app_dialog.dart';
import 'core/utils/app_text_styles.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldExit = await ExitAppDialog.show(context);
        if (shouldExit == true) {
          await SystemNavigator.pop();
        }
      },
      child: AppScaffold(
        backgroundImage: AppImages.authBackground,
        appBar: CustomAppBar(
          onBackPressed: () {
            Navigator.pop(context);
          },
        ),
        body: Center(
          child: CustomGlassContainer(
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Super Fitness', style: AppTextStyles.white20500),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    CustomSnackBar.showSuccessMessage('Success message');
                  },
                  child: const Text('Show Success'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    CustomSnackBar.showErrorMessage('Error message');
                  },
                  child: const Text('Show Error'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    LoadingDialog.show(context: context);
                    Future.delayed(const Duration(seconds: 3), () {
                      LoadingDialog.hide();
                    });
                  },
                  child: const Text('Show Loading'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
