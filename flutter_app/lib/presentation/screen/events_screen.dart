import 'package:chess_rps/common/palette.dart';
import 'package:chess_rps/presentation/controller/stats_controller.dart';
import 'package:chess_rps/presentation/widget/user_avatar_widget.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class EventsScreen extends HookConsumerWidget {
  static const routeName = '/events';

  const EventsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                    border: Border.all(color: Palette.purpleAccent.withValues(alpha: 0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: Palette.purpleAccent.withValues(alpha: 0.2),
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
                                    color: Palette.error.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Palette.error.withValues(alpha: 0.3)),
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
                                    color: Colors.black.withValues(alpha: 0.4),
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
                      _buildStandingsSection(context, ref),
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
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: Palette.purpleAccent.withValues(alpha: 0.3),
                  blurRadius: 15,
                  spreadRadius: 0,
                  offset: const Offset(0, 6),
                ),
              ]
            : [
                BoxShadow(
                  color: Palette.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ],
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
        boxShadow: [
          BoxShadow(
            color: iconColor.withValues(alpha: 0.25),
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
        ],
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
                    colors: [iconColor, iconColor.withValues(alpha: 0.7)],
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
                            color: iconColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: iconColor.withValues(alpha: 0.2)),
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
                    colors: [iconColor, iconColor.withValues(alpha: 0.7)],
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
        border: Border.all(color: Palette.accent.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Palette.accent.withValues(alpha: 0.25),
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
        ],
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
                    color: Palette.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Palette.accent.withValues(alpha: 0.2)),
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
        boxShadow: [
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
        ],
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

  Widget _buildStandingsSection(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(leaderboardProvider(3));
    
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
        leaderboardAsync.when(
          data: (leaderboard) {
            if (leaderboard.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Palette.backgroundTertiary,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Palette.glassBorder),
                ),
                child: Center(
                  child: Text(
                    'No standings available',
                    style: TextStyle(
                      fontSize: 14,
                      color: Palette.textSecondary,
                    ),
                  ),
                ),
              );
            }
            
            return Container(
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
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 24, child: Text('#', style: TextStyle(fontSize: 12, color: Palette.textSecondary))),
                        Expanded(child: Text('Player', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Palette.textSecondary))),
                        SizedBox(width: 64, child: Text('Rating', textAlign: TextAlign.right, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Palette.textSecondary))),
                      ],
                    ),
                  ),
                  ...leaderboard.asMap().entries.map((entry) {
                    final index = entry.key;
                    final player = entry.value;
                    final isFirst = index == 0;
                    return Column(
                      children: [
                        if (index > 0) Divider(color: Palette.glassBorder, height: 1),
                        _buildStandingRow(
                          player.rank,
                          player.username,
                          player.rating,
                          isFirst,
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
            );
          },
          loading: () => Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Palette.purpleAccent),
              ),
            ),
          ),
          error: (error, stack) => Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Palette.backgroundTertiary,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Palette.glassBorder),
            ),
            child: Center(
              child: Text(
                'Failed to load standings',
                style: TextStyle(
                  fontSize: 14,
                  color: Palette.error,
                ),
              ),
            ),
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
          UserAvatarByIconWidget(
            size: 32,
            border: isFirst
                ? Border.all(color: Palette.gold, width: 2)
                : Border.all(color: Palette.glassBorder, width: 1),
            shadow: isFirst
                ? BoxShadow(
                    color: Palette.gold.withValues(alpha: 0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  )
                : null,
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



