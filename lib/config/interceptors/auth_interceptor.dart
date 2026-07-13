import 'package:dio/dio.dart';
import 'package:super_fitness/config/cache/secure_cache_helper.dart';
import 'package:super_fitness/core/utils/app_end_points.dart';
import 'package:super_fitness/core/utils/app_keys.dart';
import 'package:injectable/injectable.dart';

@injectable
class AuthInterceptor extends Interceptor {
  final SecureCacheHelper cache;

  AuthInterceptor(this.cache);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Only add authorization header for our own API requests
    if (options.path.startsWith(AppEndPoints.baseUrl)) {
      final token = await cache.readData(key: AppKeys.tokenKey);

      if (token != null) {
        options.headers[AppKeys.authorizationKey] =
            '${AppKeys.bearerPrefix} $token';
      }
    }

    handler.next(options);
  }
}
