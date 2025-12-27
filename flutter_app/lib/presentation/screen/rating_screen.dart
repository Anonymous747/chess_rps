import 'package:chess_rps/common/logger.dart';
import 'package:chess_rps/common/palette.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RatingScreen extends StatelessWidget {
  static const routeName = '/rating';

  const RatingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                      _buildRatingCard(),
                      const SizedBox(height: 32),
                      
                      // History Section
                      _buildHistorySection(),
                      const SizedBox(height: 32),
                      
                      // Mode Breakdown
                      _buildModeBreakdown(),
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

  Widget _buildRatingCard() {
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
                    'Tier 7',
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
            '2,458',
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
                'Grandmaster II',
                style: TextStyle(
                  fontSize: 14,
                  color: Palette.textSecondary,
                ),
              ),
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
                  color: Palette.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Palette.success.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.trending_up, size: 14, color: Palette.success),
                    const SizedBox(width: 4),
                    Text(
                      '+24',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Palette.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Stats Grid
          Row(
            children: [
              Expanded(
                child: _buildStatItem('Win Rate', '58%', Palette.textPrimary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem('Percentile', 'Top 1.2%', Palette.purpleAccent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem('Games', '1,240', Palette.textPrimary),
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

  Widget _buildHistorySection() {
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
            painter: _ChartPainter(),
            child: Container(),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Oct 1', style: TextStyle(fontSize: 10, color: Palette.textTertiary)),
            Text('Oct 8', style: TextStyle(fontSize: 10, color: Palette.textTertiary)),
            Text('Oct 15', style: TextStyle(fontSize: 10, color: Palette.textTertiary)),
            Text('Oct 22', style: TextStyle(fontSize: 10, color: Palette.textTertiary)),
            Text('Today', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Palette.purpleAccent)),
          ],
        ),
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

  Widget _buildModeBreakdown() {
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
        _buildModeItem('Blitz', '3+2 • 5 min', 2310, 12, true, Icons.bolt, Palette.purpleAccent),
        const SizedBox(height: 12),
        _buildModeItem('Bullet', '1+0 • 2+1', 2150, -5, false, Icons.rocket_launch, Palette.gold),
        const SizedBox(height: 12),
        _buildModeItem('Chess RPS', 'Hybrid Mode', 2560, 45, true, Icons.extension, Palette.purpleAccent, isFeatured: true),
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
                '$rating',
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
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Palette.purpleAccent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final points = [
      Offset(0, size.height * 0.7),
      Offset(size.width * 0.2, size.height * 0.5),
      Offset(size.width * 0.4, size.height * 0.45),
      Offset(size.width * 0.6, size.height * 0.3),
      Offset(size.width * 0.8, size.height * 0.35),
      Offset(size.width, size.height * 0.1),
    ];

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

    // Draw point
    final pointPaint = Paint()
      ..color = Palette.textPrimary
      ..style = PaintingStyle.fill;
    canvas.drawCircle(points[points.length - 1], 5, pointPaint);
    canvas.drawCircle(points[points.length - 1], 5, Paint()..color = Palette.purpleAccent..style = PaintingStyle.stroke..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

