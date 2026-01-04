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

  Future<StatsUpdateResponse> recordGameResult({
    required String result,
    int? opponentRating,
    String? gameMode,
    String? endType,
    String? opponentMode, // "ai" or "socket"
  }) async {
    try {
      final service = ref.read(statsServiceProvider);
      final response = await service.recordGameResult(
        result: result,
        opponentRating: opponentRating,
        gameMode: gameMode,
        endType: endType,
        opponentMode: opponentMode,
      );
      // Refresh stats after recording result
      await refreshStats();
      AppLogger.info('Game result recorded successfully', tag: 'StatsController');
      return response;
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
    return await service.getLeaderboard(limit: limit, page: 1);
  } catch (e) {
    AppLogger.error('Error loading leaderboard', tag: 'LeaderboardController', error: e);
    return [];
  }
}

@riverpod
class LeaderboardController extends _$LeaderboardController {
  @override
  Future<List<LeaderboardEntry>> build() async {
    AppLogger.info('Initializing leaderboard controller', tag: 'LeaderboardController');
    final service = ref.read(statsServiceProvider);
    try {
      return await service.getLeaderboard(page: 1, limit: 20);
    } catch (e) {
      AppLogger.error('Error loading leaderboard', tag: 'LeaderboardController', error: e);
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
    
    final currentPage = (currentData.length ~/ 20) + 1;
    
    // Don't show loading state if we already have data (to avoid flickering)
    try {
      final service = ref.read(statsServiceProvider);
      final newEntries = await service.getLeaderboard(page: currentPage, limit: 20);
      
      if (newEntries.isEmpty) {
        // No more entries to load - keep current data
        AppLogger.info('No more leaderboard entries to load', tag: 'LeaderboardController');
        return;
      }
      
      // Append new entries to existing list
      final updatedList = [...currentData, ...newEntries];
      state = AsyncValue.data(updatedList);
      AppLogger.info('Loaded more leaderboard entries: ${newEntries.length} new, ${updatedList.length} total', tag: 'LeaderboardController');
    } catch (e) {
      AppLogger.error('Error loading more leaderboard entries', tag: 'LeaderboardController', error: e);
      // Keep existing data on error - don't change state
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final service = ref.read(statsServiceProvider);
      final entries = await service.getLeaderboard(page: 1, limit: 20);
      state = AsyncValue.data(entries);
      AppLogger.info('Leaderboard refreshed: ${entries.length} entries', tag: 'LeaderboardController');
    } catch (e, stackTrace) {
      AppLogger.error('Error refreshing leaderboard', tag: 'LeaderboardController', error: e);
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

