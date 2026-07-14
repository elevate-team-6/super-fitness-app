import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_fitness/core/utils/app_assets.dart';
import 'package:super_fitness/core/utils/app_routes.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/core/widgets/app_scaffold.dart';

import '../view_model/signup_view_model/register_event.dart';
import '../view_model/signup_view_model/signup_cubit.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundImage: AppImages.authBackground,
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            context.read<SignupCubit>().doEvent(NextStepEvent());
            Navigator.pushNamed(context, AppRoutes.completeRegister);
          },
          child: Text(AppStrings.register.tr()),
        ),
      ),
    );
  }
}
