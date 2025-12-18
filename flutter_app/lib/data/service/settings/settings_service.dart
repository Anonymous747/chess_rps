import 'package:chess_rps/common/endpoint.dart';
import 'package:chess_rps/common/logger.dart';
import 'package:chess_rps/data/service/auth/auth_interceptor.dart';
import 'package:dio/dio.dart';

class UserSettings {
  final String boardTheme;
  final String pieceSet;
  final bool autoQueen;
  final bool confirmMoves;
  final double masterVolume;
  final bool pushNotifications;
  final bool onlineStatusVisible;
  final int userId;

  UserSettings({
    required this.boardTheme,
    required this.pieceSet,
    required this.autoQueen,
    required this.confirmMoves,
    required this.masterVolume,
    required this.pushNotifications,
    required this.onlineStatusVisible,
    required this.userId,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      boardTheme: json['board_theme'] as String? ?? 'glass_dark',
      pieceSet: json['piece_set'] as String? ?? 'neon_3d',
      autoQueen: json['auto_queen'] as bool? ?? true,
      confirmMoves: json['confirm_moves'] as bool? ?? false,
      masterVolume: (json['master_volume'] as num?)?.toDouble() ?? 0.8,
      pushNotifications: json['push_notifications'] as bool? ?? true,
      onlineStatusVisible: json['online_status_visible'] as bool? ?? true,
      userId: json['user_id'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'board_theme': boardTheme,
      'piece_set': pieceSet,
      'auto_queen': autoQueen,
      'confirm_moves': confirmMoves,
      'master_volume': masterVolume,
      'push_notifications': pushNotifications,
      'online_status_visible': onlineStatusVisible,
    };
  }

  UserSettings copyWith({
    String? boardTheme,
    String? pieceSet,
    bool? autoQueen,
    bool? confirmMoves,
    double? masterVolume,
    bool? pushNotifications,
    bool? onlineStatusVisible,
  }) {
    return UserSettings(
      boardTheme: boardTheme ?? this.boardTheme,
      pieceSet: pieceSet ?? this.pieceSet,
      autoQueen: autoQueen ?? this.autoQueen,
      confirmMoves: confirmMoves ?? this.confirmMoves,
      masterVolume: masterVolume ?? this.masterVolume,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      onlineStatusVisible: onlineStatusVisible ?? this.onlineStatusVisible,
      userId: userId,
    );
  }
}

class SettingsService {
  final Dio _dio;

  SettingsService() : _dio = Dio() {
    _dio.options.baseUrl = Endpoint.apiBase;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.interceptors.add(AuthInterceptor());
  }

  Future<UserSettings> getSettings() async {
    try {
      AppLogger.info('Fetching user settings', tag: 'SettingsService');
      final response = await _dio.get('/api/v1/auth/settings');
      
      if (response.statusCode == 200) {
        AppLogger.info('Settings fetched successfully', tag: 'SettingsService');
        return UserSettings.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch settings: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('Error fetching settings', tag: 'SettingsService', error: e);
      rethrow;
    }
  }

  Future<UserSettings> updateSettings({
    String? boardTheme,
    String? pieceSet,
    bool? autoQueen,
    bool? confirmMoves,
    double? masterVolume,
    bool? pushNotifications,
    bool? onlineStatusVisible,
  }) async {
    try {
      AppLogger.info('Updating user settings', tag: 'SettingsService');
      
      final Map<String, dynamic> updateData = {};
      if (boardTheme != null) updateData['board_theme'] = boardTheme;
      if (pieceSet != null) updateData['piece_set'] = pieceSet;
      if (autoQueen != null) updateData['auto_queen'] = autoQueen;
      if (confirmMoves != null) updateData['confirm_moves'] = confirmMoves;
      if (masterVolume != null) updateData['master_volume'] = masterVolume;
      if (pushNotifications != null) updateData['push_notifications'] = pushNotifications;
      if (onlineStatusVisible != null) updateData['online_status_visible'] = onlineStatusVisible;

      final response = await _dio.put(
        '/api/v1/auth/settings',
        data: updateData,
      );

      if (response.statusCode == 200) {
        AppLogger.info('Settings updated successfully', tag: 'SettingsService');
        return UserSettings.fromJson(response.data);
      } else {
        throw Exception('Failed to update settings: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('Error updating settings', tag: 'SettingsService', error: e);
      rethrow;
    }
  }
}

