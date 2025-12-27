import 'package:chess_rps/common/logger.dart';
import 'package:chess_rps/data/service/friends/friends_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod/riverpod.dart';

part 'friends_controller.g.dart';

@riverpod
FriendsService friendsService(Ref ref) {
  return FriendsService();
}

@riverpod
class FriendsController extends _$FriendsController {
  @override
  Future<List<FriendInfo>> build() async {
    AppLogger.info('Initializing friends controller', tag: 'FriendsController');
    final service = ref.read(friendsServiceProvider);
    try {
      return await service.getFriends();
    } catch (e) {
      AppLogger.error('Error loading friends', tag: 'FriendsController', error: e);
      return [];
    }
  }

  Future<void> refreshFriends() async {
    state = const AsyncValue.loading();
    try {
      final service = ref.read(friendsServiceProvider);
      final friends = await service.getFriends();
      state = AsyncValue.data(friends);
      AppLogger.info('Friends refreshed', tag: 'FriendsController');
    } catch (e, stackTrace) {
      AppLogger.error('Error refreshing friends', tag: 'FriendsController', error: e);
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

@riverpod
class FriendRequestsController extends _$FriendRequestsController {
  @override
  Future<List<FriendRequestInfo>> build() async {
    AppLogger.info('Initializing friend requests controller', tag: 'FriendRequestsController');
    final service = ref.read(friendsServiceProvider);
    try {
      return await service.getFriendRequests();
    } catch (e) {
      AppLogger.error('Error loading friend requests', tag: 'FriendRequestsController', error: e);
      return [];
    }
  }

  Future<void> refreshRequests() async {
    state = const AsyncValue.loading();
    try {
      final service = ref.read(friendsServiceProvider);
      final requests = await service.getFriendRequests();
      state = AsyncValue.data(requests);
      AppLogger.info('Friend requests refreshed', tag: 'FriendRequestsController');
    } catch (e, stackTrace) {
      AppLogger.error('Error refreshing friend requests', tag: 'FriendRequestsController', error: e);
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> sendFriendRequest(int userId) async {
    try {
      final service = ref.read(friendsServiceProvider);
      await service.sendFriendRequest(userId);
      // Refresh both friends and requests
      await refreshRequests();
      ref.read(friendsControllerProvider.notifier).refreshFriends();
      AppLogger.info('Friend request sent successfully', tag: 'FriendRequestsController');
    } catch (e) {
      AppLogger.error('Error sending friend request', tag: 'FriendRequestsController', error: e);
      rethrow;
    }
  }

  Future<void> acceptRequest(int requestId) async {
    try {
      final service = ref.read(friendsServiceProvider);
      await service.acceptFriendRequest(requestId);
      // Refresh both friends and requests
      await refreshRequests();
      ref.read(friendsControllerProvider.notifier).refreshFriends();
      AppLogger.info('Friend request accepted successfully', tag: 'FriendRequestsController');
    } catch (e) {
      AppLogger.error('Error accepting friend request', tag: 'FriendRequestsController', error: e);
      rethrow;
    }
  }

  Future<void> declineRequest(int requestId) async {
    try {
      final service = ref.read(friendsServiceProvider);
      await service.declineFriendRequest(requestId);
      await refreshRequests();
      AppLogger.info('Friend request declined successfully', tag: 'FriendRequestsController');
    } catch (e) {
      AppLogger.error('Error declining friend request', tag: 'FriendRequestsController', error: e);
      rethrow;
    }
  }
}

@riverpod
class FriendsSearchController extends _$FriendsSearchController {
  @override
  Future<List<SearchUserResponse>> build() async {
    return [];
  }

  Future<void> searchUsers(String query) async {
    // Backend requires at least 3 characters for search
    if (query.length < 3) {
      state = const AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();
    try {
      final service = ref.read(friendsServiceProvider);
      final results = await service.searchUsers(query);
      state = AsyncValue.data(results);
      AppLogger.info('User search completed: ${results.length} results', tag: 'FriendsSearchController');
    } catch (e, stackTrace) {
      AppLogger.error('Error searching users', tag: 'FriendsSearchController', error: e);
      state = AsyncValue.error(e, stackTrace);
    }
  }

  void clearSearch() {
    state = const AsyncValue.data([]);
  }
}

@riverpod
class UsersListController extends _$UsersListController {
  @override
  Future<List<SearchUserResponse>> build() async {
    AppLogger.info('Initializing users list controller', tag: 'UsersListController');
    final service = ref.read(friendsServiceProvider);
    try {
      return await service.getUsersList(page: 1, limit: 10);
    } catch (e) {
      AppLogger.error('Error loading users list', tag: 'UsersListController', error: e);
      return [];
    }
  }

  Future<void> loadMore() async {
    final currentData = state.valueOrNull ?? [];
    if (currentData.isEmpty) {
      // If no data, refresh instead
      await refresh();
      return;
    }
    
    final currentPage = (currentData.length ~/ 10) + 1;
    
    // Don't show loading state if we already have data (to avoid flickering)
    try {
      final service = ref.read(friendsServiceProvider);
      final newUsers = await service.getUsersList(page: currentPage, limit: 10);
      
      if (newUsers.isEmpty) {
        // No more users to load - keep current data
        AppLogger.info('No more users to load', tag: 'UsersListController');
        return;
      }
      
      // Append new users to existing list
      final updatedList = [...currentData, ...newUsers];
      state = AsyncValue.data(updatedList);
      AppLogger.info('Loaded more users: ${newUsers.length} new, ${updatedList.length} total', tag: 'UsersListController');
    } catch (e) {
      AppLogger.error('Error loading more users', tag: 'UsersListController', error: e);
      // Keep existing data on error - don't change state
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final service = ref.read(friendsServiceProvider);
      final users = await service.getUsersList(page: 1, limit: 10);
      state = AsyncValue.data(users);
      AppLogger.info('Users list refreshed: ${users.length} users', tag: 'UsersListController');
    } catch (e, stackTrace) {
      AppLogger.error('Error refreshing users list', tag: 'UsersListController', error: e);
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

