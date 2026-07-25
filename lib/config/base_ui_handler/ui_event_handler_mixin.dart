import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
      case OpenUrlEvent():
        _openUrl(event.url);
    }
  }

  /// Opens an external link, preferring the dedicated app (YouTube, etc.) and
  /// falling back to the platform default when nothing claims it.
  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      await launchUrl(uri);
    }
  }

  /// Override in screens that own a text field to be filled by the cubit.
  void onFillTextField(String text) {}

  /// Override in screens that need to show a confirmation dialog.
  void onShowConfirmationDialog() {}
}
