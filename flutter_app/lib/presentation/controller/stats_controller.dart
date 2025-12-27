import 'package:chess_rps/common/logger.dart';
import 'package:chess_rps/data/service/stats/stats_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod/riverpod.dart';

part 'stats_controller.g.dart';

@riverpod
StatsService statsService(Ref ref) {
  return StatsService();
}

@riverpod
class StatsController extends _$StatsController {
  @override
  Future<UserStats> build() async {
    AppLogger.info('Initializing stats controller', tag: 'StatsController');
    final service = ref.read(statsServiceProvider);
    try {
      return await service.getMyStats(includeHistory: true, historyDays: 30);
    } catch (e) {
      AppLogger.error('Error loading user stats', tag: 'StatsController', error: e);
      // Return default stats on error
      return UserStats(
        id: 0,
        userId: 0,
        rating: 1200,
        ratingChange: 0,
        totalGames: 0,
        wins: 0,
        losses: 0,
        draws: 0,
        winRate: 0.0,
        currentStreak: 0,
        bestStreak: 0,
        worstStreak: 0,
        level: 0,
        experience: 0,
        createdAt: DateTime.now(),
        updatedAt: null,
        performanceHistory: null,
      );
    }
  }

  Future<void> refreshStats({bool includeHistory = true, int historyDays = 30}) async {
    state = const AsyncValue.loading();
    try {
      final service = ref.read(statsServiceProvider);
      final stats = await service.getMyStats(includeHistory: includeHistory, historyDays: historyDays);
      state = AsyncValue.data(stats);
      AppLogger.info('Stats refreshed', tag: 'StatsController');
    } catch (e, stackTrace) {
      AppLogger.error('Error refreshing stats', tag: 'StatsController', error: e);
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> recordGameResult({
    required String result,
    int? opponentRating,
    String? gameMode,
    String? endType,
  }) async {
    try {
      final service = ref.read(statsServiceProvider);
      await service.recordGameResult(
        result: result,
        opponentRating: opponentRating,
        gameMode: gameMode,
        endType: endType,
      );
      // Refresh stats after recording result
      await refreshStats();
      AppLogger.info('Game result recorded successfully', tag: 'StatsController');
    } catch (e) {
      AppLogger.error('Error recording game result', tag: 'StatsController', error: e);
      rethrow;
    }
  }
}

@riverpod
Future<List<LeaderboardEntry>> leaderboard(Ref ref, int limit) async {
  AppLogger.info('Fetching leaderboard (limit: $limit)', tag: 'LeaderboardController');
  final service = ref.read(statsServiceProvider);
  try {
    return await service.getLeaderboard(limit: limit);
  } catch (e) {
    AppLogger.error('Error loading leaderboard', tag: 'LeaderboardController', error: e);
    return [];
  }
}

