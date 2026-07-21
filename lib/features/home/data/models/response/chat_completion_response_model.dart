import 'package:super_fitness/core/utils/app_params.dart';

/// The OpenAI-format chat-completion envelope Groq answers with. The useful
/// payload sits at `choices[0].message.content` as a *string* — a JSON schema
/// only constrains what that string contains, so it still has to be decoded
/// separately by the caller.
class ChatCompletionResponseModel {
  /// Empty when the model returned nothing usable — a content filter, or a
  /// response cut off before any token was emitted.
  final String? content;

  const ChatCompletionResponseModel({this.content});

  factory ChatCompletionResponseModel.fromJson(Map<String, dynamic> json) {
    final choices = json[ApiParameters.choices] as List<dynamic>?;
    if (choices == null || choices.isEmpty) {
      return const ChatCompletionResponseModel();
    }

    // Only the first choice is read: we never ask for more than one.
    final message =
        (choices.first as Map<String, dynamic>)[ApiParameters.message]
            as Map<String, dynamic>?;

    final content = message?[ApiParameters.content] as String?;
    return ChatCompletionResponseModel(
      content: (content == null || content.isEmpty) ? null : content,
    );
  }
}
