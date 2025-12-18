import 'package:pretty_dio_logger/pretty_dio_logger.dart';

/// Pretty Dio logger interceptor for network request/response logging
class DioLoggerInterceptor extends PrettyDioLogger {
  DioLoggerInterceptor()
      : super(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
          maxWidth: 90,
          logPrint: _logPrint,
        );

  static void _logPrint(Object object) {
    // Use print for now, but you could integrate with your AppLogger if needed
    print(object);
  }
}

