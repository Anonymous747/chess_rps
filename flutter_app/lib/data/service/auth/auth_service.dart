import 'package:chess_rps/common/endpoint.dart';
import 'package:chess_rps/common/logger.dart';
import 'package:chess_rps/data/service/auth/auth_interceptor.dart';
import 'package:chess_rps/domain/model/auth_user.dart';
import 'package:dio/dio.dart';

class AuthService {
  final Dio _dio;

  AuthService({Dio? dio}) 
      : _dio = dio ?? Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 5),
            receiveTimeout: const Duration(seconds: 5),
            sendTimeout: const Duration(seconds: 5),
          ),
        )..interceptors.add(AuthInterceptor());

  Future<AuthUser> register({
    required String phoneNumber,
    required String password,
  }) async {
    try {
      AppLogger.info('Registering user: $phoneNumber', tag: 'AuthService');
      
      final response = await _dio.post(
        '${Endpoint.apiBase}/api/v1/auth/register',
        data: {
          'phone_number': phoneNumber,
          'password': password,
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 201) {
        final data = response.data;
        AppLogger.info('Registration successful', tag: 'AuthService');
        return AuthUser(
          userId: data['user_id'],
          phoneNumber: data['phone_number'],
          accessToken: data['access_token'],
        );
      } else {
        throw Exception('Registration failed: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      AppLogger.error('Registration error: ${e.message}', tag: 'AuthService', error: e);
      if (e.response != null) {
        final errorMessage = e.response?.data['detail'] ?? 'Registration failed';
        throw Exception(errorMessage);
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      AppLogger.error('Unexpected error during registration', tag: 'AuthService', error: e);
      throw Exception('Unexpected error: $e');
    }
  }

  Future<AuthUser> login({
    required String phoneNumber,
    required String password,
  }) async {
    try {
      AppLogger.info('Logging in user: $phoneNumber', tag: 'AuthService');
      
      final response = await _dio.post(
        '${Endpoint.apiBase}/api/v1/auth/login',
        data: {
          'phone_number': phoneNumber,
          'password': password,
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        AppLogger.info('Login successful', tag: 'AuthService');
        return AuthUser(
          userId: data['user_id'],
          phoneNumber: data['phone_number'],
          accessToken: data['access_token'],
        );
      } else {
        throw Exception('Login failed: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      AppLogger.error('Login error: ${e.message}', tag: 'AuthService', error: e);
      if (e.response != null) {
        final errorMessage = e.response?.data['detail'] ?? 'Login failed';
        throw Exception(errorMessage);
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      AppLogger.error('Unexpected error during login', tag: 'AuthService', error: e);
      throw Exception('Unexpected error: $e');
    }
  }

  Future<void> logout(String token) async {
    try {
      AppLogger.info('Logging out user', tag: 'AuthService');
      
      await _dio.post(
        '${Endpoint.apiBase}/api/v1/auth/logout',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      AppLogger.info('Logout successful', tag: 'AuthService');
    } on DioException catch (e) {
      AppLogger.error('Logout error: ${e.message}', tag: 'AuthService', error: e);
      // Don't throw on logout errors - we'll clear local storage anyway
    } catch (e) {
      AppLogger.error('Unexpected error during logout', tag: 'AuthService', error: e);
      // Don't throw on logout errors
    }
  }

  Future<bool> validateToken(String token) async {
    try {
      // Create a separate Dio instance without interceptor to avoid circular token addition
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
          sendTimeout: const Duration(seconds: 5),
        ),
      );
      
      final response = await dio.get(
        '${Endpoint.apiBase}/api/v1/auth/validate-token',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return response.statusCode == 200 && response.data['valid'] == true;
    } on DioException catch (e) {
      AppLogger.error('Token validation error: ${e.message}', tag: 'AuthService', error: e);
      // If it's a timeout or connection error, treat as invalid
      if (e.type == DioExceptionType.connectionTimeout || 
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.connectionError) {
        AppLogger.warning('Token validation timeout or connection error', tag: 'AuthService');
      }
      return false;
    } catch (e) {
      AppLogger.error('Unexpected token validation error', tag: 'AuthService', error: e);
      return false;
    }
  }
}

