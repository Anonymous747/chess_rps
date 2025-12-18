import 'package:chess_rps/common/palette.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatelessWidget {
  static const routeName = '/profile';

  const ProfileScreen({Key? key}) : super(key: key);

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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: Icon(Icons.arrow_back, color: Palette.textSecondary),
                    ),
                    Text(
                      'PLAYER PROFILE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Palette.textSecondary,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.share, color: Palette.textSecondary),
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
                      // Profile Header
                      _buildProfileHeader(),
                      const SizedBox(height: 24),

                      // Stats Grid
                      _buildStatsGrid(),
                      const SizedBox(height: 24),

                      // Performance Chart
                      _buildPerformanceSection(),
                      const SizedBox(height: 24),

                      // Achievements
                      _buildAchievementsSection(),
                      const SizedBox(height: 24),

                      // Showcase
                      _buildShowcaseSection(),
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

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Palette.purpleAccent.withOpacity(0.3),
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
              child: CircularProgressIndicator(
                value: 0.3,
                strokeWidth: 2,
                color: Palette.purpleAccent,
                backgroundColor: Colors.transparent,
              ),
            ),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Palette.glassBorder, width: 2),
              ),
            ),
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Palette.purpleAccent, Palette.purpleAccentDark],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Palette.purpleAccent.withOpacity(0.4),
                    blurRadius: 25,
                  ),
                ],
              ),
              child: Icon(Icons.person, color: Palette.textPrimary, size: 48),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Palette.background,
                  shape: BoxShape.circle,
                ),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Palette.purpleAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: Palette.background, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      '42',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Palette.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Grandmaster',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Palette.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.verified, color: Palette.gold, size: 20),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'ID: 8839201 • Joined 2023',
          style: TextStyle(
            fontSize: 14,
            color: Palette.textSecondary,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Palette.textPrimary,
                  foregroundColor: Palette.background,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text('Add Friend'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: Palette.textPrimary,
                  side: BorderSide(color: Palette.glassBorder),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text('Message'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard('Rating', '1250', '+12', Palette.success, Icons.trending_up),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard('Win Rate', '58%', '240 Games', Palette.accent, null),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard('Puzzle', '2100', 'Rank 5', Palette.purpleAccent, Icons.military_tech),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, String subtitle, Color color, IconData? icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Palette.backgroundTertiary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Palette.glassBorder),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Palette.textTertiary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 10, color: color),
                const SizedBox(width: 4),
              ],
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: color.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Performance',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Palette.textPrimary,
              ),
            ),
            Row(
              children: [
                _buildTimeFilter('Weekly', true),
                const SizedBox(width: 8),
                _buildTimeFilter('Monthly', false),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 160,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Palette.backgroundTertiary,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Palette.glassBorder),
          ),
          child: CustomPaint(
            painter: _PerformanceChartPainter(),
            child: Container(),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeFilter(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? Colors.white.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: isActive ? Palette.textPrimary : Palette.textSecondary,
        ),
      ),
    );
  }

  Widget _buildAchievementsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Achievements',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Palette.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'View All',
                style: TextStyle(color: Palette.accent),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildAchievementCard('Grandmaster', 'Reach 2500 MMR', Icons.emoji_events, Palette.gold, true),
              const SizedBox(width: 12),
              _buildAchievementCard('On Fire', '10 Win Streak', Icons.local_fire_department, Palette.error, true),
              const SizedBox(width: 12),
              _buildAchievementCard('Puzzle Master', 'Solve 1000 Puzzles', Icons.extension, Palette.accent, false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    bool isUnlocked,
  ) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Palette.backgroundTertiary,
            Palette.backgroundSecondary,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Palette.glassBorder),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              boxShadow: isUnlocked
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.2),
                        blurRadius: 15,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              color: isUnlocked ? color : Palette.textTertiary,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isUnlocked ? Palette.textPrimary : Palette.textTertiary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: isUnlocked ? Palette.textTertiary : Palette.textTertiary.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildShowcaseSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Showcase',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Palette.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildShowcaseItem('Void Spirit Knight', 'Legendary Skin', Icons.extension, Palette.purpleAccent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildShowcaseItem('Nebula Queen', 'Epic Skin', Icons.star, Palette.purpleAccentLight),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildShowcaseItem(String title, String subtitle, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Palette.backgroundTertiary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Palette.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 128,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Center(
              child: Icon(
                icon,
                size: 64,
                color: color,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Palette.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PerformanceChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Palette.purpleAccent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final points = [
      Offset(size.width * 0.0, size.height * 0.67),
      Offset(size.width * 0.2, size.height * 0.58),
      Offset(size.width * 0.4, size.height * 0.42),
      Offset(size.width * 0.6, size.height * 0.5),
      Offset(size.width * 0.8, size.height * 0.25),
      Offset(size.width * 1.0, size.height * 0.08),
    ];

    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(path, paint);

    // Fill
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Palette.purpleAccent.withOpacity(0.3),
          Palette.purpleAccent.withOpacity(0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // Points
    for (final point in [points[2], points[4]]) {
      canvas.drawCircle(point, 3, Paint()..color = Palette.purpleAccent..style = PaintingStyle.fill);
      canvas.drawCircle(point, 3, Paint()..color = Palette.background..style = PaintingStyle.stroke..strokeWidth = 2);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
