// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$collectionServiceHash() => r'c1d2e3f4g5h6i7j8k9l0m1n2o3p4q5r6';

/// See also [collectionService].
@ProviderFor(collectionService)
final collectionServiceProvider = AutoDisposeProvider<CollectionService>.internal(
  collectionService,
  name: r'collectionServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$collectionServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CollectionServiceRef = AutoDisposeProviderRef<CollectionService>;

String _$collectionControllerHash() => r'd2e3f4g5h6i7j8k9l0m1n2o3p4q5r6s7';

/// See also [CollectionController].
@ProviderFor(CollectionController)
final collectionControllerProvider =
    AutoDisposeAsyncNotifierProvider<CollectionController, List<CollectionItem>>.internal(
  CollectionController.new,
  name: r'collectionControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$collectionControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CollectionController = AutoDisposeAsyncNotifier<List<CollectionItem>>;

String _$userCollectionControllerHash() => r'e3f4g5h6i7j8k9l0m1n2o3p4q5r6s7t8';

/// See also [UserCollectionController].
@ProviderFor(UserCollectionController)
final userCollectionControllerProvider =
    AutoDisposeAsyncNotifierProvider<UserCollectionController, List<UserCollectionItem>>.internal(
  UserCollectionController.new,
  name: r'userCollectionControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userCollectionControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$UserCollectionController = AutoDisposeAsyncNotifier<List<UserCollectionItem>>;

String _$collectionStatsControllerHash() => r'f4g5h6i7j8k9l0m1n2o3p4q5r6s7t8u9';

/// See also [CollectionStatsController].
@ProviderFor(CollectionStatsController)
final collectionStatsControllerProvider =
    AutoDisposeAsyncNotifierProvider<CollectionStatsController, CollectionStats>.internal(
  CollectionStatsController.new,
  name: r'collectionStatsControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$collectionStatsControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CollectionStatsController = AutoDisposeAsyncNotifier<CollectionStats>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

