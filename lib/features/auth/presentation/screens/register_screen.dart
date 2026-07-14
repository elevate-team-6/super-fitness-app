import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_fitness/config/base_ui_handler/ui_event_handler_mixin.dart';
import 'package:super_fitness/core/utils/app_assets.dart';
import 'package:super_fitness/core/utils/app_strings.dart';
import 'package:super_fitness/core/widgets/app_scaffold.dart';

import '../view_model/register_view_model/register_cubit.dart';
import '../view_model/register_view_model/register_event.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with UiEventHandler {
  late final StreamSubscription _uiEventSubscription;

  @override
  void initState() {
    super.initState();
    _uiEventSubscription = context.read<RegisterCubit>().eventStream.listen(
      handleUiEvent,
    );
  }

  @override
  void dispose() {
    _uiEventSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundImage: AppImages.authBackground,
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            context.read<RegisterCubit>().doEvent(NextStepEvent());
          },
          child: Text(AppStrings.register.tr()),
        ),
      ),
    );
  }
}
