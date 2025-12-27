import 'package:chess_rps/common/logger.dart';
import 'package:chess_rps/data/service/settings/settings_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod/riverpod.dart';

part 'settings_controller.g.dart';

@riverpod
SettingsService settingsService(Ref ref) {
  return SettingsService();
}

@riverpod
class SettingsController extends _$SettingsController {
  @override
  Future<UserSettings> build() async {
    AppLogger.info('Initializing settings controller', tag: 'SettingsController');
    final service = ref.read(settingsServiceProvider);
    try {
      return await service.getSettings();
    } catch (e) {
      AppLogger.error('Error loading settings', tag: 'SettingsController', error: e);
      // Return default settings if fetch fails
      return UserSettings(
        boardTheme: 'glass_dark',
        pieceSet: 'cardinal',
        effect: 'classic',
        autoQueen: true,
        confirmMoves: false,
        masterVolume: 0.8,
        pushNotifications: true,
        onlineStatusVisible: true,
        userId: 0,
      );
    }
  }

  Future<void> updateBoardTheme(String theme) async {
    AppLogger.info('Updating board theme to $theme', tag: 'SettingsController');
    final currentSettings = state.valueOrNull;
    if (currentSettings == null) return;

    // Optimistically update UI
    state = AsyncValue.data(currentSettings.copyWith(boardTheme: theme));

    try {
      final service = ref.read(settingsServiceProvider);
      final updated = await service.updateSettings(boardTheme: theme);
      state = AsyncValue.data(updated);
      AppLogger.info('Board theme updated successfully', tag: 'SettingsController');
    } catch (e) {
      AppLogger.error('Error updating board theme', tag: 'SettingsController', error: e);
      // Revert on error
      state = AsyncValue.data(currentSettings);
    }
  }

  Future<void> updatePieceSet(String pieceSet) async {
    AppLogger.info('Updating piece set to $pieceSet', tag: 'SettingsController');
    final currentSettings = state.valueOrNull;
    if (currentSettings == null) return;

    // Optimistically update UI
    state = AsyncValue.data(currentSettings.copyWith(pieceSet: pieceSet));

    try {
      final service = ref.read(settingsServiceProvider);
      final updated = await service.updateSettings(pieceSet: pieceSet);
      state = AsyncValue.data(updated);
      AppLogger.info('Piece set updated successfully', tag: 'SettingsController');
    } catch (e) {
      AppLogger.error('Error updating piece set', tag: 'SettingsController', error: e);
      // Revert on error
      state = AsyncValue.data(currentSettings);
    }
  }

  Future<void> updateAutoQueen(bool value) async {
    AppLogger.info('Updating auto-queen to $value', tag: 'SettingsController');
    final currentSettings = state.valueOrNull;
    if (currentSettings == null) return;

    // Optimistically update UI
    state = AsyncValue.data(currentSettings.copyWith(autoQueen: value));

    try {
      final service = ref.read(settingsServiceProvider);
      final updated = await service.updateSettings(autoQueen: value);
      state = AsyncValue.data(updated);
      AppLogger.info('Auto-queen updated successfully', tag: 'SettingsController');
    } catch (e) {
      AppLogger.error('Error updating auto-queen', tag: 'SettingsController', error: e);
      // Revert on error
      state = AsyncValue.data(currentSettings);
    }
  }

  Future<void> updateConfirmMoves(bool value) async {
    AppLogger.info('Updating confirm moves to $value', tag: 'SettingsController');
    final currentSettings = state.valueOrNull;
    if (currentSettings == null) return;

    // Optimistically update UI
    state = AsyncValue.data(currentSettings.copyWith(confirmMoves: value));

    try {
      final service = ref.read(settingsServiceProvider);
      final updated = await service.updateSettings(confirmMoves: value);
      state = AsyncValue.data(updated);
      AppLogger.info('Confirm moves updated successfully', tag: 'SettingsController');
    } catch (e) {
      AppLogger.error('Error updating confirm moves', tag: 'SettingsController', error: e);
      // Revert on error
      state = AsyncValue.data(currentSettings);
    }
  }

  Future<void> updateMasterVolume(double volume) async {
    AppLogger.info('Updating master volume to $volume', tag: 'SettingsController');
    final currentSettings = state.valueOrNull;
    if (currentSettings == null) return;

    // Optimistically update UI
    state = AsyncValue.data(currentSettings.copyWith(masterVolume: volume));

    try {
      final service = ref.read(settingsServiceProvider);
      final updated = await service.updateSettings(masterVolume: volume);
      state = AsyncValue.data(updated);
      AppLogger.info('Master volume updated successfully', tag: 'SettingsController');
    } catch (e) {
      AppLogger.error('Error updating master volume', tag: 'SettingsController', error: e);
      state = AsyncValue.error(e, StackTrace.current);
      state = AsyncValue.data(currentSettings);
    }
  }

  Future<void> updatePushNotifications(bool value) async {
    AppLogger.info('Updating push notifications to $value', tag: 'SettingsController');
    final currentSettings = state.valueOrNull;
    if (currentSettings == null) return;

    // Optimistically update UI
    state = AsyncValue.data(currentSettings.copyWith(pushNotifications: value));

    try {
      final service = ref.read(settingsServiceProvider);
      final updated = await service.updateSettings(pushNotifications: value);
      state = AsyncValue.data(updated);
      AppLogger.info('Push notifications updated successfully', tag: 'SettingsController');
    } catch (e) {
      AppLogger.error('Error updating push notifications', tag: 'SettingsController', error: e);
      // Revert on error
      state = AsyncValue.data(currentSettings);
    }
  }

  Future<void> updateOnlineStatusVisible(bool value) async {
    AppLogger.info('Updating online status visible to $value', tag: 'SettingsController');
    final currentSettings = state.valueOrNull;
    if (currentSettings == null) return;

    // Optimistically update UI
    state = AsyncValue.data(currentSettings.copyWith(onlineStatusVisible: value));

    try {
      final service = ref.read(settingsServiceProvider);
      final updated = await service.updateSettings(onlineStatusVisible: value);
      state = AsyncValue.data(updated);
      AppLogger.info('Online status visible updated successfully', tag: 'SettingsController');
    } catch (e) {
      AppLogger.error('Error updating online status visible', tag: 'SettingsController', error: e);
      // Revert on error
      state = AsyncValue.data(currentSettings);
    }
  }

  Future<void> updateEffect(String effect) async {
    AppLogger.info('Updating effect to $effect', tag: 'SettingsController');
    final currentSettings = state.valueOrNull;
    if (currentSettings == null) return;

    // Optimistically update UI
    state = AsyncValue.data(currentSettings.copyWith(effect: effect));

    try {
      final service = ref.read(settingsServiceProvider);
      final updated = await service.updateSettings(effect: effect);
      // If backend doesn't return effect field, preserve our optimistic update
      final finalSettings = updated.effect != null 
          ? updated 
          : updated.copyWith(effect: effect);
      state = AsyncValue.data(finalSettings);
      AppLogger.info('Effect updated successfully', tag: 'SettingsController');
    } catch (e) {
      AppLogger.error('Error updating effect', tag: 'SettingsController', error: e);
      // Revert on error
      state = AsyncValue.data(currentSettings);
    }
  }
}

