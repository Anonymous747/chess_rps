import 'package:chess_rps/common/logger.dart';
import 'package:chess_rps/data/service/auth/auth_storage.dart';
import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Get token from storage
    final storage = AuthStorage();
    final token = await storage.getToken();
    
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
      AppLogger.debug('Added auth token to request: ${options.path}', tag: 'AuthInterceptor');
    }
    
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      AppLogger.warning('Unauthorized request, token may be invalid', tag: 'AuthInterceptor');
      // Token might be invalid, but we'll let the app handle it
    }
    handler.next(err);
  }
}

