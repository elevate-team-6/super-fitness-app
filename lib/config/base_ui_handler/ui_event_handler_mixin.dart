import 'package:flutter/material.dart';

import '../../core/widgets/custom_loading.dart';
import '../../core/widgets/custom_snack_bar.dart';
import '../base_ui_event/base_ui_event.dart';

mixin UiEventHandler<T extends StatefulWidget> on State<T> {
  void handleUiEvent(BaseUiEvent event) {
    switch (event) {
      case DisplaySuccessEvent():
        CustomSnackBar.showSuccessMessage(event.successMessage);
      case DisplayErrorEvent():
        CustomSnackBar.showErrorMessage(event.errorMessage);
      case NavigateEvent():
        switch (event.navigationType) {
          case NavigationType.push:
            Navigator.pushNamed(
              context,
              event.routeName,
              arguments: event.arguments,
            );
          case NavigationType.pushReplacement:
            Navigator.pushReplacementNamed(
              context,
              event.routeName,
              arguments: event.arguments,
            );
          case NavigationType.pushAndRemoveUntil:
            Navigator.pushNamedAndRemoveUntil(
              context,
              event.routeName,
              event.predicate ?? (route) => false,
              arguments: event.arguments,
            );
          case NavigationType.pop:
            Navigator.pop(context, event.arguments);
        }
      case ShowLoadingEvent():
        LoadingDialog.show(context: context);
      case HideLoadingEvent():
        LoadingDialog.hide(context: context);
      case FillTextFieldEvent():
        onFillTextField(event.text);
      case ShowConfirmationDialogEvent():
        onShowConfirmationDialog();
    }
  }

  /// Override in screens that own a text field to be filled by the cubit.
  void onFillTextField(String text) {}

  /// Override in screens that need to show a confirmation dialog.
  void onShowConfirmationDialog() {}
}
