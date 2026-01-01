import 'package:chess_rps/common/logger.dart';
import 'package:chess_rps/common/palette.dart';
import 'package:chess_rps/data/service/stats/stats_service.dart';
import 'package:chess_rps/presentation/controller/stats_controller.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class RatingScreen extends ConsumerWidget {
  static const routeName = '/rating';

  const RatingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsControllerProvider);
    
    return statsAsync.when(
      data: (stats) => _buildContent(context, stats),
      loading: () => _buildLoading(context),
      error: (error, stack) => _buildError(context, error),
    );
  }

  Widget _buildLoading(BuildContext context) {
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
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Palette.accent),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, Object error) {
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
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Palette.error),
                const SizedBox(height: 16),
                Text(
                  'Error loading rating',
                  style: TextStyle(
                    fontSize: 16,
                    color: Palette.error,
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.pop(),
                  child: Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, stats) {
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
                    const Spacer(),
                    Text(
                      'Rating Overview',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Palette.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        AppLogger.info('Share rating', tag: 'RatingScreen');
                      },
                      icon: Icon(Icons.share, color: Palette.textSecondary),
                      style: IconButton.styleFrom(
                        backgroundColor: Palette.backgroundTertiary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Palette.glassBorder),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // Rating Card
                      _buildRatingCard(stats),
                      const SizedBox(height: 32),
                      
                      // History Section
                      _buildHistorySection(stats),
                      const SizedBox(height: 32),
                      
                      // Mode Breakdown
                      _buildModeBreakdown(stats),
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

  Widget _buildRatingCard(UserStats stats) {
    // Use level name from stats, or fallback to "Level X"
    final tierDisplay = stats.levelName ?? 'Level ${stats.level}';
    
    // Format rating with comma
    final ratingText = _formatNumber(stats.rating);
    
    // Rating change
    final ratingChange = stats.ratingChange;
    final ratingChangeText = ratingChange >= 0 ? '+$ratingChange' : '$ratingChange';
    final ratingChangeColor = ratingChange >= 0 ? Palette.success : Palette.error;
    
    // Win rate
    final winRateText = stats.totalGames > 0 ? '${stats.winRate.toStringAsFixed(1)}%' : '0%';
    
    // Total games
    final gamesText = _formatNumber(stats.totalGames);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Palette.glassBorder),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Palette.purpleAccentDark.withValues(alpha: 0.3),
            Palette.backgroundTertiary,
            Palette.backgroundSecondary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Palette.purpleAccent.withValues(alpha: 0.25),
            blurRadius: 25,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Palette.black.withValues(alpha: 0.15),
            blurRadius: 15,
            spreadRadius: 0,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Tier Badge
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      Palette.purpleAccent,
                      Palette.purpleAccentDark,
                    ],
                  ),
                  border: Border.all(color: Palette.glassBorder),
                ),
                child: Icon(
                  Icons.military_tech,
                  color: Palette.gold,
                  size: 40,
                ),
              ),
              Positioned(
                bottom: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Palette.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Palette.purpleAccent),
                  ),
                  child: Text(
                    'Level ${stats.level}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Palette.purpleAccent,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // MMR
          Text(
            ratingText,
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Palette.textPrimary,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Rank and Change
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                tierDisplay,
                style: TextStyle(
                  fontSize: 14,
                  color: Palette.textSecondary,
                ),
              ),
              if (ratingChange != 0) ...[
                const SizedBox(width: 8),
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Palette.textTertiary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: ratingChangeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: ratingChangeColor.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        ratingChange >= 0 ? Icons.trending_up : Icons.trending_down,
                        size: 14,
                        color: ratingChangeColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        ratingChangeText,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: ratingChangeColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Stats Grid
          Row(
            children: [
              Expanded(
                child: _buildStatItem('Win Rate', winRateText, Palette.textPrimary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem('Level', '${stats.level}', Palette.purpleAccent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem('Games', gamesText, Palette.textPrimary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color valueColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Palette.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection(UserStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Palette.purpleAccent, size: 20),
                const SizedBox(width: 8),
                Text(
                  'History',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Palette.textPrimary,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Palette.backgroundTertiary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Palette.glassBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTimeFilterButton('1M', true),
                  _buildTimeFilterButton('3M', false),
                  _buildTimeFilterButton('ALL', false),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: 200,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Palette.backgroundTertiary,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Palette.glassBorder),
            boxShadow: [
              BoxShadow(
                color: Palette.purpleAccent.withValues(alpha: 0.15),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Palette.black.withValues(alpha: 0.1),
                blurRadius: 12,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: CustomPaint(
            painter: _ChartPainter(stats.performanceHistory ?? []),
            child: Container(),
          ),
        ),
        const SizedBox(height: 12),
        _buildHistoryLabels(stats.performanceHistory ?? []),
      ],
    );
  }

  Widget _buildTimeFilterButton(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? Palette.purpleAccent : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isActive ? Palette.textPrimary : Palette.textSecondary,
        ),
      ),
    );
  }

  Widget _buildHistoryLabels(List<PerformanceHistoryItem> history) {
    if (history.isEmpty) {
      return SizedBox.shrink();
    }
    
    // Get first and last dates
    final firstDate = history.first.createdAt;
    final lastDate = history.last.createdAt;
    
    // Calculate interval dates (divide into 5 segments)
    final duration = lastDate.difference(firstDate);
    final interval = duration.inDays > 0 ? duration.inDays ~/ 5 : 1;
    
    final labels = <Widget>[];
    for (int i = 0; i < 5; i++) {
      final date = firstDate.add(Duration(days: interval * i));
      final isLast = i == 4;
      labels.add(
        Text(
          isLast ? 'Today' : '${date.month}/${date.day}',
          style: TextStyle(
            fontSize: 10,
            fontWeight: isLast ? FontWeight.bold : FontWeight.normal,
            color: isLast ? Palette.purpleAccent : Palette.textTertiary,
          ),
        ),
      );
    }
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: labels,
    );
  }

  String _formatNumber(int value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }
    return value.toString();
  }

  Widget _buildModeBreakdown(UserStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.category, color: Palette.purpleAccent, size: 20),
            const SizedBox(width: 8),
            Text(
              'Mode Breakdown',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Palette.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildModeItem('Classical', 'Standard Chess', stats.rating, stats.ratingChange, stats.ratingChange >= 0, Icons.extension, Palette.purpleAccent),
        const SizedBox(height: 12),
        _buildModeItem('RPS Mode', 'Rock Paper Scissors', stats.rating, stats.ratingChange, stats.ratingChange >= 0, Icons.extension, Palette.purpleAccent, isFeatured: true),
      ],
    );
  }

  Widget _buildModeItem(
    String name,
    String description,
    int rating,
    int change,
    bool isPositive,
    IconData icon,
    Color iconColor, {
    bool isFeatured = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Palette.backgroundTertiary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isFeatured ? Palette.purpleAccent.withValues(alpha: 0.3) : Palette.glassBorder,
        ),
        boxShadow: isFeatured
            ? [
                BoxShadow(
                  color: Palette.purpleAccent.withValues(alpha: 0.25),
                  blurRadius: 18,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Palette.black.withValues(alpha: 0.15),
                  blurRadius: 12,
                  spreadRadius: 0,
                  offset: const Offset(0, 5),
                ),
              ]
            : [
                BoxShadow(
                  color: iconColor.withValues(alpha: 0.15),
                  blurRadius: 15,
                  spreadRadius: 0,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: Palette.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        children: [
          if (isFeatured)
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Palette.purpleAccent, Palette.purpleAccentDark],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          if (isFeatured) const SizedBox(width: 12),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: iconColor.withValues(alpha: 0.2)),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Palette.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Palette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatNumber(rating),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Palette.textPrimary,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 14,
                    color: isPositive ? Palette.success : Palette.error,
                  ),
                  Text(
                    '${isPositive ? '+' : ''}$change',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isPositive ? Palette.success : Palette.error,
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

class _ChartPainter extends CustomPainter {
  final List<PerformanceHistoryItem> history;
  
  _ChartPainter(this.history);
  
  @override
  void paint(Canvas canvas, Size size) {
    if (history.isEmpty) {
      return;
    }
    
    // Find min and max rating for scaling
    final ratings = history.map((h) => h.rating).toList();
    final minRating = ratings.reduce((a, b) => a < b ? a : b);
    final maxRating = ratings.reduce((a, b) => a > b ? a : b);
    final ratingRange = maxRating - minRating;
    final scaleY = ratingRange > 0 ? size.height / ratingRange : 1.0;
    
    final paint = Paint()
      ..color = Palette.purpleAccent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final points = <Offset>[];
    
    for (int i = 0; i < history.length; i++) {
      final x = history.length > 1 ? (size.width / (history.length - 1)) * i : size.width / 2;
      final normalizedRating = maxRating - history[i].rating;
      final y = normalizedRating * scaleY;
      points.add(Offset(x, y));
    }
    
    if (points.isEmpty) return;
    
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(path, paint);

    // Draw gradient fill
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Palette.purpleAccent.withValues(alpha: 0.4),
          Palette.purpleAccent.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(fillPath, fillPaint);

    // Draw point on last rating
    if (points.isNotEmpty) {
      final lastPoint = points.last;
      final pointPaint = Paint()
        ..color = Palette.textPrimary
        ..style = PaintingStyle.fill;
      canvas.drawCircle(lastPoint, 5, pointPaint);
      canvas.drawCircle(lastPoint, 5, Paint()..color = Palette.purpleAccent..style = PaintingStyle.stroke..strokeWidth = 2);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is! _ChartPainter) return true;
    if (oldDelegate.history.length != history.length) return true;
    for (int i = 0; i < history.length; i++) {
      if (oldDelegate.history[i].rating != history[i].rating ||
          oldDelegate.history[i].createdAt != history[i].createdAt) {
        return true;
      }
    }
    return false;
  }
}

