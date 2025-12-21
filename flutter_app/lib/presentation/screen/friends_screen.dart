import 'package:chess_rps/common/logger.dart';
import 'package:chess_rps/common/palette.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FriendsScreen extends StatefulWidget {
  static const routeName = '/friends';

  const FriendsScreen({Key? key}) : super(key: key);

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  int _selectedFilter = 0; // 0: Online, 1: In Game, 2: Offline

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
                    const SizedBox(width: 12),
                    Text(
                      'Friends',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Palette.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        AppLogger.info('Add friend', tag: 'FriendsScreen');
                      },
                      icon: Icon(Icons.person_add, color: Palette.purpleAccent),
                      style: IconButton.styleFrom(
                        backgroundColor: Palette.purpleAccent.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Palette.purpleAccent.withOpacity(0.2)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Palette.backgroundTertiary,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Palette.glassBorder),
                  ),
                  child: TextField(
                    style: TextStyle(color: Palette.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search by name or ID...',
                      hintStyle: TextStyle(color: Palette.textSecondary),
                      prefixIcon: Icon(Icons.search, color: Palette.textSecondary),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Friend Requests
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'REQUESTS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Palette.textSecondary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Palette.error,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Palette.error.withOpacity(0.4),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Text(
                        '2 Pending',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Palette.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Requests List
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _buildRequestItem('GambitQueen', 'Sent you a request • 2m ago', true),
                      const SizedBox(height: 12),
                      _buildRequestItem('PawnSacrifice', 'Sent you a request • 1h ago', false),
                      const SizedBox(height: 24),

                      // Filter Buttons
                      Row(
                        children: [
                          _buildFilterButton('Online', 3, 0),
                          const SizedBox(width: 12),
                          _buildFilterButton('In Game', 1, 1),
                          const SizedBox(width: 12),
                          _buildFilterButton('Offline', 0, 2),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Friends List
                      _buildFriendItem('SkyWalker_99', '1850', 'Online • Lobby', true, true),
                      const SizedBox(height: 12),
                      _buildFriendItem('TacticalRose', null, 'Online • Analyzing', true, false),
                      const SizedBox(height: 12),
                      _buildFriendItem('BotCrusher', null, 'Playing • 10m left', false, false, isBot: true),
                      const SizedBox(height: 20),

                      Text(
                        'OFFLINE',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Palette.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildFriendItem('RookTakesPawn', null, 'Last seen 2h ago', false, false, isOffline: true),
                      const SizedBox(height: 12),
                      _buildFriendItem('KingPin_88', null, 'Last seen 1d ago', false, false, isOffline: true),
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

  Widget _buildRequestItem(String name, String subtitle, bool isPremium) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Palette.backgroundTertiary.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Palette.glassBorder),
        boxShadow: [
          BoxShadow(
            color: Palette.black.withOpacity(0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Palette.backgroundSecondary, Palette.backgroundTertiary],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Palette.glassBorder),
            ),
            child: Center(
              child: Text(
                name.substring(0, 2).toUpperCase(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Palette.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Palette.textPrimary,
                      ),
                    ),
                    if (isPremium) ...[
                      const SizedBox(width: 4),
                      Icon(Icons.star, color: Palette.gold, size: 16),
                    ],
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
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.check, color: Palette.success),
            style: IconButton.styleFrom(
              backgroundColor: Palette.success.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Palette.success.withOpacity(0.2)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.close, color: Palette.error),
            style: IconButton.styleFrom(
              backgroundColor: Palette.error.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Palette.error.withOpacity(0.2)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label, int count, int index) {
    final isActive = _selectedFilter == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedFilter = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: isActive
                ? LinearGradient(
                    colors: [Palette.purpleAccent, Palette.purpleAccentDark],
                  )
                : null,
            color: isActive ? null : Palette.backgroundTertiary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? Colors.transparent : Palette.glassBorder,
            ),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isActive ? Palette.textPrimary : Palette.textSecondary,
                  ),
                ),
                if (count > 0) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.white.withOpacity(0.2)
                          : Palette.backgroundSecondary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 10,
                        color: isActive ? Palette.textPrimary : Palette.textSecondary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFriendItem(
    String name,
    String? rating,
    String status,
    bool isOnline,
    bool canChallenge, {
    bool isBot = false,
    bool isOffline = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Palette.backgroundTertiary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Palette.glassBorder),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isBot
                        ? [Palette.backgroundSecondary, Palette.backgroundTertiary]
                        : [Palette.purpleAccent.withOpacity(0.2), Palette.purpleAccentDark.withOpacity(0.2)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Palette.glassBorder),
                ),
                child: isBot
                    ? Icon(Icons.smart_toy, color: Palette.purpleAccent, size: 28)
                    : Center(
                        child: Text(
                          name.substring(0, 2).toUpperCase(),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Palette.textPrimary,
                          ),
                        ),
                      ),
              ),
              if (isOnline)
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Palette.onlineGreen,
                      shape: BoxShape.circle,
                      border: Border.all(color: Palette.backgroundTertiary, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Palette.onlineGreen.withOpacity(0.8),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                )
              else if (isBot)
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Palette.purpleAccent,
                      shape: BoxShape.circle,
                      border: Border.all(color: Palette.backgroundTertiary, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Palette.purpleAccent.withOpacity(0.8),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isOffline ? Palette.textTertiary : Palette.textPrimary,
                      ),
                    ),
                    if (rating != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Palette.purpleAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Palette.purpleAccent.withOpacity(0.2)),
                        ),
                        child: Text(
                          rating,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Palette.purpleAccent,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (isOnline)
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Palette.onlineGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                    if (isOnline) const SizedBox(width: 4),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 12,
                        color: isOffline ? Palette.textTertiary : (isOnline ? Palette.success : Palette.textSecondary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (canChallenge)
            IconButton(
              onPressed: () {
                AppLogger.info('Challenge $name', tag: 'FriendsScreen');
              },
              icon: Icon(Icons.sports_martial_arts, color: Palette.textPrimary),
              style: IconButton.styleFrom(
                backgroundColor: Palette.purpleAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            )
          else if (!isOffline)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.chat_bubble_outline, color: Palette.textSecondary),
                  style: IconButton.styleFrom(
                    backgroundColor: Palette.backgroundSecondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.sports_martial_arts, color: Palette.purpleAccent),
                  style: IconButton.styleFrom(
                    backgroundColor: Palette.purpleAccent.withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Palette.purpleAccent.withOpacity(0.2)),
                    ),
                  ),
                ),
              ],
            )
          else
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.mail_outline, color: Palette.textTertiary),
              style: IconButton.styleFrom(
                backgroundColor: Palette.backgroundSecondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
        ],
      ),
    );
  }
}


