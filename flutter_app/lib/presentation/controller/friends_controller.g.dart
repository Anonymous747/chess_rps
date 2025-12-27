// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friends_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$friendsServiceHash() => r'friends_service_provider_hash';

/// See also [friendsService].
@ProviderFor(friendsService)
final friendsServiceProvider = Provider<FriendsService>.internal(
  friendsService,
  name: r'friendsServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$friendsServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FriendsServiceRef = ProviderRef<FriendsService>;

String _$friendsControllerHash() => r'friends_controller_provider_hash';

/// See also [FriendsController].
@ProviderFor(FriendsController)
final friendsControllerProvider =
    AutoDisposeAsyncNotifierProvider<FriendsController, List<FriendInfo>>.internal(
  FriendsController.new,
  name: r'friendsControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$friendsControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$FriendsController = AutoDisposeAsyncNotifier<List<FriendInfo>>;

String _$friendRequestsControllerHash() => r'friend_requests_controller_provider_hash';

/// See also [FriendRequestsController].
@ProviderFor(FriendRequestsController)
final friendRequestsControllerProvider =
    AutoDisposeAsyncNotifierProvider<FriendRequestsController, List<FriendRequestInfo>>.internal(
  FriendRequestsController.new,
  name: r'friendRequestsControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$friendRequestsControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$FriendRequestsController = AutoDisposeAsyncNotifier<List<FriendRequestInfo>>;

String _$friendsSearchControllerHash() => r'friends_search_controller_provider_hash';

/// See also [FriendsSearchController].
@ProviderFor(FriendsSearchController)
final friendsSearchControllerProvider =
    AutoDisposeAsyncNotifierProvider<FriendsSearchController, List<SearchUserResponse>>.internal(
  FriendsSearchController.new,
  name: r'friendsSearchControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$friendsSearchControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$FriendsSearchController = AutoDisposeAsyncNotifier<List<SearchUserResponse>>;

String _$usersListControllerHash() => r'users_list_controller_provider_hash';

/// See also [UsersListController].
@ProviderFor(UsersListController)
final usersListControllerProvider =
    AutoDisposeAsyncNotifierProvider<UsersListController, List<SearchUserResponse>>.internal(
  UsersListController.new,
  name: r'usersListControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$usersListControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$UsersListController = AutoDisposeAsyncNotifier<List<SearchUserResponse>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

