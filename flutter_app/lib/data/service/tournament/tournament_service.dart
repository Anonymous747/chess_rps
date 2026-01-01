import 'package:chess_rps/common/endpoint.dart';
import 'package:chess_rps/common/logger.dart';
import 'package:chess_rps/data/service/auth/auth_interceptor.dart';
import 'package:chess_rps/data/service/dio_logger_interceptor.dart';
import 'package:dio/dio.dart';

// Tournament Models
class TournamentModel {
  final int id;
  final String name;
  final String? description;
  final String gameMode; // "classical" or "rps"
  final String format; // "single_elimination", "double_elimination", "swiss", "round_robin"
  final String status; // "registration", "started", "finished", "cancelled"
  final int maxParticipants;
  final int minParticipants;
  final int? creatorId;
  final DateTime registrationStart;
  final DateTime registrationEnd;
  final DateTime? tournamentStart;
  final DateTime? tournamentEnd;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int? participantCount;

  TournamentModel({
    required this.id,
    required this.name,
    this.description,
    required this.gameMode,
    required this.format,
    required this.status,
    required this.maxParticipants,
    required this.minParticipants,
    this.creatorId,
    required this.registrationStart,
    required this.registrationEnd,
    this.tournamentStart,
    this.tournamentEnd,
    required this.createdAt,
    this.updatedAt,
    this.participantCount,
  });

  factory TournamentModel.fromJson(Map<String, dynamic> json) {
    return TournamentModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      gameMode: json['game_mode'] as String,
      format: json['format'] as String,
      status: json['status'] as String,
      maxParticipants: json['max_participants'] as int,
      minParticipants: json['min_participants'] as int,
      creatorId: json['creator_id'] as int?,
      registrationStart: DateTime.parse(json['registration_start'] as String),
      registrationEnd: DateTime.parse(json['registration_end'] as String),
      tournamentStart: json['tournament_start'] != null
          ? DateTime.parse(json['tournament_start'] as String)
          : null,
      tournamentEnd: json['tournament_end'] != null
          ? DateTime.parse(json['tournament_end'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      participantCount: json['participant_count'] as int?,
    );
  }
}

class TournamentParticipantModel {
  final int id;
  final int tournamentId;
  final int userId;
  final String? username;
  final int tournamentRating;
  final int? finalPlace;
  final int wins;
  final int losses;
  final int draws;
  final DateTime registeredAt;

  TournamentParticipantModel({
    required this.id,
    required this.tournamentId,
    required this.userId,
    this.username,
    required this.tournamentRating,
    this.finalPlace,
    required this.wins,
    required this.losses,
    required this.draws,
    required this.registeredAt,
  });

  factory TournamentParticipantModel.fromJson(Map<String, dynamic> json) {
    return TournamentParticipantModel(
      id: json['id'] as int,
      tournamentId: json['tournament_id'] as int,
      userId: json['user_id'] as int,
      username: json['username'] as String?,
      tournamentRating: json['tournament_rating'] as int,
      finalPlace: json['final_place'] as int?,
      wins: json['wins'] as int,
      losses: json['losses'] as int,
      draws: json['draws'] as int,
      registeredAt: DateTime.parse(json['registered_at'] as String),
    );
  }
}

class TournamentRatingModel {
  final int id;
  final int userId;
  final String? username;
  final String gameMode;
  final int rating;
  final int ratingChange;
  final int tournamentsPlayed;
  final int tournamentsWon;
  final int? bestPlacement;
  final int totalMatches;
  final int matchWins;
  final int matchLosses;
  final int matchDraws;
  final DateTime createdAt;
  final DateTime? updatedAt;

  TournamentRatingModel({
    required this.id,
    required this.userId,
    this.username,
    required this.gameMode,
    required this.rating,
    required this.ratingChange,
    required this.tournamentsPlayed,
    required this.tournamentsWon,
    this.bestPlacement,
    required this.totalMatches,
    required this.matchWins,
    required this.matchLosses,
    required this.matchDraws,
    required this.createdAt,
    this.updatedAt,
  });

  factory TournamentRatingModel.fromJson(Map<String, dynamic> json) {
    return TournamentRatingModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      username: json['username'] as String?,
      gameMode: json['game_mode'] as String,
      rating: json['rating'] as int,
      ratingChange: json['rating_change'] as int,
      tournamentsPlayed: json['tournaments_played'] as int,
      tournamentsWon: json['tournaments_won'] as int,
      bestPlacement: json['best_placement'] as int?,
      totalMatches: json['total_matches'] as int,
      matchWins: json['match_wins'] as int,
      matchLosses: json['match_losses'] as int,
      matchDraws: json['match_draws'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }
}

class TournamentLeaderboardEntry {
  final int rank;
  final int userId;
  final String username;
  final int rating;
  final int tournamentsPlayed;
  final int tournamentsWon;
  final int? bestPlacement;
  final int totalMatches;
  final int matchWins;
  final int matchLosses;
  final int matchDraws;
  final double winRate;

  TournamentLeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.username,
    required this.rating,
    required this.tournamentsPlayed,
    required this.tournamentsWon,
    this.bestPlacement,
    required this.totalMatches,
    required this.matchWins,
    required this.matchLosses,
    required this.matchDraws,
    required this.winRate,
  });

  factory TournamentLeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return TournamentLeaderboardEntry(
      rank: json['rank'] as int,
      userId: json['user_id'] as int,
      username: json['username'] as String,
      rating: json['rating'] as int,
      tournamentsPlayed: json['tournaments_played'] as int,
      tournamentsWon: json['tournaments_won'] as int,
      bestPlacement: json['best_placement'] as int?,
      totalMatches: json['total_matches'] as int,
      matchWins: json['match_wins'] as int,
      matchLosses: json['match_losses'] as int,
      matchDraws: json['match_draws'] as int,
      winRate: (json['win_rate'] as num).toDouble(),
    );
  }
}

class TournamentService {
  final Dio _dio;

  TournamentService({Dio? dio})
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

  /// Create a new tournament
  Future<TournamentModel> createTournament({
    required String name,
    String? description,
    required String gameMode, // "classical" or "rps"
    required String format, // "single_elimination", "double_elimination", "swiss", "round_robin"
    required int maxParticipants,
    int minParticipants = 2,
    required DateTime registrationStart,
    required DateTime registrationEnd,
    DateTime? tournamentStart,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/tournaments',
        data: {
          'name': name,
          'description': description,
          'game_mode': gameMode,
          'format': format,
          'max_participants': maxParticipants,
          'min_participants': minParticipants,
          'registration_start': registrationStart.toIso8601String(),
          'registration_end': registrationEnd.toIso8601String(),
          if (tournamentStart != null)
            'tournament_start': tournamentStart.toIso8601String(),
        },
      );

      return TournamentModel.fromJson(response.data);
    } catch (e) {
      AppLogger.error('Failed to create tournament: $e', tag: 'TournamentService', error: e);
      rethrow;
    }
  }

  /// List tournaments with optional filters
  Future<List<TournamentModel>> listTournaments({
    String? gameMode,
    String? statusFilter,
    int skip = 0,
    int limit = 50,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'skip': skip,
        'limit': limit,
      };
      if (gameMode != null) queryParams['game_mode'] = gameMode;
      if (statusFilter != null) queryParams['status_filter'] = statusFilter;

      final response = await _dio.get(
        '/api/v1/tournaments',
        queryParameters: queryParams,
      );

      final List<dynamic> data = response.data;
      return data.map((json) => TournamentModel.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('Failed to list tournaments: $e', tag: 'TournamentService', error: e);
      rethrow;
    }
  }

  /// Get tournament details
  Future<TournamentModel> getTournament(int tournamentId) async {
    try {
      final response = await _dio.get(
        '/api/v1/tournaments/$tournamentId',
      );

      return TournamentModel.fromJson(response.data);
    } catch (e) {
      AppLogger.error('Failed to get tournament: $e', tag: 'TournamentService', error: e);
      rethrow;
    }
  }

  /// Join a tournament
  Future<TournamentParticipantModel> joinTournament(int tournamentId) async {
    try {
      final response = await _dio.post(
        '/api/v1/tournaments/$tournamentId/join',
      );

      return TournamentParticipantModel.fromJson(response.data);
    } catch (e) {
      AppLogger.error('Failed to join tournament: $e', tag: 'TournamentService', error: e);
      rethrow;
    }
  }

  /// Get tournament participants
  Future<List<TournamentParticipantModel>> getTournamentParticipants(int tournamentId) async {
    try {
      final response = await _dio.get(
        '/api/v1/tournaments/$tournamentId/participants',
      );

      final List<dynamic> data = response.data;
      return data.map((json) => TournamentParticipantModel.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('Failed to get tournament participants: $e', tag: 'TournamentService', error: e);
      rethrow;
    }
  }

  /// Get tournament leaderboard for a game mode
  Future<List<TournamentLeaderboardEntry>> getTournamentLeaderboard({
    required String gameMode,
    int limit = 100,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/tournaments/ratings/$gameMode',
        queryParameters: {'limit': limit},
      );

      final List<dynamic> data = response.data;
      return data.map((json) => TournamentLeaderboardEntry.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('Failed to get tournament leaderboard: $e', tag: 'TournamentService', error: e);
      rethrow;
    }
  }

  /// Get current user's tournament rating for a game mode
  Future<TournamentRatingModel> getMyTournamentRating(String gameMode) async {
    try {
      final response = await _dio.get(
        '/api/v1/tournaments/ratings/me/$gameMode',
      );

      return TournamentRatingModel.fromJson(response.data);
    } catch (e) {
      AppLogger.error('Failed to get tournament rating: $e', tag: 'TournamentService', error: e);
      rethrow;
    }
  }
}

