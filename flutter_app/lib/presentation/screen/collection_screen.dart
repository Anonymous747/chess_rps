import 'package:chess_rps/common/logger.dart';
import 'package:chess_rps/common/palette.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CollectionScreen extends StatefulWidget {
  static const routeName = '/collection';

  const CollectionScreen({Key? key}) : super(key: key);

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  int _selectedTab = 0;
  final List<String> _tabs = ['Pieces', 'Boards', 'Avatars', 'Effects'];

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
                      'Collection',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Palette.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Palette.backgroundTertiary.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Palette.glassBorder),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Palette.purpleAccent,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Palette.purpleAccent.withOpacity(0.6),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '34/120',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Palette.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: () {
                        AppLogger.info('Shop tapped', tag: 'CollectionScreen');
                      },
                      icon: Icon(Icons.shopping_bag, color: Palette.purpleAccent),
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

              // Tabs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(
                      _tabs.length,
                      (index) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _buildTabButton(_tabs[index], index == _selectedTab, () {
                          setState(() => _selectedTab = index);
                        }),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // Featured Set
                      _buildFeaturedSet(),
                      const SizedBox(height: 24),

                      // Collection Grid
                      _buildCollectionGrid(),
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

  Widget _buildTabButton(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Palette.textPrimary : Palette.backgroundTertiary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? Colors.transparent : Palette.glassBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? Palette.background : Palette.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedSet() {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Palette.glassBorder),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Palette.backgroundTertiary,
            Palette.backgroundSecondary,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildBadge('Equipped', Palette.success),
                      const SizedBox(width: 8),
                      _buildBadge('Epic', Palette.purpleAccent),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Crystal Void Set',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Palette.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Season 4 Rewards',
                    style: TextStyle(
                      fontSize: 12,
                      color: Palette.textSecondary,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.favorite_border, color: Palette.textPrimary, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.05),
                  shape: const CircleBorder(),
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildPiecePreview(Icons.circle, Palette.purpleAccent),
                  const SizedBox(width: 8),
                  _buildPiecePreview(Icons.extension, Palette.purpleAccent, isLarge: true),
                  const SizedBox(width: 8),
                  _buildPiecePreview(Icons.square, Palette.purpleAccent),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  AppLogger.info('Customize tapped', tag: 'CollectionScreen');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Palette.purpleAccent,
                  foregroundColor: Palette.textPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Customize',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildPiecePreview(IconData icon, Color color, {bool isLarge = false}) {
    return Container(
      width: isLarge ? 56 : 48,
      height: isLarge ? 80 : 64,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withOpacity(0.2),
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
        border: Border(
          top: BorderSide(color: color.withOpacity(0.2)),
          left: BorderSide(color: color.withOpacity(0.2)),
          right: BorderSide(color: color.withOpacity(0.2)),
        ),
      ),
      child: Icon(icon, color: color, size: isLarge ? 40 : 32),
    );
  }

  Widget _buildCollectionGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'My Pieces',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Palette.textSecondary,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'Sort by: Rarity',
                style: TextStyle(
                  fontSize: 12,
                  color: Palette.purpleAccent,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 0.75,
          children: [
            _buildCollectionItem('Golden Age', 'Legendary', Icons.star, Palette.gold, true, true),
            _buildCollectionItem('Neon City', 'Rare', Icons.trip_origin, Palette.accent, true, false),
            _buildCollectionItem('Obsidian', 'Unlock at Lvl 50', Icons.workspace_premium, Palette.textTertiary, false, false, isLocked: true),
            _buildCollectionItem('Forest Spirit', 'Uncommon', Icons.circle, Palette.success, true, false),
            _buildCollectionItem('Classic Wood', 'Common', Icons.square, Palette.textSecondary, true, false),
            _buildShopCard(),
          ],
        ),
      ],
    );
  }

  Widget _buildCollectionItem(
    String name,
    String rarity,
    IconData icon,
    Color color,
    bool isOwned,
    bool isEquipped, {
    bool isLocked = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Palette.backgroundTertiary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Palette.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Palette.backgroundSecondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      icon,
                      size: 48,
                      color: isLocked ? Palette.textTertiary : color,
                    ),
                  ),
                  if (isLocked)
                    Container(
                      color: Colors.black.withOpacity(0.4),
                      child: Center(
                        child: Icon(Icons.lock, color: Palette.textSecondary, size: 24),
                      ),
                    ),
                  if (!isLocked && rarity == 'Legendary')
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Icon(Icons.star, color: color, size: 16),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isLocked ? Palette.textTertiary : Palette.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      rarity,
                      style: TextStyle(
                        fontSize: 10,
                        color: isLocked ? Palette.textTertiary : color,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  isLocked ? Icons.shopping_cart : Icons.checkroom,
                  color: isLocked ? Palette.purpleAccent : Palette.textSecondary,
                  size: 20,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: isLocked
                      ? Palette.purpleAccent.withOpacity(0.1)
                      : Colors.white.withOpacity(0.05),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShopCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Palette.purpleAccentDark.withOpacity(0.5),
            Palette.purpleAccent.withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Palette.purpleAccent.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Palette.purpleAccent,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Palette.purpleAccent.withOpacity(0.4),
                  blurRadius: 15,
                ),
              ],
            ),
            child: Icon(Icons.add, color: Palette.textPrimary, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            'Get More',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Palette.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Visit the Shop',
            style: TextStyle(
              fontSize: 10,
              color: Palette.purpleAccentLight,
            ),
          ),
        ],
      ),
    );
  }
}
