import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:injectable/injectable.dart';

/// A wrapper service for [FirebaseCrashlytics] to facilitate testing and
/// abstraction.
abstract class CrashlyticsService {
  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    dynamic reason,
    Iterable<Object> information = const [],
    bool? printDetails,
    bool fatal = false,
  });
}

@LazySingleton(as: CrashlyticsService)
class CrashlyticsServiceImpl implements CrashlyticsService {
  @override
  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    dynamic reason,
    Iterable<Object> information = const [],
    bool? printDetails,
    bool fatal = false,
  }) {
    // Firebase Crashlytics has no web SDK/plugin — every call to its native
    // methods throws (e.g. "isCrashlyticsCollectionEnabled" assertion
    // failures) when running on the web. Since every error-recording call in
    // the app goes through this single service, guarding it here protects
    // every caller (auth, chat, etc.) without touching them individually.
    if (kIsWeb) {
      // ignore: avoid_print
      print(
        '[CrashlyticsService] Skipped on web — $exception'
        '${reason != null ? ' (reason: $reason)' : ''}',
      );
      return Future.value();
    }

    return FirebaseCrashlytics.instance.recordError(
      exception,
      stack,
      reason: reason,
      information: information,
      printDetails: printDetails,
      fatal: fatal,
    );
  }
}
