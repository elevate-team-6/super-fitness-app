import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:super_fitness/core/utils/app_keys.dart';
import 'package:injectable/injectable.dart';

import '../../core/utils/app_end_points.dart';
import '../interceptors/auth_interceptor.dart';
import '../interceptors/logging_interceptor.dart';

@module
abstract class DioModule {
  @lazySingleton
  CacheStore get cacheStore => MemCacheStore();

  @lazySingleton
  Dio dio(
    AuthInterceptor authInterceptor,
    LoggingInterceptor loggingInterceptor,
    CacheStore cacheStore,
  ) {
    final dio = Dio();
    _configureDio(dio, authInterceptor, loggingInterceptor, cacheStore);
    return dio;
  }

  @Named('external')
  @lazySingleton
  Dio externalDio(LoggingInterceptor loggingInterceptor) {
    final dio = Dio();
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);
    dio.interceptors.add(loggingInterceptor);
    return dio;
  }

  void _configureDio(
    Dio dio,
    AuthInterceptor authInterceptor,
    LoggingInterceptor loggingInterceptor,
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
    // 3. LoggingInterceptor - logs requests/responses
    dio.interceptors.addAll([
      authInterceptor,
      DioCacheInterceptor(options: cacheOptions),
      loggingInterceptor,
    ]);

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
