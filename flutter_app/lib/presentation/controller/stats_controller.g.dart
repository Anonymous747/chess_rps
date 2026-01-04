// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stats_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$statsServiceHash() => r'stats_service_provider_hash';

/// See also [statsService].
@ProviderFor(statsService)
final statsServiceProvider = Provider<StatsService>.internal(
  statsService,
  name: r'statsServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$statsServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef StatsServiceRef = ProviderRef<StatsService>;

String _$statsControllerHash() => r'stats_controller_provider_hash';

/// See also [StatsController].
@ProviderFor(StatsController)
final statsControllerProvider =
    AutoDisposeAsyncNotifierProvider<StatsController, UserStats>.internal(
  StatsController.new,
  name: r'statsControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$statsControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$StatsController = AutoDisposeAsyncNotifier<UserStats>;

/// See also [leaderboard].
final leaderboardProvider = FutureProvider.autoDispose.family<List<LeaderboardEntry>, int>(
  (ref, limit) => leaderboard(ref, limit),
);

String _$leaderboardControllerHash() => r'leaderboard_controller_provider_hash';

/// See also [LeaderboardController].
@ProviderFor(LeaderboardController)
final leaderboardControllerProvider =
    AutoDisposeAsyncNotifierProvider<LeaderboardController, List<LeaderboardEntry>>.internal(
  LeaderboardController.new,
  name: r'leaderboardControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$leaderboardControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LeaderboardController = AutoDisposeAsyncNotifier<List<LeaderboardEntry>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

