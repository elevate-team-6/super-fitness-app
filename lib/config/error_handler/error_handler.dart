import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../core/utils/app_strings.dart';
import '../base_response/base_response.dart';

class ErrorHandler {
  static Future<BaseResponse<T>> handleApiCall<T>(
    Future<T> Function() call,
  ) async {
    try {
      final result = await call();
      return SuccessBaseResponse(result);
    } catch (e) {
      return ErrorBaseResponse(_handle(e));
    }
  }

  static String _handle(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return AppStrings.connectionTimeout.tr();
        case DioExceptionType.sendTimeout:
          return AppStrings.sendTimeout.tr();
        case DioExceptionType.receiveTimeout:
          return AppStrings.receiveTimeout.tr();
        case DioExceptionType.badResponse:
          return _handleBadResponse(error.response);
        case DioExceptionType.cancel:
          return AppStrings.requestCancelled.tr();
        case DioExceptionType.connectionError:
          return AppStrings.noInternetConnection.tr();
        case DioExceptionType.unknown:
          return AppStrings.unexpectedError.tr();
        default:
          return AppStrings.defaultErrorTryAgain.tr();
      }
    } else {
      return AppStrings.unknownError.tr();
    }
  }

  static String _handleBadResponse(Response? response) {
    if (response == null) {
      return AppStrings.unexpectedErrorTryAgain.tr();
    }

    final serverMessage = _extractMessage(response.data);

    if (serverMessage != null) {
      return _mapErrorMessage(serverMessage);
    }

    switch (response.statusCode) {
      case 400:
        return AppStrings.invalidRequest.tr();
      case 401:
        return AppStrings.authFailed.tr();
      case 403:
        return AppStrings.forbidden.tr();
      case 404:
        return AppStrings.notFound.tr();
      case 500:
        return AppStrings.serverError.tr();
      default:
        return AppStrings.defaultError.tr();
    }
  }

  /// Pulls a human-readable message out of an error body.
  ///
  /// Our own API answers with a flat `{"message": "..."}`, but third parties
  /// don't: Google nests it as `{"error": {"code": 404, "message": "..."}}`.
  /// Both shapes are handled, and anything else falls through to null so the
  /// status code decides — a body we can't read must never be shown to a user
  /// or, worse, assigned to a String and thrown as a type error.
  static String? _extractMessage(dynamic data) {
    if (data is! Map) return null;

    final message = data['message'];
    if (message is String && message.isNotEmpty) return message;

    final error = data['error'];
    if (error is String && error.isNotEmpty) return error;
    if (error is Map) {
      final nested = error['message'];
      if (nested is String && nested.isNotEmpty) return nested;
    }

    return null;
  }

  static String _mapErrorMessage(String message) {
    final lowerMessage = message.toLowerCase();

    if (lowerMessage.contains('user already exists')) {
      return AppStrings.userAlreadyExists.tr();
    }
    if (lowerMessage.contains('gender') &&
        lowerMessage.contains('must be one of')) {
      return AppStrings.invalidGender.tr();
    }
    if (lowerMessage.contains('invalid phone number format')) {
      return AppStrings.invalidPhoneFormat.tr();
    }

    return message;
  }
}
