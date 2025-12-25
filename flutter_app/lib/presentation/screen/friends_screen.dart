import 'package:chess_rps/common/logger.dart';
import 'package:chess_rps/common/palette.dart';
import 'package:chess_rps/data/service/friends/friends_service.dart';
import 'package:chess_rps/presentation/controller/friends_controller.dart';
import 'package:chess_rps/presentation/widget/user_avatar_widget.dart';
import 'package:chess_rps/presentation/widget/skeleton_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class FriendsScreen extends HookConsumerWidget {
  static const routeName = '/friends';

  const FriendsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendsAsync = ref.watch(friendsControllerProvider);
    final requestsAsync = ref.watch(friendRequestsControllerProvider);
    final searchAsync = ref.watch(friendsSearchControllerProvider);
    final searchController = ref.read(friendsSearchControllerProvider.notifier);
    final friendsController = ref.read(friendsControllerProvider.notifier);
    final requestsController = ref.read(friendRequestsControllerProvider.notifier);
    
    final searchTextController = useTextEditingController();
    final showSearchResults = useState(false);
    final selectedFilterState = useState(0); // 0: Online, 1: In Game, 2: Offline

    // Handle search
    void onSearchChanged(String value) {
      if (value.length >= 3) {
        showSearchResults.value = true;
        searchController.searchUsers(value);
      } else {
        showSearchResults.value = false;
        searchController.clearSearch();
      }
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Palette.background,
              Palette.backgroundSecondary,
              Palette.backgroundTertiary,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: Icon(Icons.arrow_back, color: Palette.textSecondary),
                      style: IconButton.styleFrom(
                        backgroundColor: Palette.backgroundTertiary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Palette.glassBorder),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Friends',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Palette.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        _showAddFriendDialog(context, ref, searchController);
                      },
                      icon: Icon(Icons.person_add, color: Palette.purpleAccent),
                      style: IconButton.styleFrom(
                        backgroundColor: Palette.purpleAccent.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Palette.purpleAccent.withOpacity(0.2)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Palette.backgroundTertiary,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Palette.glassBorder),
                  ),
                  child: TextField(
                    controller: searchTextController,
                    style: TextStyle(color: Palette.textPrimary),
                    onChanged: onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search by phone number or ID...',
                      hintStyle: TextStyle(color: Palette.textSecondary),
                      prefixIcon: Icon(Icons.search, color: Palette.textSecondary),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Show search results if searching
              if (showSearchResults.value)
                Expanded(
                  child: _buildSearchResults(context, ref, searchAsync, requestsController),
                )
              else
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // Friend Requests Section
                        _buildFriendRequestsSection(context, ref, requestsAsync, requestsController),
                        
                        const SizedBox(height: 24),
                        
                        // Friends List
                        _buildFriendsList(context, ref, friendsAsync, friendsController, selectedFilterState),
                        
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFriendRequestsSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<FriendRequestInfo>> requestsAsync,
    FriendRequestsController requestsController,
  ) {
    return requestsAsync.when(
      data: (requests) {
        if (requests.isEmpty) {
          return const SizedBox.shrink();
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'REQUESTS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Palette.textSecondary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Palette.error,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Palette.error.withOpacity(0.4),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Text(
                    '${requests.length} Pending',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Palette.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...requests.map((request) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildRequestItem(context, ref, request, requestsController),
            )),
          ],
        );
      },
      loading: () => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: List.generate(
            3,
            (index) => Padding(
              padding: EdgeInsets.only(bottom: index < 2 ? 12 : 0),
              child: const SkeletonListItem(),
            ),
          ),
        ),
      ),
      error: (error, stack) => Container(
        padding: const EdgeInsets.all(20),
        child: Text(
          'Error loading requests',
          style: TextStyle(color: Palette.error, fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildRequestItem(
    BuildContext context,
    WidgetRef ref,
    FriendRequestInfo request,
    FriendRequestsController requestsController,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Palette.backgroundTertiary.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Palette.glassBorder),
        boxShadow: [
          BoxShadow(
            color: Palette.black.withOpacity(0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
                    UserAvatarByIconWidget(
                      size: 48,
                      border: Border.all(color: Palette.glassBorder, width: 2),
                    ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.requesterPhone,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Palette.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sent you a request • ${_formatTimeAgo(request.createdAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Palette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () async {
              try {
                await requestsController.acceptRequest(request.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Friend request accepted'),
                      backgroundColor: Palette.success,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to accept request: $e'),
                      backgroundColor: Palette.error,
                    ),
                  );
                }
              }
            },
            icon: Icon(Icons.check, color: Palette.success),
            style: IconButton.styleFrom(
              backgroundColor: Palette.success.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Palette.success.withOpacity(0.2)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () async {
              try {
                await requestsController.declineRequest(request.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Friend request declined'),
                      backgroundColor: Palette.textSecondary,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to decline request: $e'),
                      backgroundColor: Palette.error,
                    ),
                  );
                }
              }
            },
            icon: Icon(Icons.close, color: Palette.error),
            style: IconButton.styleFrom(
              backgroundColor: Palette.error.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Palette.error.withOpacity(0.2)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendsList(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<FriendInfo>> friendsAsync,
    FriendsController friendsController,
    ValueNotifier<int> selectedFilterState,
  ) {
    return friendsAsync.when(
      data: (friends) {
        if (friends.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Palette.textTertiary),
                  const SizedBox(height: 16),
                  Text(
                    'No friends yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: Palette.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add friends to challenge them to games',
                    style: TextStyle(
                      fontSize: 12,
                      color: Palette.textTertiary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        // Filter friends (for now, just show all - online status not implemented yet)
        final filteredFriends = friends;
        final onlineFriends = filteredFriends.where((f) => f.isOnline).toList();
        final offlineFriends = filteredFriends.where((f) => !f.isOnline).toList();

        final selectedFilter = selectedFilterState.value;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Buttons
            Row(
              children: [
                _buildFilterButton('Online', onlineFriends.length, 0, selectedFilter, (v) {
                  selectedFilterState.value = v;
                }),
                const SizedBox(width: 12),
                _buildFilterButton('In Game', 0, 1, selectedFilter, (v) {
                  selectedFilterState.value = v;
                }),
                const SizedBox(width: 12),
                _buildFilterButton('Offline', offlineFriends.length, 2, selectedFilter, (v) {
                  selectedFilterState.value = v;
                }),
              ],
            ),
            const SizedBox(height: 20),
            
            // Online Friends
            if (onlineFriends.isNotEmpty) ...[
              Text(
                'ONLINE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Palette.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              ...onlineFriends.map((friend) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildFriendItem(context, ref, friend, friendsController),
              )),
              const SizedBox(height: 20),
            ],
            
            // Offline Friends
            if (offlineFriends.isNotEmpty) ...[
              Text(
                'OFFLINE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Palette.textTertiary,
                ),
              ),
              const SizedBox(height: 12),
              ...offlineFriends.map((friend) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildFriendItem(context, ref, friend, friendsController),
              )),
            ],
          ],
        );
      },
      loading: () => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: List.generate(
            3,
            (index) => Padding(
              padding: EdgeInsets.only(bottom: index < 2 ? 12 : 0),
              child: const SkeletonListItem(),
            ),
          ),
        ),
      ),
      error: (error, stack) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Error loading friends',
              style: TextStyle(color: Palette.error, fontSize: 12),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => friendsController.refreshFriends(),
              child: Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendItem(
    BuildContext context,
    WidgetRef ref,
    FriendInfo friend,
    FriendsController friendsController,
  ) {
    final isOffline = !friend.isOnline;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Palette.backgroundTertiary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Palette.glassBorder),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              // Use default avatar for friends (backend doesn't return avatar info yet)
              UserAvatarByIconWidget(
                size: 56,
                border: Border.all(color: Palette.glassBorder, width: 2),
              ),
              if (friend.isOnline)
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Palette.onlineGreen,
                      shape: BoxShape.circle,
                      border: Border.all(color: Palette.backgroundTertiary, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Palette.onlineGreen.withOpacity(0.8),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      friend.phoneNumber,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isOffline ? Palette.textTertiary : Palette.textPrimary,
                      ),
                    ),
                    if (friend.rating != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Palette.purpleAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Palette.purpleAccent.withOpacity(0.2)),
                        ),
                        child: Text(
                          '${friend.rating}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Palette.purpleAccent,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (friend.isOnline)
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Palette.onlineGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                    if (friend.isOnline) const SizedBox(width: 4),
                    Text(
                      friend.isOnline ? 'Online' : 'Offline',
                      style: TextStyle(
                        fontSize: 12,
                        color: isOffline
                            ? Palette.textTertiary
                            : (friend.isOnline ? Palette.success : Palette.textSecondary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {
                  // TODO: Open chat
                  AppLogger.info('Chat with ${friend.phoneNumber}', tag: 'FriendsScreen');
                },
                icon: Icon(Icons.chat_bubble_outline, color: Palette.textSecondary),
                style: IconButton.styleFrom(
                  backgroundColor: Palette.backgroundSecondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  // TODO: Challenge to game
                  AppLogger.info('Challenge ${friend.phoneNumber}', tag: 'FriendsScreen');
                },
                icon: Icon(Icons.sports_martial_arts, color: Palette.purpleAccent),
                style: IconButton.styleFrom(
                  backgroundColor: Palette.purpleAccent.withOpacity(0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Palette.purpleAccent.withOpacity(0.2)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label, int count, int index, int selectedFilter, Function(int) onTap) {
    final isActive = selectedFilter == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: isActive
                ? LinearGradient(
                    colors: [Palette.purpleAccent, Palette.purpleAccentDark],
                  )
                : null,
            color: isActive ? null : Palette.backgroundTertiary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? Colors.transparent : Palette.glassBorder,
            ),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isActive ? Palette.textPrimary : Palette.textSecondary,
                  ),
                ),
                if (count > 0) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.white.withOpacity(0.2)
                          : Palette.backgroundSecondary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 10,
                        color: isActive ? Palette.textPrimary : Palette.textSecondary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<SearchUserResponse>> searchAsync,
    FriendRequestsController requestsController,
  ) {
    return searchAsync.when(
      data: (results) {
        if (results.isEmpty) {
          return Center(
            child: Text(
              'No users found',
              style: TextStyle(color: Palette.textSecondary, fontSize: 14),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final user = results[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Palette.backgroundTertiary,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Palette.glassBorder),
                ),
                child: Row(
                  children: [
                    UserAvatarByIconWidget(
                      size: 48,
                      border: Border.all(color: Palette.glassBorder, width: 2),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                user.phoneNumber,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Palette.textPrimary,
                                ),
                              ),
                              if (user.rating != null) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Palette.purpleAccent.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: Palette.purpleAccent.withOpacity(0.2)),
                                  ),
                                  child: Text(
                                    '${user.rating}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Palette.purpleAccent,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.isFriend
                                ? 'Already friends'
                                : (user.friendshipStatus == 'pending'
                                    ? 'Request pending'
                                    : 'Not friends'),
                            style: TextStyle(
                              fontSize: 12,
                              color: Palette.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!user.isFriend && user.friendshipStatus != 'pending')
                      IconButton(
                        onPressed: () async {
                          try {
                            await requestsController.sendFriendRequest(user.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Friend request sent'),
                                  backgroundColor: Palette.success,
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to send request: $e'),
                                  backgroundColor: Palette.error,
                                ),
                              );
                            }
                          }
                        },
                        icon: Icon(Icons.person_add, color: Palette.purpleAccent),
                        style: IconButton.styleFrom(
                          backgroundColor: Palette.purpleAccent.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Palette.purpleAccent.withOpacity(0.2)),
                          ),
                        ),
                      )
                    else if (user.isFriend)
                      Icon(Icons.check_circle, color: Palette.success, size: 24)
                    else
                      Icon(Icons.hourglass_empty, color: Palette.warning, size: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: List.generate(
            3,
            (index) => Padding(
              padding: EdgeInsets.only(bottom: index < 2 ? 12 : 0),
              child: const SkeletonListItem(),
            ),
          ),
        ),
      ),
      error: (error, stack) => Center(
        child: Text(
          'Error searching users',
          style: TextStyle(color: Palette.error, fontSize: 14),
        ),
      ),
    );
  }

  void _showAddFriendDialog(
    BuildContext context,
    WidgetRef ref,
    FriendsSearchController searchController,
  ) {
    final searchTextController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Palette.backgroundTertiary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Palette.glassBorder, width: 1),
          ),
          title: Text(
            'Add Friend',
            style: TextStyle(
              color: Palette.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: searchTextController,
                style: TextStyle(color: Palette.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Enter phone number or user ID',
                  hintStyle: TextStyle(color: Palette.textSecondary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Palette.glassBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Palette.glassBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Palette.purpleAccent),
                  ),
                ),
                onChanged: (value) {
                  if (value.length >= 3) {
                    searchController.searchUsers(value);
                  } else {
                    searchController.clearSearch();
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Palette.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

