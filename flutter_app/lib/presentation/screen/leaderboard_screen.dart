import 'package:chess_rps/common/logger.dart';
import 'package:chess_rps/common/palette.dart';
import 'package:chess_rps/data/service/stats/stats_service.dart';
import 'package:chess_rps/l10n/app_localizations.dart';
import 'package:chess_rps/presentation/controller/stats_controller.dart';
import 'package:chess_rps/presentation/widget/user_avatar_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  static const routeName = '/leaderboard';

  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      // Load more when user scrolls to 80% of the list
      if (!_isLoadingMore) {
        _loadMore();
      }
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;
    
    setState(() {
      _isLoadingMore = true;
    });

    try {
      final controller = ref.read(leaderboardControllerProvider.notifier);
      await controller.loadMore();
    } catch (e) {
      AppLogger.error('Error loading more leaderboard entries', tag: 'LeaderboardScreen', error: e);
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final leaderboardAsync = ref.watch(leaderboardControllerProvider);

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
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        l10n.leaderboard,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Palette.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: leaderboardAsync.when(
                  data: (leaderboard) {
                    if (leaderboard.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.leaderboard_outlined,
                              size: 64,
                              color: Palette.textSecondary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l10n.noLeaderboardData,
                              style: TextStyle(
                                fontSize: 16,
                                color: Palette.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        final controller = ref.read(leaderboardControllerProvider.notifier);
                        await controller.refresh();
                      },
                      color: Palette.purpleAccent,
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: leaderboard.length + (_isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == leaderboard.length) {
                            // Loading indicator at the bottom
                            return Padding(
                              padding: const EdgeInsets.all(16),
                              child: Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Palette.purpleAccent),
                                ),
                              ),
                            );
                          }

                          final entry = leaderboard[index];
                          final isTopThree = entry.rank <= 3;
                          
                          return _buildLeaderboardItem(entry, isTopThree, l10n);
                        },
                      ),
                    );
                  },
                  loading: () => Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Palette.purpleAccent),
                    ),
                  ),
                  error: (error, stack) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Palette.error),
                        const SizedBox(height: 16),
                        Text(
                          l10n.errorLoadingLeaderboard,
                          style: TextStyle(
                            fontSize: 16,
                            color: Palette.error,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            final controller = ref.read(leaderboardControllerProvider.notifier);
                            controller.refresh();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Palette.purpleAccent,
                            foregroundColor: Palette.textPrimary,
                          ),
                          child: Text(l10n.retry),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboardItem(LeaderboardEntry entry, bool isTopThree, AppLocalizations l10n) {
    Color rankColor;
    IconData? rankIcon;
    
    if (entry.rank == 1) {
      rankColor = Palette.gold;
      rankIcon = Icons.looks_one;
    } else if (entry.rank == 2) {
      rankColor = Palette.silver;
      rankIcon = Icons.looks_two;
    } else if (entry.rank == 3) {
      rankColor = Palette.bronze;
      rankIcon = Icons.looks_3;
    } else {
      rankColor = Palette.textSecondary;
      rankIcon = null;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Palette.backgroundTertiary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isTopThree ? rankColor.withValues(alpha: 0.5) : Palette.glassBorder,
          width: isTopThree ? 2 : 1,
        ),
        boxShadow: isTopThree
            ? [
                BoxShadow(
                  color: rankColor.withValues(alpha: 0.3),
                  blurRadius: 12,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 40,
            child: Column(
              children: [
                if (rankIcon != null)
                  Icon(
                    rankIcon,
                    color: rankColor,
                    size: 28,
                  )
                else
                  Text(
                    '${entry.rank}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: rankColor,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          
          // Avatar
          UserAvatarByIconWidget(
            size: 48,
            border: isTopThree
                ? Border.all(color: rankColor, width: 2)
                : Border.all(color: Palette.glassBorder, width: 1),
            shadow: isTopThree
                ? BoxShadow(
                    color: rankColor.withValues(alpha: 0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  )
                : null,
          ),
          const SizedBox(width: 12),
          
          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.username,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Palette.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (entry.levelName != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Palette.purpleAccent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Palette.purpleAccent.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          entry.levelName!,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Palette.purpleAccent,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      '${l10n.level(entry.level)} • ${l10n.games(entry.totalGames)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Palette.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Rating
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.rating}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Palette.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.trending_up,
                    size: 12,
                    color: Palette.success,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${entry.winRate.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: Palette.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

