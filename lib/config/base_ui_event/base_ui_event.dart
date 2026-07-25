sealed class BaseUiEvent {}

class ShowLoadingEvent extends BaseUiEvent {}

class HideLoadingEvent extends BaseUiEvent {}

enum NavigationType { push, pushReplacement, pushAndRemoveUntil, pop }

class DisplayErrorEvent extends BaseUiEvent {
  final String errorMessage;
  DisplayErrorEvent(this.errorMessage);
}

/// Asks the screen to write [text] into its associated text field
/// (e.g. restoring a remembered value when the screen opens).
class FillTextFieldEvent extends BaseUiEvent {
  final String text;
  FillTextFieldEvent(this.text);
}

class DisplaySuccessEvent extends BaseUiEvent {
  final String successMessage;
  DisplaySuccessEvent(this.successMessage);
}

class ShowConfirmationDialogEvent extends BaseUiEvent {}

/// Asks the screen to open [url] in an external app (browser / YouTube / …)
/// rather than an in-app route — the actual launch lives in the UI layer so
/// the cubit stays free of platform plugins.
class OpenUrlEvent extends BaseUiEvent {
  final String url;
  OpenUrlEvent(this.url);
}

class NavigateEvent extends BaseUiEvent {
  final String routeName;
  final NavigationType navigationType;
  final Object? arguments;
  final bool Function(dynamic)? predicate;

  NavigateEvent(
    this.routeName, {
    this.navigationType = NavigationType.push,
    this.arguments,
    this.predicate,
  });
}
