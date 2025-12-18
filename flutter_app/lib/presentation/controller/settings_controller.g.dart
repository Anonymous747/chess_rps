// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$settingsServiceHash() => r'a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7';

/// See also [settingsService].
@ProviderFor(settingsService)
final settingsServiceProvider = AutoDisposeProvider<SettingsService>.internal(
  settingsService,
  name: r'settingsServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$settingsServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SettingsServiceRef = AutoDisposeProviderRef<SettingsService>;

String _$settingsControllerHash() => r'b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8';

/// See also [SettingsController].
@ProviderFor(SettingsController)
final settingsControllerProvider =
    AutoDisposeAsyncNotifierProvider<SettingsController, UserSettings>.internal(
  SettingsController.new,
  name: r'settingsControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$settingsControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SettingsController = AutoDisposeAsyncNotifier<UserSettings>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

