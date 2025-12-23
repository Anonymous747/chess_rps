import 'package:chess_rps/common/logger.dart';
import 'package:chess_rps/data/service/auth/auth_service.dart';
import 'package:chess_rps/data/service/auth/auth_storage.dart';
import 'package:chess_rps/domain/model/auth_user.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod/riverpod.dart';

part 'auth_controller.g.dart';

@riverpod
AuthService authService(Ref ref) {
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
        // Validate access token with timeout protection
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
            // Access token is invalid, try to refresh using refresh token
            AppLogger.info('Access token invalid, attempting to refresh', tag: 'AuthController');
            try {
              final refreshedUser = await _authService!.refreshToken(savedUser.refreshToken)
                  .timeout(
                    const Duration(seconds: 6),
                    onTimeout: () {
                      AppLogger.warning('Token refresh timed out', tag: 'AuthController');
                      throw Exception('Token refresh timed out');
                    },
                  );
              
              // Save refreshed tokens
              await _authStorage!.saveAuthUser(refreshedUser);
              AppLogger.info('Token refreshed successfully', tag: 'AuthController');
              return refreshedUser;
            } catch (refreshError) {
              AppLogger.warning('Token refresh failed, clearing storage', tag: 'AuthController', error: refreshError);
              await _authStorage!.clearAuthUser();
            }
          }
        } catch (e) {
          // If validation throws an error, try to refresh token
          AppLogger.warning('Token validation error, attempting refresh', tag: 'AuthController', error: e);
          try {
            final refreshedUser = await _authService!.refreshToken(savedUser.refreshToken)
                .timeout(
                  const Duration(seconds: 6),
                  onTimeout: () {
                    AppLogger.warning('Token refresh timed out', tag: 'AuthController');
                    throw Exception('Token refresh timed out');
                  },
                );
            
            // Save refreshed tokens
            await _authStorage!.saveAuthUser(refreshedUser);
            AppLogger.info('Token refreshed successfully after validation error', tag: 'AuthController');
            return refreshedUser;
          } catch (refreshError) {
            AppLogger.error('Token refresh failed, clearing storage', tag: 'AuthController', error: refreshError);
            await _authStorage!.clearAuthUser();
          }
        }
      }
      
      // No saved user found - return null so user can log in
      AppLogger.info('No saved user found', tag: 'AuthController');
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

  Future<void> updateProfileName(String profileName) async {
    final currentUser = state.valueOrNull;
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    try {
      final updatedName = await _authService!.updateProfileName(profileName);
      final updatedUser = currentUser.copyWith(profileName: updatedName);
      await _authStorage!.saveAuthUser(updatedUser);
      state = AsyncValue.data(updatedUser);
      AppLogger.info('Profile name updated successfully', tag: 'AuthController');
    } catch (e, stackTrace) {
      AppLogger.error('Profile name update failed', tag: 'AuthController', error: e);
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }
}

