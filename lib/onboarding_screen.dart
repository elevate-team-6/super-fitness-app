import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:super_fitness/core/utils/app_assets.dart';
import 'package:super_fitness/core/widgets/app_scaffold.dart';
import 'package:super_fitness/core/widgets/custom_loading.dart';
import 'package:super_fitness/core/widgets/custom_snack_bar.dart';

import 'config/services/exit_app_dialog.dart';

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
          SystemNavigator.pop();
        }
      },
      child: AppScaffold(
        backgroundImage: AppImages.homeBackground,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
    );
  }
}
