import 'package:chess_rps/common/logger.dart';
import 'package:chess_rps/domain/model/auth_user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static const _tokenKey = 'auth_token';
  static const _userIdKey = 'auth_user_id';
  static const _phoneNumberKey = 'auth_phone_number';

  Future<void> saveAuthUser(AuthUser user) async {
    try {
      AppLogger.info('Saving auth user', tag: 'AuthStorage');
      await Future.wait([
        _storage.write(key: _tokenKey, value: user.accessToken),
        _storage.write(key: _userIdKey, value: user.userId.toString()),
        _storage.write(key: _phoneNumberKey, value: user.phoneNumber),
      ]);
      AppLogger.info('Auth user saved successfully', tag: 'AuthStorage');
    } catch (e) {
      AppLogger.error('Error saving auth user', tag: 'AuthStorage', error: e);
      rethrow;
    }
  }

  Future<AuthUser?> getAuthUser() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      final userIdStr = await _storage.read(key: _userIdKey);
      final phoneNumber = await _storage.read(key: _phoneNumberKey);

      if (token == null || userIdStr == null || phoneNumber == null) {
        return null;
      }

      return AuthUser(
        userId: int.parse(userIdStr),
        phoneNumber: phoneNumber,
        accessToken: token,
      );
    } catch (e) {
      AppLogger.error('Error reading auth user', tag: 'AuthStorage', error: e);
      return null;
    }
  }

  Future<void> clearAuthUser() async {
    try {
      AppLogger.info('Clearing auth user', tag: 'AuthStorage');
      await Future.wait([
        _storage.delete(key: _tokenKey),
        _storage.delete(key: _userIdKey),
        _storage.delete(key: _phoneNumberKey),
      ]);
      AppLogger.info('Auth user cleared', tag: 'AuthStorage');
    } catch (e) {
      AppLogger.error('Error clearing auth user', tag: 'AuthStorage', error: e);
    }
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }
}

