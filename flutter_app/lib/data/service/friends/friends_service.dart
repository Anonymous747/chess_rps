import 'package:chess_rps/common/endpoint.dart';
import 'package:chess_rps/common/logger.dart';
import 'package:chess_rps/data/service/auth/auth_interceptor.dart';
import 'package:chess_rps/data/service/dio_logger_interceptor.dart';
import 'package:dio/dio.dart';

class FriendInfo {
  final int id;
  final int userId;
  final String phoneNumber;
  final int? rating;
  final bool isOnline;
  final int friendshipId;
  final String status;
  final DateTime createdAt;
  final DateTime? acceptedAt;

  FriendInfo({
    required this.id,
    required this.userId,
    required this.phoneNumber,
    this.rating,
    required this.isOnline,
    required this.friendshipId,
    required this.status,
    required this.createdAt,
    this.acceptedAt,
  });

  factory FriendInfo.fromJson(Map<String, dynamic> json) {
    return FriendInfo(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      phoneNumber: json['phone_number'] as String,
      rating: json['rating'] as int?,
      isOnline: json['is_online'] as bool? ?? false,
      friendshipId: json['friendship_id'] as int,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      acceptedAt: json['accepted_at'] != null
          ? DateTime.parse(json['accepted_at'] as String)
          : null,
    );
  }
}

class FriendRequestInfo {
  final int id;
  final int requesterId;
  final int addresseeId;
  final String requesterPhone;
  final String addresseePhone;
  final String status;
  final DateTime createdAt;

  FriendRequestInfo({
    required this.id,
    required this.requesterId,
    required this.addresseeId,
    required this.requesterPhone,
    required this.addresseePhone,
    required this.status,
    required this.createdAt,
  });

