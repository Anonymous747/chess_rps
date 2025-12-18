import 'package:chess_rps/common/logger.dart';
import 'package:chess_rps/common/palette.dart';
import 'package:chess_rps/data/service/collection/collection_service.dart';
import 'package:chess_rps/presentation/controller/collection_controller.dart';
import 'package:chess_rps/presentation/utils/collection_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CollectionScreen extends ConsumerStatefulWidget {
  static const routeName = '/collection';

  const CollectionScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends ConsumerState<CollectionScreen> {
  int _selectedTab = 0;
  final List<CollectionCategory> _tabs = [
    CollectionCategory.PIECES,
    CollectionCategory.BOARDS,
    CollectionCategory.AVATARS,
    CollectionCategory.EFFECTS,
  ];

  String _getTabLabel(CollectionCategory category) {
    switch (category) {
      case CollectionCategory.PIECES:
        return 'Pieces';
      case CollectionCategory.BOARDS:
        return 'Boards';
      case CollectionCategory.AVATARS:
        return 'Avatars';
      case CollectionCategory.EFFECTS:
        return 'Effects';
    }
  }

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
                    _buildCollectionStats(),
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
                          setState(() {
                            _selectedTab = index;
                            // Refresh collection when tab changes
                            ref.read(userCollectionControllerProvider.notifier)
                                .refreshCollection(category: _tabs[index]);
                          });
                        }),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Content
              Expanded(
                child: _buildCollectionContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(CollectionCategory category, bool isActive, VoidCallback onTap) {
    final label = _getTabLabel(category);
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

  Widget _buildCollectionStats() {
    final statsAsync = ref.watch(collectionStatsControllerProvider);
    
    return statsAsync.when(
      data: (stats) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Palette.backgroundTertiary.withValues(alpha: 0.8),
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
                    color: Palette.purpleAccent.withValues(alpha: 0.6),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${stats.ownedItems}/${stats.totalItems}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Palette.textSecondary,
              ),
            ),
          ],
        ),
      ),
      loading: () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Palette.purpleAccent),
          ),
        ),
      ),
      error: (error, stack) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Text(
          '0/0',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Palette.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildCollectionContent() {
    final currentCategory = _tabs[_selectedTab];
    final userCollectionAsync = ref.watch(userCollectionControllerProvider);
    final allItemsAsync = ref.watch(collectionControllerProvider);
    
    return userCollectionAsync.when(
      data: (userCollection) => allItemsAsync.when(
        data: (allItems) {
          // Filter items by selected category
          final categoryItems = allItems.where((item) => item.category == currentCategory).toList();
          
          // Create a map of user collection items by item_id
          final userCollectionMap = <int, UserCollectionItem>{};
          for (final uc in userCollection) {
            if (uc.item.category == currentCategory) {
              userCollectionMap[uc.itemId] = uc;
            }
          }
          
          // Find equipped item for featured set
          UserCollectionItem? equippedItem;
          try {
            equippedItem = userCollection.firstWhere(
              (uc) => uc.isEquipped && uc.item.category == currentCategory,
            );
          } catch (e) {
            // No equipped item, try to find any owned item in this category
            try {
              equippedItem = userCollection.firstWhere(
                (uc) => uc.isOwned && uc.item.category == currentCategory,
              );
            } catch (e2) {
              // No owned items in this category
              equippedItem = null;
            }
          }
          
          // If no user collection items, find first item from all items
          if (equippedItem == null && categoryItems.isNotEmpty) {
            final firstItem = categoryItems.first;
            equippedItem = UserCollectionItem(
              id: 0,
              userId: 0,
              itemId: firstItem.id,
              item: firstItem,
              isOwned: false,
              isEquipped: false,
            );
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                // Featured Set (show equipped item or first owned item)
                if (equippedItem != null)
                  _buildFeaturedSet(equippedItem.item, equippedItem.isEquipped),
                if (equippedItem != null) const SizedBox(height: 24),
                
                // Collection Grid
                _buildCollectionGrid(categoryItems, userCollectionMap, currentCategory),
                const SizedBox(height: 100),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(
            'Error loading items',
            style: TextStyle(color: Palette.error),
          ),
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text(
          'Error loading collection',
          style: TextStyle(color: Palette.error),
        ),
      ),
    );
  }

  Widget _buildFeaturedSet(CollectionItem item, bool isEquipped) {
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
                      if (isEquipped)
                        _buildBadge('Equipped', Palette.success),
                      if (isEquipped) const SizedBox(width: 8),
                      _buildBadge(
                        CollectionUtils.getRarityDisplayName(item.rarity),
                        CollectionUtils.getColorFromHexOrRarity(item.colorHex, item.rarity),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Palette.textPrimary,
                    ),
                  ),
                  if (item.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.description!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Palette.textSecondary,
                      ),
                    ),
                  ],
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
                  _buildPiecePreview(
                    CollectionUtils.getIconFromName(item.iconName),
                    CollectionUtils.getColorFromHexOrRarity(item.colorHex, item.rarity),
                    isLarge: true,
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  AppLogger.info('Customize tapped for ${item.name}', tag: 'CollectionScreen');
                  // TODO: Navigate to customization screen
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

  Widget _buildCollectionGrid(
    List<CollectionItem> items,
    Map<int, UserCollectionItem> userCollectionMap,
    CollectionCategory category,
  ) {
    // Sort items by rarity (Legendary first, then Epic, etc.)
    items.sort((a, b) {
      final rarityOrder = {
        CollectionRarity.LEGENDARY: 0,
        CollectionRarity.EPIC: 1,
        CollectionRarity.RARE: 2,
        CollectionRarity.UNCOMMON: 3,
        CollectionRarity.COMMON: 4,
      };
      return (rarityOrder[a.rarity] ?? 4).compareTo(rarityOrder[b.rarity] ?? 4);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'My ${_getTabLabel(category)}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Palette.textSecondary,
              ),
            ),
            TextButton(
              onPressed: () {
                AppLogger.info('Sort button tapped', tag: 'CollectionScreen');
                // TODO: Implement sorting options
              },
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
            ...items.map((item) {
              final userItem = userCollectionMap[item.id];
              final isOwned = userItem?.isOwned ?? false;
              final isEquipped = userItem?.isEquipped ?? false;
              final isLocked = !isOwned && (item.unlockLevel != null);
              
              return _buildCollectionItem(
                item,
                userItem,
                isOwned,
                isEquipped,
                isLocked,
              );
            }),
            _buildShopCard(),
          ],
        ),
      ],
    );
  }

  Widget _buildCollectionItem(
    CollectionItem item,
    UserCollectionItem? userItem,
    bool isOwned,
    bool isEquipped,
    bool isLocked,
  ) {
    final color = CollectionUtils.getColorFromHexOrRarity(item.colorHex, item.rarity);
    final icon = CollectionUtils.getIconFromName(item.iconName);
    final rarityText = item.unlockLevel != null && isLocked
        ? 'Unlock at Lvl ${item.unlockLevel}'
        : CollectionUtils.getRarityDisplayName(item.rarity);
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
                  if (!isLocked && item.rarity == CollectionRarity.LEGENDARY)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Icon(Icons.star, color: color, size: 16),
                    ),
                  if (isEquipped)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Palette.success,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.check, color: Palette.textPrimary, size: 12),
                      ),
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
                      item.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isLocked ? Palette.textTertiary : Palette.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      rarityText,
                      style: TextStyle(
                        fontSize: 10,
                        color: isLocked ? Palette.textTertiary : color,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: isLocked
                    ? () {
                        AppLogger.info('Unlock item ${item.id}', tag: 'CollectionScreen');
                        ref.read(userCollectionControllerProvider.notifier).unlockItem(item.id);
                      }
                    : isEquipped
                        ? null // Disable if already equipped
                        : () {
                            AppLogger.info('Equip item ${item.id}', tag: 'CollectionScreen');
                            ref.read(userCollectionControllerProvider.notifier)
                                .equipItem(item.id, item.category);
                          },
                icon: Icon(
                  isLocked ? Icons.shopping_cart : Icons.checkroom,
                  color: isLocked
                      ? Palette.purpleAccent
                      : isEquipped
                          ? Palette.success
                          : Palette.textSecondary,
                  size: 20,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: isLocked
                      ? Palette.purpleAccent.withValues(alpha: 0.1)
                      : isEquipped
                          ? Palette.success.withValues(alpha: 0.1)
                          : Colors.white.withValues(alpha: 0.05),
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

