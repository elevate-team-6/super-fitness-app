import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:super_fitness/core/utils/app_keys.dart';

import '../../core/utils/app_end_points.dart';
import '../interceptors/auth_interceptor.dart';

@module
abstract class DioModule {
  @lazySingleton
  CacheStore get cacheStore => MemCacheStore();

  @lazySingleton
  Dio dio(AuthInterceptor authInterceptor, CacheStore cacheStore) {
    final dio = Dio();
    _configureDio(dio, authInterceptor, cacheStore);
    return dio;
  }

  @Named('external')
  @lazySingleton
  Dio externalDio() {
    final dio = Dio();
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);
    if (kDebugMode) {
      dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
          maxWidth: 90,
        ),
      );
    }
    return dio;
  }

  void _configureDio(
    Dio dio,
    AuthInterceptor authInterceptor,
    CacheStore cacheStore,
  ) {
    dio.options.baseUrl = AppEndPoints.baseUrl;
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);
    dio.options.sendTimeout = const Duration(seconds: 30);

    dio.options.headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
    };

    final cacheOptions = CacheOptions(
      store: cacheStore,
      policy: CachePolicy.noCache,
      priority: CachePriority.normal,
      maxStale: const Duration(days: 7),
    );

    // Add interceptors in correct order:
    // 1. AuthInterceptor - adds authorization headers
    // 2. DioCacheInterceptor - handles caching
    // 3. PrettyDioLogger - logs requests/responses (in debug mode)
    dio.interceptors.addAll([
      authInterceptor,
      DioCacheInterceptor(options: cacheOptions),
    ]);

    if (kDebugMode) {
      dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
          maxWidth: 90,
        ),
      );
    }

    // Add cache duration logic
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final cacheHours = options.extra[AppKeys.cacheDurationHours];

          if (options.method == 'GET' && cacheHours != null) {
            options.extra.addAll(
              cacheOptions
                  .copyWith(
                    policy: CachePolicy.forceCache,
                    maxStale: Duration(hours: cacheHours),
                  )
                  .toExtra(),
            );
          }

          handler.next(options);
        },
      ),
    );
  }
}