  factory FriendRequestInfo.fromJson(Map<String, dynamic> json) {
    return FriendRequestInfo(
      id: json['id'] as int,
      requesterId: json['requester_id'] as int,
      addresseeId: json['addressee_id'] as int,
      requesterPhone: json['requester_phone'] as String,
      addresseePhone: json['addressee_phone'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class SearchUserResponse {
  final int id;
  final String phoneNumber;
  final int? rating;
  final bool isFriend;
  final String? friendshipStatus;
  final int? friendshipId;

  SearchUserResponse({
    required this.id,
    required this.phoneNumber,
    this.rating,
    required this.isFriend,
    this.friendshipStatus,
    this.friendshipId,
  });

  factory SearchUserResponse.fromJson(Map<String, dynamic> json) {
    return SearchUserResponse(
      id: json['id'] as int,
      phoneNumber: json['phone_number'] as String,
      rating: json['rating'] as int?,
      isFriend: json['is_friend'] as bool? ?? false,
      friendshipStatus: json['friendship_status'] as String?,
      friendshipId: json['friendship_id'] as int?,
    );
  }
}

class FriendsService {
  final Dio _dio;

  FriendsService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: Endpoint.apiBase,
                connectTimeout: const Duration(seconds: 30),
                receiveTimeout: const Duration(seconds: 30),
              ),
            )..interceptors.addAll([
                DioLoggerInterceptor(),
                AuthInterceptor(),
              ]);

  /// Get all friends
  Future<List<FriendInfo>> getFriends() async {
    try {
      AppLogger.info('Fetching friends list', tag: 'FriendsService');
      final response = await _dio.get('/api/v1/friends/');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => FriendInfo.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Failed to fetch friends: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      AppLogger.error(
        'Error fetching friends: ${e.message}',
        tag: 'FriendsService',
        error: e,
      );
      throw Exception(e.response?.data['detail'] ?? 'Failed to fetch friends');
    } catch (e) {
      AppLogger.error(
        'Unexpected error fetching friends: $e',
        tag: 'FriendsService',
      );
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get friend requests (pending requests received)
  Future<List<FriendRequestInfo>> getFriendRequests() async {
    try {
      AppLogger.info('Fetching friend requests', tag: 'FriendsService');
      final response = await _dio.get('/api/v1/friends/requests');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data
            .map((json) => FriendRequestInfo.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to fetch friend requests: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      AppLogger.error(
        'Error fetching friend requests: ${e.message}',
        tag: 'FriendsService',
        error: e,
      );
      throw Exception(e.response?.data['detail'] ?? 'Failed to fetch friend requests');
    } catch (e) {
      AppLogger.error(
        'Unexpected error fetching friend requests: $e',
        tag: 'FriendsService',
      );
      throw Exception('Unexpected error: $e');
    }
  }

  /// Send a friend request
  Future<FriendRequestInfo> sendFriendRequest(int userId) async {
    try {
      AppLogger.info('Sending friend request to user $userId', tag: 'FriendsService');
      final response = await _dio.post(
        '/api/v1/friends/requests',
        data: {'addressee_id': userId},
      );

      if (response.statusCode == 201) {
        return FriendRequestInfo.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to send friend request: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      AppLogger.error(
        'Error sending friend request: ${e.message}',
        tag: 'FriendsService',
        error: e,
      );
      throw Exception(e.response?.data['detail'] ?? 'Failed to send friend request');
    } catch (e) {
      AppLogger.error(
        'Unexpected error sending friend request: $e',
        tag: 'FriendsService',
      );
      throw Exception('Unexpected error: $e');
    }
  }

  /// Accept a friend request
  Future<FriendRequestInfo> acceptFriendRequest(int requestId) async {
    try {
      AppLogger.info('Accepting friend request $requestId', tag: 'FriendsService');
      final response = await _dio.post('/api/v1/friends/requests/$requestId/accept');

      if (response.statusCode == 200) {
        return FriendRequestInfo.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to accept friend request: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      AppLogger.error(
        'Error accepting friend request: ${e.message}',
        tag: 'FriendsService',
        error: e,
      );
      throw Exception(e.response?.data['detail'] ?? 'Failed to accept friend request');
    } catch (e) {
      AppLogger.error(
        'Unexpected error accepting friend request: $e',
        tag: 'FriendsService',
      );
      throw Exception('Unexpected error: $e');
    }
  }

  /// Decline a friend request
  Future<FriendRequestInfo> declineFriendRequest(int requestId) async {
    try {
      AppLogger.info('Declining friend request $requestId', tag: 'FriendsService');
      final response = await _dio.post('/api/v1/friends/requests/$requestId/decline');

      if (response.statusCode == 200) {
        return FriendRequestInfo.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to decline friend request: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      AppLogger.error(
        'Error declining friend request: ${e.message}',
        tag: 'FriendsService',
        error: e,
      );
      throw Exception(e.response?.data['detail'] ?? 'Failed to decline friend request');
    } catch (e) {
      AppLogger.error(
        'Unexpected error declining friend request: $e',
        tag: 'FriendsService',
      );
      throw Exception('Unexpected error: $e');
    }
  }

  /// Remove a friend
  Future<void> removeFriend(int friendshipId) async {
    try {
      AppLogger.info('Removing friend $friendshipId', tag: 'FriendsService');
      final response = await _dio.delete('/api/v1/friends/$friendshipId');

      if (response.statusCode != 204) {
        throw Exception('Failed to remove friend: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      AppLogger.error(
        'Error removing friend: ${e.message}',
        tag: 'FriendsService',
        error: e,
      );
      throw Exception(e.response?.data['detail'] ?? 'Failed to remove friend');
    } catch (e) {
      AppLogger.error(
        'Unexpected error removing friend: $e',
        tag: 'FriendsService',
      );
      throw Exception('Unexpected error: $e');
    }
  }

  /// Search for users
  Future<List<SearchUserResponse>> searchUsers(String query) async {
    try {
      AppLogger.info('Searching users: $query', tag: 'FriendsService');
      final response = await _dio.get(
        '/api/v1/friends/search',
        queryParameters: {'query': query},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data
            .map((json) => SearchUserResponse.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to search users: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      AppLogger.error(
        'Error searching users: ${e.message}',
        tag: 'FriendsService',
        error: e,
      );
      throw Exception(e.response?.data['detail'] ?? 'Failed to search users');
    } catch (e) {
      AppLogger.error(
        'Unexpected error searching users: $e',
        tag: 'FriendsService',
      );
      throw Exception('Unexpected error: $e');
    }
  }
}

