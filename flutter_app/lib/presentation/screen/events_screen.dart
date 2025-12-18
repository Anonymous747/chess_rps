import 'package:chess_rps/common/palette.dart';
import 'package:flutter/material.dart';

class EventsScreen extends StatelessWidget {
  static const routeName = '/events';

  const EventsScreen({Key? key}) : super(key: key);

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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Events',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Palette.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Season 4: Shadow Gambit',
                          style: TextStyle(
                            fontSize: 14,
                            color: Palette.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.calendar_month, color: Palette.textSecondary),
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

              // Featured Event
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 240,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Palette.purpleAccent.withOpacity(0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: Palette.purpleAccent.withOpacity(0.2),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Palette.purpleAccentDark,
                              Palette.backgroundTertiary,
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Palette.error.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Palette.error.withOpacity(0.3)),
                                  ),
                                  child: Text(
                                    'LIVE NOW',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Palette.error,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.visibility, size: 14, color: Palette.textSecondary),
                                      const SizedBox(width: 4),
                                      Text(
                                        '12.4k',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Palette.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Grand Prix 2024',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Palette.textPrimary,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'The ultimate rapid chess showdown. Watch grandmasters battle for the throne.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Palette.purpleAccentLight,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Palette.textPrimary,
                                    foregroundColor: Palette.background,
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.play_circle, size: 18),
                                      const SizedBox(width: 8),
                                      Text('Watch Stream'),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                OutlinedButton(
                                  onPressed: () {},
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Palette.textPrimary,
                                    side: BorderSide(color: Palette.glassBorder),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  ),
                                  child: Text('Details'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Filter Tabs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterTab('All Events', true),
                      const SizedBox(width: 12),
                      _buildFilterTab('Tournaments', false),
                      const SizedBox(width: 12),
                      _buildFilterTab('Challenges', false),
                      const SizedBox(width: 12),
                      _buildFilterTab('Community', false),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Events List
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _buildEventCard(
                        'Weekly Blitz',
                        'Starts in 2h 15m • 3+2 Blitz Arena',
                        '\$500 Prize',
                        '128/256',
                        Icons.emoji_events,
                        Palette.gold,
                        'Registration Open',
                        0.5,
                      ),
                      const SizedBox(height: 16),
                      _buildChallengeCard(),
                      const SizedBox(height: 16),
                      _buildClubWarsCard(),
                      const SizedBox(height: 16),
                      _buildStandingsSection(),
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

  Widget _buildFilterTab(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? Palette.purpleAccent : Palette.backgroundTertiary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? Colors.transparent : Palette.glassBorder,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isActive ? Palette.textPrimary : Palette.textSecondary,
        ),
      ),
    );
  }

  Widget _buildEventCard(
    String title,
    String subtitle,
    String prize,
    String participants,
    IconData icon,
    Color iconColor,
    String status,
    double progress,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Palette.backgroundTertiary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Palette.glassBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [iconColor, iconColor.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Palette.glassBorder),
                ),
                child: Icon(icon, color: Palette.textPrimary, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Palette.textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: iconColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: iconColor.withOpacity(0.2)),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: iconColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Palette.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.emoji_events, size: 14, color: iconColor),
                            const SizedBox(width: 4),
                            Text(prize, style: TextStyle(fontSize: 12, color: Palette.textSecondary)),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Row(
                          children: [
                            Icon(Icons.group, size: 14, color: Palette.textTertiary),
                            const SizedBox(width: 4),
                            Text(participants, style: TextStyle(fontSize: 12, color: Palette.textSecondary)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.chevron_right, color: Palette.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: Palette.backgroundSecondary,
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [iconColor, iconColor.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Palette.backgroundTertiary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Palette.accent.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Palette.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Palette.accent.withOpacity(0.2)),
                  ),
                  child: Text(
                    'DAILY CHALLENGE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Palette.accent,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Mate in 3 Puzzle',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Palette.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Solve today\'s hardest puzzle to earn points.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Palette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 56,
            height: 56,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: 0.75,
                  strokeWidth: 4,
                  backgroundColor: Palette.backgroundSecondary,
                  valueColor: AlwaysStoppedAnimation<Color>(Palette.accent),
                ),
                Text(
                  '75%',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Palette.accent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClubWarsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Palette.backgroundTertiary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Palette.glassBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Palette.backgroundSecondary,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Palette.glassBorder),
            ),
            child: Icon(Icons.groups, color: Palette.textSecondary, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Club Wars',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Palette.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Team vs Team • Starts in 3 days',
                  style: TextStyle(
                    fontSize: 12,
                    color: Palette.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 20,
                  child: Stack(
                    children: [
                      for (int i = 0; i < 3; i++)
                        Positioned(
                          left: i * 12.0,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Palette.backgroundSecondary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Palette.backgroundTertiary, width: 2),
                            ),
                          ),
                        ),
                      Positioned(
                        left: 3 * 12.0 + 4.0,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Palette.backgroundSecondary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Palette.backgroundTertiary, width: 2),
                          ),
                          child: Center(
                            child: Text(
                              '+42',
                              style: TextStyle(fontSize: 8, color: Palette.textPrimary),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Palette.purpleAccent,
              foregroundColor: Palette.textPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text('Join'),
          ),
        ],
      ),
    );
  }

  Widget _buildStandingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Top Standings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Palette.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'View All',
                style: TextStyle(color: Palette.purpleAccent),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Palette.backgroundTertiary,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Palette.glassBorder),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(width: 24, child: Text('#', style: TextStyle(fontSize: 12, color: Palette.textSecondary))),
                    Expanded(child: Text('Player', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Palette.textSecondary))),
                    SizedBox(width: 64, child: Text('Points', textAlign: TextAlign.right, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Palette.textSecondary))),
                  ],
                ),
              ),
              _buildStandingRow(1, 'GrandmasterX', 2450, true),
              Divider(color: Palette.glassBorder, height: 1),
              _buildStandingRow(2, 'TacticalPawn', 2310, false),
              Divider(color: Palette.glassBorder, height: 1),
              _buildStandingRow(3, 'RookToE4', 2180, false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStandingRow(int rank, String name, int points, bool isFirst) {
    return ListTile(
      leading: SizedBox(
        width: 24,
        child: Text(
          '$rank',
          style: TextStyle(
            fontSize: isFirst ? 18 : 16,
            fontWeight: isFirst ? FontWeight.bold : FontWeight.normal,
            color: isFirst ? Palette.gold : Palette.textSecondary,
          ),
        ),
      ),
      title: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              gradient: isFirst
                  ? LinearGradient(colors: [Palette.purpleAccent, Palette.purpleAccentDark])
                  : null,
              color: isFirst ? null : Palette.backgroundSecondary,
              shape: BoxShape.circle,
              border: Border.all(color: Palette.glassBorder),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Palette.textPrimary,
            ),
          ),
        ],
      ),
      trailing: Text(
        '$points',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: isFirst ? Palette.purpleAccent : Palette.textPrimary,
        ),
      ),
    );
  }
}
