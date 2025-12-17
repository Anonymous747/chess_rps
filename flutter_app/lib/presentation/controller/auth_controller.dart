import 'package:chess_rps/common/logger.dart';
import 'package:chess_rps/data/service/auth/auth_service.dart';
import 'package:chess_rps/data/service/auth/auth_storage.dart';
import 'package:chess_rps/domain/model/auth_user.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod/riverpod.dart';

part 'auth_controller.g.dart';

@riverpod
AuthService authService(AuthServiceRef ref) {
  return AuthService();
}

@riverpod
class AuthController extends _$AuthController {
  AuthService? _authService;
  AuthStorage? _authStorage;

  @override
  Future<AuthUser?> build() async {
    try {
      _authService = ref.read(authServiceProvider);
      _authStorage = AuthStorage();
      
      // Try to load saved user
      final savedUser = await _authStorage!.getAuthUser();
      if (savedUser != null) {
        // Validate token with timeout protection
        try {
          final isValid = await _authService!.validateToken(savedUser.accessToken)
              .timeout(
                const Duration(seconds: 6),
                onTimeout: () {
                  AppLogger.warning('Token validation timed out', tag: 'AuthController');
                  return false;
                },
              );
          
          if (isValid) {
            AppLogger.info('Loaded valid auth user from storage', tag: 'AuthController');
            return savedUser;
          } else {
            AppLogger.info('Saved token is invalid, clearing storage', tag: 'AuthController');
            await _authStorage!.clearAuthUser();
          }
        } catch (e) {
          AppLogger.error('Error validating token, clearing storage', tag: 'AuthController', error: e);
          await _authStorage!.clearAuthUser();
        }
      }
      
      return null;
    } catch (e) {
      AppLogger.error('Error in AuthController build', tag: 'AuthController', error: e);
      // Return null on any error to prevent infinite loading
      return null;
    }
  }
  
  // Helper to get current AsyncValue state
  AsyncValue<AuthUser?> get asyncState => state;

  Future<void> register({
    required String phoneNumber,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      final user = await _authService!.register(
        phoneNumber: phoneNumber,
        password: password,
      );
      
      await _authStorage!.saveAuthUser(user);
      state = AsyncValue.data(user);
      AppLogger.info('Registration successful', tag: 'AuthController');
    } catch (e, stackTrace) {
      AppLogger.error('Registration failed', tag: 'AuthController', error: e);
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  Future<void> login({
    required String phoneNumber,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      final user = await _authService!.login(
        phoneNumber: phoneNumber,
        password: password,
      );
      
      await _authStorage!.saveAuthUser(user);
      state = AsyncValue.data(user);
      AppLogger.info('Login successful', tag: 'AuthController');
    } catch (e, stackTrace) {
      AppLogger.error('Login failed', tag: 'AuthController', error: e);
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  Future<void> logout() async {
    final currentUser = state.valueOrNull;
    if (currentUser != null) {
      try {
        await _authService!.logout(currentUser.accessToken);
      } catch (e) {
        AppLogger.error('Logout API call failed', tag: 'AuthController', error: e);
        // Continue with local logout even if API call fails
      }
    }
    
    await _authStorage!.clearAuthUser();
    state = const AsyncValue.data(null);
    AppLogger.info('Logout successful', tag: 'AuthController');
  }

  bool get isAuthenticated => state.valueOrNull?.isAuthenticated ?? false;
  
  AuthUser? get currentUser => state.valueOrNull;
  
  String? get token => state.valueOrNull?.accessToken;
}

