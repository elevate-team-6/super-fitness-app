import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:injectable/injectable.dart';

import '../../../../config/base_response/base_response.dart';
import '../../../../config/services/crashlytics_service.dart';
import '../../../../core/utils/app_strings.dart';
import '../../data/data_sources/chat_remote_data_source_contract.dart';
import '../../data/models/chat_event_model.dart';
import '../api_client/chat_api_client.dart';

/// Implementation of [ChatRemoteDataSourceContract] using [ChatApiClient].
@LazySingleton(as: ChatRemoteDataSourceContract)
class ChatRemoteDataSourceImpl implements ChatRemoteDataSourceContract {
  final ChatApiClient _apiClient;
  final CrashlyticsService _crashlyticsService;

  ChatRemoteDataSourceImpl(this._apiClient, this._crashlyticsService);

  @override
  Stream<BaseResponse<ChatEventModel>> getChatResponseStream({
    required String message,
    required String token,
    Map<String, dynamic>? userContext,
  }) async* {
    try {
      final response = await _apiClient.getChatResponse(
        message: message,
        token: token,
        userContext: userContext,
      );

      if (response.statusCode != 200) {
        String errorMessage;
        switch (response.statusCode) {
          case 401:
            errorMessage = AppStrings.authFailed.tr();
          case 500:
          case 502:
          case 503:
            errorMessage = AppStrings.serverError.tr();
          default:
            errorMessage =
                "${AppStrings.chatUnexpectedError.tr()} (${response.statusCode})";
        }
        yield ErrorBaseResponse(errorMessage);
        return;
      }

      bool hasReceivedData = false;

      // Transform the byte stream into a line-by-line event stream
      await for (final line
          in response.stream
              .transform(utf8.decoder)
              .transform(const LineSplitter())) {
        if (line.startsWith("data: ")) {
          final data = line.substring(6).trim();
          if (data.isEmpty) continue;

          try {
            final json = jsonDecode(data);
            hasReceivedData = true;
            yield SuccessBaseResponse(ChatEventModel.fromJson(json));
          } catch (e, stack) {
            await _crashlyticsService.recordError(
              e,
              stack,
              reason: "SSE Parse Error",
            );
            yield ErrorBaseResponse(AppStrings.chatUnexpectedError.tr());
          }
        }
      }

      if (!hasReceivedData) {
        yield ErrorBaseResponse(AppStrings.coachIsBusy.tr());
      }
    } catch (e, stack) {
      await _crashlyticsService.recordError(
        e,
        stack,
        reason: "Chat Stream Failure",
      );
      yield ErrorBaseResponse(AppStrings.chatConnectionError.tr());
    }
  }
}
