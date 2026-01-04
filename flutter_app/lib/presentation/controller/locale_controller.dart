import 'package:chess_rps/common/logger.dart';
import 'package:chess_rps/data/service/auth/auth_storage.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'locale_controller.g.dart';

const String _localeKey = 'app_locale';
const Locale _defaultLocale = Locale('en');

@riverpod
class LocaleNotifier extends _$LocaleNotifier {
  final AuthStorage _storage = AuthStorage();

  @override
  Future<Locale> build() async {
    AppLogger.info('Initializing locale controller', tag: 'LocaleController');
    try {
      final localeString = await _storage.getString(_localeKey);
      if (localeString != null) {
        final locale = Locale(localeString);
        AppLogger.info('Loaded locale: $locale', tag: 'LocaleController');
        return locale;
      }
      AppLogger.info('No saved locale found, using default: $_defaultLocale', tag: 'LocaleController');
      return _defaultLocale;
    } catch (e) {
      AppLogger.error('Error loading locale', tag: 'LocaleController', error: e);
      return _defaultLocale;
    }
  }

  Future<void> setLocale(Locale locale) async {
    AppLogger.info('Setting locale to $locale', tag: 'LocaleController');
    final currentLocale = state.valueOrNull ?? _defaultLocale;
    
    // Optimistically update UI
    state = AsyncValue.data(locale);

    try {
      await _storage.setString(_localeKey, locale.languageCode);
      AppLogger.info('Locale saved successfully', tag: 'LocaleController');
      state = AsyncValue.data(locale);
    } catch (e) {
      AppLogger.error('Error saving locale', tag: 'LocaleController', error: e);
      // Revert on error
      state = AsyncValue.data(currentLocale);
    }
  }
}
