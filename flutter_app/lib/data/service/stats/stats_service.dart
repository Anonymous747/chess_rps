import 'package:chess_rps/common/endpoint.dart';
import 'package:chess_rps/common/logger.dart';
import 'package:chess_rps/data/service/auth/auth_interceptor.dart';
import 'package:chess_rps/data/service/dio_logger_interceptor.dart';
import 'package:dio/dio.dart';

class PerformanceHistoryItem {
  final int id;
  final int rating;
  final String result; // "win", "loss", "draw"
  final DateTime createdAt;

  PerformanceHistoryItem({
    required this.id,
    required this.rating,
    required this.result,
    required this.createdAt,
  });

  factory PerformanceHistoryItem.fromJson(Map<String, dynamic> json) {
    return PerformanceHistoryItem(
      id: json['id'] as int,
      rating: json['rating'] as int,
      result: json['result'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class LevelProgress {
  final int level;
  final String levelName;
  final int totalXp;
  final int currentLevelXp;
  final int xpForNextLevel;
  final double progressPercentage;

  LevelProgress({
    required this.level,
    required this.levelName,
    required this.totalXp,
    required this.currentLevelXp,
    required this.xpForNextLevel,
    required this.progressPercentage,
  });

  factory LevelProgress.fromJson(Map<String, dynamic> json) {
    return LevelProgress(
      level: json['level'] as int,
      levelName: json['level_name'] as String,
      totalXp: json['total_xp'] as int,
      currentLevelXp: json['current_level_xp'] as int,
      xpForNextLevel: json['xp_for_next_level'] as int,
      progressPercentage: (json['progress_percentage'] as num).toDouble(),
    );
  }
}

class UserStats {
  final int id;
  final int userId;
  final int rating;
  final int ratingChange;
  final int totalGames;
  final int wins;
  final int losses;
  final int draws;
  final double winRate;
  final int currentStreak;
  final int bestStreak;
  final int worstStreak;
  final int level;
  final int experience;
  final String? levelName;
  final LevelProgress? levelProgress;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<PerformanceHistoryItem>? performanceHistory;

  UserStats({
    required this.id,
    required this.userId,
    required this.rating,
    required this.ratingChange,
    required this.totalGames,
    required this.wins,
    required this.losses,
    required this.draws,
    required this.winRate,
    required this.currentStreak,
    required this.bestStreak,
    required this.worstStreak,
    required this.level,
    required this.experience,
    this.levelName,
    this.levelProgress,
    required this.createdAt,
    this.updatedAt,
    this.performanceHistory,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      rating: json['rating'] as int,
      ratingChange: json['rating_change'] as int,
      totalGames: json['total_games'] as int,
      wins: json['wins'] as int,
      losses: json['losses'] as int,
      draws: json['draws'] as int,
      winRate: (json['win_rate'] as num).toDouble(),
      currentStreak: json['current_streak'] as int,
      bestStreak: json['best_streak'] as int,
      worstStreak: json['worst_streak'] as int,
      level: json['level'] as int? ?? 0,
      experience: json['experience'] as int? ?? 0,
      levelName: json['level_name'] as String?,
      levelProgress: json['level_progress'] != null
          ? LevelProgress.fromJson(json['level_progress'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      performanceHistory: json['performance_history'] != null
          ? (json['performance_history'] as List)
              .map((item) => PerformanceHistoryItem.fromJson(item as Map<String, dynamic>))
              .toList()
          : null,
    );
  }
}

class StatsUpdateResponse {
  final bool success;
  final String message;
  final int newRating;
  final int ratingChange;
  final int xpGained;
  final bool levelUp;
  final int? newLevel;
  final UserStats newStats;

  StatsUpdateResponse({
    required this.success,
    required this.message,
    required this.newRating,
    required this.ratingChange,
    required this.xpGained,
    required this.levelUp,
    this.newLevel,
    required this.newStats,
  });

  factory StatsUpdateResponse.fromJson(Map<String, dynamic> json) {
    return StatsUpdateResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      newRating: json['new_rating'] as int,
      ratingChange: json['rating_change'] as int,
      xpGained: json['xp_gained'] as int? ?? 0,
      levelUp: json['level_up'] as bool? ?? false,
      newLevel: json['new_level'] as int?,
      newStats: UserStats.fromJson(json['new_stats'] as Map<String, dynamic>),
    );
  }
}

class LeaderboardEntry {
  final int rank;
  final int userId;
  final String username;
  final int rating;
  final int level;
  final String? levelName;
  final int totalGames;
  final int wins;
  final int losses;
  final double winRate;

  LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.username,
    required this.rating,
    required this.level,
    this.levelName,
    required this.totalGames,
    required this.wins,
    required this.losses,
    required this.winRate,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: json['rank'] as int,
      userId: json['user_id'] as int,
      username: json['username'] as String,
      rating: json['rating'] as int,
      level: json['level'] as int,
      levelName: json['level_name'] as String?,
      totalGames: json['total_games'] as int,
      wins: json['wins'] as int,
      losses: json['losses'] as int,
      winRate: (json['win_rate'] as num).toDouble(),
    );
  }
}

class StatsService {
  final Dio _dio;

  StatsService({Dio? dio})
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

  /// Get current user's statistics
  /// [includeHistory] - Whether to include performance history
  /// [historyDays] - Number of days of history to include (default: 30)
  Future<UserStats> getMyStats({
    bool includeHistory = false,
    int historyDays = 30,
  }) async {
    try {
      AppLogger.info(
        'Fetching user stats (includeHistory: $includeHistory, historyDays: $historyDays)',
        tag: 'StatsService',
      );
      final response = await _dio.get(
        '/api/v1/stats/me',
        queryParameters: {
          'include_history': includeHistory,
          'history_days': historyDays,
        },
      );

      if (response.statusCode == 200) {
        return UserStats.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to fetch user stats: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      AppLogger.error(
        'Error fetching user stats: ${e.message}',
        tag: 'StatsService',
        error: e,
      );
      throw Exception(e.response?.data['detail'] ?? 'Failed to fetch user stats');
    } catch (e) {
      AppLogger.error(
        'Unexpected error fetching user stats: $e',
        tag: 'StatsService',
      );
      throw Exception('Unexpected error: $e');
    }
  }

  /// Record a game result
  /// [result] - "win", "loss", or "draw"
  /// [opponentRating] - Optional opponent rating for ELO calculation
  /// [gameMode] - Optional game mode ("classical" or "rps")
  /// [endType] - Optional end type ("checkmate", "stalemate", "timeout", etc.)
  /// [opponentMode] - "ai" or "socket" - determines if rating should be updated (only socket games update rating)
  Future<StatsUpdateResponse> recordGameResult({
    required String result,
    int? opponentRating,
    String? gameMode,
    String? endType,
    String? opponentMode,
  }) async {
    try {
      AppLogger.info(
        'Recording game result: $result (opponentMode: $opponentMode)',
        tag: 'StatsService',
      );
      final response = await _dio.post(
        '/api/v1/stats/game-result',
        data: {
          'result': result,
          if (opponentRating != null) 'opponent_rating': opponentRating,
          if (gameMode != null) 'game_mode': gameMode,
          if (endType != null) 'end_type': endType,
          if (opponentMode != null) 'opponent_mode': opponentMode,
        },
      );

      if (response.statusCode == 200) {
        return StatsUpdateResponse.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to record game result: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      AppLogger.error(
        'Error recording game result: ${e.message}',
        tag: 'StatsService',
        error: e,
      );
      throw Exception(e.response?.data['detail'] ?? 'Failed to record game result');
    } catch (e) {
      AppLogger.error(
        'Unexpected error recording game result: $e',
        tag: 'StatsService',
      );
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get leaderboard (top users by rating)
  /// [limit] - Number of top users to return (default: 10)
  Future<List<LeaderboardEntry>> getLeaderboard({int limit = 10}) async {
    try {
      AppLogger.info(
        'Fetching leaderboard (limit: $limit)',
        tag: 'StatsService',
      );
      final response = await _dio.get(
        '/api/v1/stats/leaderboard',
        queryParameters: {
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data.map((json) => LeaderboardEntry.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Failed to fetch leaderboard: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      AppLogger.error(
        'Error fetching leaderboard: ${e.message}',
        tag: 'StatsService',
        error: e,
      );
      throw Exception(e.response?.data['detail'] ?? 'Failed to fetch leaderboard');
    } catch (e) {
      AppLogger.error(
        'Unexpected error fetching leaderboard: $e',
        tag: 'StatsService',
      );
      throw Exception('Unexpected error: $e');
    }
  }
}

