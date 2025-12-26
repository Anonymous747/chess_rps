import 'package:chess_rps/common/logger.dart';
import 'package:chess_rps/common/palette.dart';
import 'package:chess_rps/data/service/collection/collection_service.dart';
import 'package:chess_rps/presentation/controller/collection_controller.dart';
import 'package:chess_rps/presentation/controller/settings_controller.dart';
import 'package:chess_rps/presentation/utils/avatar_utils.dart';
import 'package:chess_rps/presentation/utils/collection_utils.dart';
import 'package:chess_rps/presentation/utils/piece_pack_utils.dart';
import 'package:chess_rps/presentation/utils/board_theme_utils.dart';
import 'package:chess_rps/presentation/utils/effect_utils.dart';
import 'package:chess_rps/presentation/widget/collection/piece_pack_overlay.dart';
import 'package:chess_rps/presentation/widget/skeleton_loader.dart';
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

  @override
  void initState() {
    super.initState();
    // Check if we should open avatars tab from query parameter on initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final uri = GoRouterState.of(context).uri;
        final tabParam = uri.queryParameters['tab'];
        if (tabParam == 'avatars' && _selectedTab != _tabs.indexOf(CollectionCategory.AVATARS)) {
          setState(() {
            _selectedTab = _tabs.indexOf(CollectionCategory.AVATARS);
          });
          // Refresh avatars collection
          ref
              .read(userCollectionControllerProvider.notifier)
              .refreshCollection(category: CollectionCategory.AVATARS);
        }
      }
    });
  }

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
                        backgroundColor: Palette.purpleAccent.withValues(alpha: 0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Palette.purpleAccent.withValues(alpha: 0.2)),
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
                            // Only refresh collection for non-PIECES categories
                            // PIECES category uses assets directly, not backend
                            if (_tabs[index] != CollectionCategory.PIECES) {
                              ref
                                  .read(userCollectionControllerProvider.notifier)
                                  .refreshCollection(category: _tabs[index]);
                            }
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
        child: Skeleton(width: 40, height: 16, borderRadius: 4),
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

    // For PIECES category, show all available piece packs from assets
    if (currentCategory == CollectionCategory.PIECES) {
      return _buildPiecePacksGrid();
    }

    // For BOARDS category, show all available board themes
    if (currentCategory == CollectionCategory.BOARDS) {
      return _buildBoardThemesGrid();
    }

    // For AVATARS category, show all available avatars from assets
    if (currentCategory == CollectionCategory.AVATARS) {
      return _buildAvatarsGrid();
    }

    // For EFFECTS category, show all available effects
    if (currentCategory == CollectionCategory.EFFECTS) {
      return _buildEffectsGrid();
    }

    // For other categories, use the backend collection items
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
        loading: () => Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Palette.accent),
            ),
          ),
        ),
        error: (error, stack) => Center(
          child: Text(
            'Error loading items',
            style: TextStyle(color: Palette.error),
          ),
        ),
      ),
      loading: () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SkeletonGrid(
          itemCount: 6,
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          spacing: 16,
        ),
      ),
      error: (error, stack) => Center(
        child: Text(
          'Error loading collection',
          style: TextStyle(color: Palette.error),
        ),
      ),
    );
  }

  Widget _buildFeaturedSet(CollectionItem item, bool isEquipped) {
    final isAvatar = item.category == CollectionCategory.AVATARS;
    final avatarPath = isAvatar ? AvatarUtils.getAvatarImagePath(item.iconName) : null;

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
                      if (isEquipped) _buildBadge('Equipped', Palette.success),
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
                  backgroundColor: Colors.white.withValues(alpha: 0.05),
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
                  isAvatar && avatarPath != null
                      ? Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Palette.glassBorder, width: 2),
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              avatarPath,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildPiecePreview(
                                  CollectionUtils.getIconFromName(item.iconName),
                                  CollectionUtils.getColorFromHexOrRarity(
                                      item.colorHex, item.rarity),
                                  isLarge: true,
                                );
                              },
                            ),
                          ),
                        )
                      : _buildPiecePreview(
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
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2)),
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
            color.withValues(alpha: 0.2),
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
        border: Border(
          top: BorderSide(color: color.withValues(alpha: 0.2)),
          left: BorderSide(color: color.withValues(alpha: 0.2)),
          right: BorderSide(color: color.withValues(alpha: 0.2)),
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
          childAspectRatio: 0.85,
          children: [
            ...items.map((item) {
              final userItem = userCollectionMap[item.id];
              // For avatars with unlock_level 0, they are automatically available
              final isOwned = userItem?.isOwned ??
                  (item.category == CollectionCategory.AVATARS &&
                      (item.unlockLevel == null || item.unlockLevel == 0));
              final isEquipped = userItem?.isEquipped ?? false;
              // Only lock if unlock_level is set and > 0
              final isLocked = !isOwned && (item.unlockLevel != null && item.unlockLevel! > 0);

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
    // Make the whole card tappable for avatars
    final isAvatar = item.category == CollectionCategory.AVATARS;
    final color = CollectionUtils.getColorFromHexOrRarity(item.colorHex, item.rarity);
    final icon = CollectionUtils.getIconFromName(item.iconName);
    final rarityText = item.unlockLevel != null && isLocked
        ? 'Unlock at Lvl ${item.unlockLevel}'
        : CollectionUtils.getRarityDisplayName(item.rarity);

    // For avatars, use image instead of icon
    final avatarPath = isAvatar ? AvatarUtils.getAvatarImagePath(item.iconName) : null;

    final cardContent = Column(
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
                  child: isAvatar && avatarPath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            avatarPath,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                icon,
                                size: 48,
                                color: isLocked ? Palette.textTertiary : color,
                              );
                            },
                          ),
                        )
                      : Icon(
                          icon,
                          size: 48,
                          color: isLocked ? Palette.textTertiary : color,
                        ),
                ),
                if (isLocked)
                  Container(
                    color: Colors.black.withValues(alpha: 0.4),
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
                      : () async {
                          AppLogger.info('Equip item ${item.id}', tag: 'CollectionScreen');
                          try {
                            // For avatars, use equip-avatar-by-icon endpoint which handles auto-unlocking better
                            if (isAvatar && item.iconName != null) {
                              await ref
                                  .read(userCollectionControllerProvider.notifier)
                                  .equipAvatarByIcon(item.iconName!);
                            } else {
                              // For other items, use the standard equipItem endpoint
                              await ref
                                  .read(userCollectionControllerProvider.notifier)
                                  .equipItem(item.id, item.category);
                            }
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${item.name} equipped!'),
                                  backgroundColor: Palette.success,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to equip: $e'),
                                  backgroundColor: Palette.error,
                                ),
                              );
                            }
                          }
                        },
              icon: Icon(
                isLocked ? Icons.lock : (isEquipped ? Icons.check_circle : Icons.checkroom),
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
    );

    // Wrap in GestureDetector for avatars to make whole card tappable
    if (isAvatar && !isLocked) {
      return GestureDetector(
        onTap: () async {
          if (!isEquipped) {
            AppLogger.info('Equip avatar ${item.id} by tapping', tag: 'CollectionScreen');
            try {
              // For avatars, always use equip-avatar-by-icon endpoint which handles auto-unlocking better
              if (item.iconName != null) {
                await ref
                    .read(userCollectionControllerProvider.notifier)
                    .equipAvatarByIcon(item.iconName!);
              } else {
                // Fallback to equipItem if iconName is not available
                await ref
                    .read(userCollectionControllerProvider.notifier)
                    .equipItem(item.id, item.category);
              }
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${item.name} equipped!'),
                    backgroundColor: Palette.success,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to equip: $e'),
                    backgroundColor: Palette.error,
                  ),
                );
              }
            }
          }
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Palette.backgroundTertiary,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isEquipped ? Palette.success : Palette.glassBorder,
              width: isEquipped ? 2 : 1,
            ),
          ),
          child: cardContent,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Palette.backgroundTertiary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Palette.glassBorder),
      ),
      child: cardContent,
    );
  }

  Widget _buildShopCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Palette.purpleAccentDark.withValues(alpha: 0.5),
            Palette.purpleAccent.withValues(alpha: 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Palette.purpleAccent.withValues(alpha: 0.3)),
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
                  color: Palette.purpleAccent.withValues(alpha: 0.4),
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

  Widget _buildPiecePacksGrid() {
    final piecePacks = PiecePackUtils.getKnownPiecePacks();
    final settingsAsync = ref.watch(settingsControllerProvider);

    return settingsAsync.when(
      data: (settings) => SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Available Piece Sets (${piecePacks.length})',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Palette.textSecondary,
                  ),
                ),
                if (settings.pieceSet.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Palette.purpleAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Palette.purpleAccent.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      'Selected: ${PiecePackUtils.formatPackName(settings.pieceSet)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Palette.purpleAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemCount: piecePacks.length,
              itemBuilder: (context, index) {
                final packName = piecePacks[index];
                final isSelected = packName == settings.pieceSet;
                return _buildPiecePackCard(packName, isSelected: isSelected);
              },
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      loading: () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SkeletonGrid(
          itemCount: 6,
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          spacing: 16,
        ),
      ),
      error: (error, stack) => SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Text(
              'Available Piece Sets (${piecePacks.length})',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Palette.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Palette.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Palette.error),
              ),
              child: Text(
                'Error loading settings',
                style: TextStyle(color: Palette.error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPiecePackCard(String packName, {bool isSelected = false}) {
    final queenImagePath = PiecePackUtils.getQueenImagePath(packName, isWhite: true);

    return GestureDetector(
      onTap: () {
        // Show overlay with all pieces when clicking on the card
        showDialog(
          context: context,
          builder: (context) => PiecePackOverlay(packName: packName),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Palette.backgroundTertiary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Palette.purpleAccent : Palette.glassBorder,
            width: isSelected ? 2 : 1,
          ),
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
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Image.asset(
                          queenImagePath,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.extension,
                              size: 48,
                              color: Palette.textTertiary,
                            );
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isSelected)
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Palette.success,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Palette.success.withValues(alpha: 0.5),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.check,
                                size: 12,
                                color: Palette.textPrimary,
                              ),
                            ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () {
                              // Show overlay with all pieces
                              showDialog(
                                context: context,
                                builder: (context) => PiecePackOverlay(packName: packName),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Palette.backgroundTertiary.withValues(alpha: 0.8),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.visibility,
                                color: Palette.purpleAccent,
                                size: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              PiecePackUtils.formatPackName(packName),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? Palette.purpleAccent : Palette.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  // Save selected piece set to settings
                  AppLogger.info('Selecting piece set: $packName', tag: 'CollectionScreen');
                  try {
                    await ref.read(settingsControllerProvider.notifier).updatePieceSet(packName);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${PiecePackUtils.formatPackName(packName)} selected'),
                          backgroundColor: Palette.success,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  } catch (e) {
                    AppLogger.error('Error selecting piece set', tag: 'CollectionScreen', error: e);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to select piece set: $e'),
                          backgroundColor: Palette.error,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected ? Palette.purpleAccent : Palette.backgroundSecondary,
                  foregroundColor: isSelected ? Palette.textPrimary : Palette.textSecondary,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  isSelected ? 'Selected' : 'Select',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarsGrid() {
    final userCollectionAsync = ref.watch(userCollectionControllerProvider);
    final allItemsAsync = ref.watch(collectionControllerProvider);

    return userCollectionAsync.when(
      data: (userCollection) => allItemsAsync.when(
        data: (allItems) {
          // Get equipped avatar
          UserCollectionItem? equippedAvatar;
          try {
            equippedAvatar = userCollection.firstWhere(
              (uc) => uc.isEquipped && uc.item.category == CollectionCategory.AVATARS,
            );
          } catch (e) {
            equippedAvatar = null;
          }

          final equippedIconName = equippedAvatar?.item.iconName;
          final equippedIndex = AvatarUtils.getAvatarIndex(equippedIconName) ?? 1;

          // Create a map of avatar items by icon_name for quick lookup
          final avatarItemsMap = <String, CollectionItem>{};
          for (final item in allItems) {
            if (item.category == CollectionCategory.AVATARS && item.iconName != null) {
              avatarItemsMap[item.iconName!] = item;
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Available Avatars (20)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Palette.textSecondary,
                      ),
                    ),
                    if (equippedAvatar != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Palette.purpleAccent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Palette.purpleAccent.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          'Selected: ${equippedAvatar.item.name}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Palette.purpleAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: 20,
                  itemBuilder: (context, index) {
                    final avatarIndex = index + 1;
                    final iconName = AvatarUtils.getAvatarIconName(avatarIndex);
                    final avatarName = AvatarUtils.getAvatarName(avatarIndex);
                    final avatarPath = AvatarUtils.getAvatarImagePath(iconName);
                    final isSelected = equippedIndex == avatarIndex;
                    final avatarItem = avatarItemsMap[iconName];

                    return _buildAvatarCard(
                      avatarIndex: avatarIndex,
                      avatarName: avatarName,
                      avatarPath: avatarPath,
                      iconName: iconName,
                      isSelected: isSelected,
                      avatarItem: avatarItem,
                    );
                  },
                ),
                const SizedBox(height: 100),
              ],
            ),
          );
        },
        loading: () => Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Palette.accent),
            ),
          ),
        ),
        error: (error, stack) => SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Text(
                'Available Avatars (20)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Palette.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Palette.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Palette.error),
                ),
                child: Text(
                  'Error loading collection',
                  style: TextStyle(color: Palette.error),
                ),
              ),
            ],
          ),
        ),
      ),
      loading: () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SkeletonGrid(
          itemCount: 6,
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          spacing: 16,
        ),
      ),
      error: (error, stack) => SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Text(
              'Available Avatars (20)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Palette.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Palette.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Palette.error),
              ),
              child: Text(
                'Error loading collection',
                style: TextStyle(color: Palette.error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarCard({
    required int avatarIndex,
    required String avatarName,
    required String avatarPath,
    required String iconName,
    required bool isSelected,
    CollectionItem? avatarItem,
  }) {
    return Consumer(
      builder: (context, ref, child) => GestureDetector(
        onTap: () async {
          AppLogger.info('Selecting avatar $avatarIndex: $avatarName', tag: 'CollectionScreen');

          try {
            // Always use equip-avatar-by-icon for avatars - it handles auto-unlocking better
            // This endpoint is more lenient and will auto-create/equip avatars even if not owned
            await ref
                .read(userCollectionControllerProvider.notifier)
                .equipAvatarByIcon(iconName);

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$avatarName selected!'),
                  backgroundColor: Palette.success,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          } catch (e) {
            AppLogger.error('Error selecting avatar', tag: 'CollectionScreen', error: e);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to select avatar: $e'),
                  backgroundColor: Palette.error,
                ),
              );
            }
          }
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Palette.backgroundTertiary,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? Palette.success : Palette.glassBorder,
              width: isSelected ? 2 : 1,
            ),
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
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          avatarPath,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Palette.purpleAccent, Palette.purpleAccentDark],
                                ),
                              ),
                              child: Icon(
                                Icons.person,
                                color: Palette.textPrimary,
                                size: 48,
                              ),
                            );
                          },
                        ),
                      ),
                      if (isSelected)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Palette.success,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Palette.success.withValues(alpha: 0.5),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.check,
                              size: 12,
                              color: Palette.textPrimary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                avatarName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Palette.success : Palette.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'Avatar ${avatarIndex}',
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected ? Palette.success : Palette.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBoardThemesGrid() {
    final boardThemes = BoardThemeUtils.getKnownBoardThemes();
    final settingsAsync = ref.watch(settingsControllerProvider);

    return settingsAsync.when(
      data: (settings) => SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Available Board Themes (${boardThemes.length})',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Palette.textSecondary,
                  ),
                ),
                if (settings.boardTheme.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Palette.purpleAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Palette.purpleAccent.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      'Selected: ${BoardThemeUtils.formatThemeName(settings.boardTheme)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Palette.purpleAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: boardThemes.length,
              itemBuilder: (context, index) {
                final themeName = boardThemes[index];
                final isSelected = themeName == settings.boardTheme;
                return _buildBoardThemeCard(themeName, isSelected: isSelected);
              },
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      loading: () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SkeletonGrid(
          itemCount: 6,
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          spacing: 16,
        ),
      ),
      error: (error, stack) => SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Text(
              'Available Board Themes (${boardThemes.length})',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Palette.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Palette.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Palette.error),
              ),
              child: Text(
                'Error loading settings',
                style: TextStyle(color: Palette.error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoardThemeCard(String themeName, {bool isSelected = false}) {
    final lightColor = Color(BoardThemeUtils.getLightColor(themeName));
    final darkColor = Color(BoardThemeUtils.getDarkColor(themeName));

    return GestureDetector(
      onTap: () {
        // Show preview of the board theme
        showDialog(
          context: context,
          builder: (context) => _BoardThemePreviewDialog(themeName: themeName),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Palette.backgroundTertiary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Palette.purpleAccent : Palette.glassBorder,
            width: isSelected ? 2 : 1,
          ),
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
                    // Mini chess board preview (4x4 grid)
                    GridView.count(
                      crossAxisCount: 4,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: List.generate(16, (index) {
                        final row = index ~/ 4;
                        final col = index % 4;
                        final isLight = (row + col) % 2 == 0;
                        return Container(
                          decoration: BoxDecoration(
                            color: isLight ? lightColor : darkColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                      }),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isSelected)
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Palette.success,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Palette.success.withValues(alpha: 0.5),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.check,
                                size: 12,
                                color: Palette.textPrimary,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              BoardThemeUtils.formatThemeName(themeName),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? Palette.purpleAccent : Palette.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  // Save selected board theme to backend settings
                  AppLogger.info('Selecting board theme: $themeName', tag: 'CollectionScreen');
                  try {
                    await ref.read(settingsControllerProvider.notifier).updateBoardTheme(themeName);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              '${BoardThemeUtils.formatThemeName(themeName)} selected and saved'),
                          backgroundColor: Palette.success,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  } catch (e) {
                    AppLogger.error('Error selecting board theme',
                        tag: 'CollectionScreen', error: e);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to select board theme: $e'),
                          backgroundColor: Palette.error,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected ? Palette.purpleAccent : Palette.backgroundSecondary,
                  foregroundColor: isSelected ? Palette.textPrimary : Palette.textSecondary,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  isSelected ? 'Selected' : 'Select',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEffectsGrid() {
    final effects = EffectUtils.getKnownEffects();
    final settingsAsync = ref.watch(settingsControllerProvider);

    return settingsAsync.when(
      data: (settings) => SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Available Effects (${effects.length})',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Palette.textSecondary,
                  ),
                ),
                if (settings.effect != null && settings.effect!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Palette.purpleAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Palette.purpleAccent.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      'Selected: ${EffectUtils.formatEffectName(settings.effect!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Palette.purpleAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Palette.purpleAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Palette.purpleAccent.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      'Selected: Classic',
                      style: TextStyle(
                        fontSize: 12,
                        color: Palette.purpleAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: effects.length,
              itemBuilder: (context, index) {
                final effectName = effects[index];
                // Handle null effect - default to 'classic' if not set
                final currentEffect = settings.effect ?? 'classic';
                final isSelected = currentEffect == effectName;
                return _buildEffectCard(effectName, isSelected: isSelected);
              },
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      loading: () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SkeletonGrid(
          itemCount: 6,
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          spacing: 16,
        ),
      ),
      error: (error, stack) => SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Text(
              'Available Effects (${effects.length})',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Palette.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Palette.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Palette.error),
              ),
              child: Text(
                'Error loading settings',
                style: TextStyle(color: Palette.error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEffectCard(String effectName, {bool isSelected = false}) {
    final icon = EffectUtils.getEffectIcon(effectName);
    final color = EffectUtils.getEffectColor(effectName);
    final description = EffectUtils.getEffectDescription(effectName);
    final rarity = EffectUtils.getEffectRarity(effectName);

    return GestureDetector(
      onTap: () {
        // Show preview dialog
        showDialog(
          context: context,
          builder: (context) => _EffectPreviewDialog(effectName: effectName),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Palette.backgroundTertiary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Palette.glassBorder,
            width: isSelected ? 2 : 1,
          ),
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
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withValues(alpha: 0.3),
                      color.withValues(alpha: 0.1),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        icon,
                        size: 48,
                        color: color,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isSelected)
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Palette.success,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Palette.success.withValues(alpha: 0.5),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.check,
                                size: 12,
                                color: Palette.textPrimary,
                              ),
                            ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: CollectionUtils.getColorFromHexOrRarity(null, rarity).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: CollectionUtils.getColorFromHexOrRarity(null, rarity).withValues(alpha: 0.5),
                              ),
                            ),
                            child: Text(
                              CollectionUtils.getRarityDisplayName(rarity)[0],
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: CollectionUtils.getColorFromHexOrRarity(null, rarity),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              EffectUtils.formatEffectName(effectName),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? color : Palette.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 10,
                color: Palette.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  // Save selected effect to settings
                  AppLogger.info('Selecting effect: $effectName', tag: 'CollectionScreen');
                  try {
                    await ref.read(settingsControllerProvider.notifier).updateEffect(effectName);
                    // Refresh the collection to show updated selection
                    if (context.mounted) {
                      // The UI will automatically update because we're watching settingsControllerProvider
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${EffectUtils.formatEffectName(effectName)} selected'),
                          backgroundColor: Palette.success,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  } catch (e) {
                    AppLogger.error('Error selecting effect', tag: 'CollectionScreen', error: e);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to select effect: $e'),
                          backgroundColor: Palette.error,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected ? color : Palette.backgroundSecondary,
                  foregroundColor: isSelected ? Palette.textPrimary : Palette.textSecondary,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  isSelected ? 'Selected' : 'Select',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Effect preview dialog
class _EffectPreviewDialog extends ConsumerWidget {
  final String effectName;

  const _EffectPreviewDialog({required this.effectName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsControllerProvider);
    // Handle null effect - default to 'classic' if not set
    final currentEffect = settingsAsync.valueOrNull?.effect ?? 'classic';
    final isSelected = currentEffect == effectName;
    final icon = EffectUtils.getEffectIcon(effectName);
    final color = EffectUtils.getEffectColor(effectName);
    final description = EffectUtils.getEffectDescription(effectName);
    final rarity = EffectUtils.getEffectRarity(effectName);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: Palette.backgroundTertiary,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Palette.glassBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          EffectUtils.formatEffectName(effectName),
                          style: TextStyle(
                            fontSize: 20,
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
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: Palette.textSecondary),
                    style: IconButton.styleFrom(
                      backgroundColor: Palette.backgroundSecondary,
                      shape: const CircleBorder(),
                    ),
                  ),
                ],
              ),
            ),

            // Effect preview
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Palette.backgroundSecondary,
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withValues(alpha: 0.3),
                      color.withValues(alpha: 0.1),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: 80,
                    color: color,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Rarity info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: CollectionUtils.getColorFromHexOrRarity(null, rarity).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: CollectionUtils.getColorFromHexOrRarity(null, rarity).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.star,
                      size: 16,
                      color: CollectionUtils.getColorFromHexOrRarity(null, rarity),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      CollectionUtils.getRarityDisplayName(rarity),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: CollectionUtils.getColorFromHexOrRarity(null, rarity),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Select button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    AppLogger.info('Selecting effect from preview: $effectName',
                        tag: 'EffectPreview');
                    try {
                      await ref
                          .read(settingsControllerProvider.notifier)
                          .updateEffect(effectName);
                      if (context.mounted) {
                        Navigator.of(context).pop();
                        // The UI will automatically update because we're watching settingsControllerProvider
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${EffectUtils.formatEffectName(effectName)} selected'),
                            backgroundColor: Palette.success,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    } catch (e) {
                      AppLogger.error('Error selecting effect',
                          tag: 'EffectPreview', error: e);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to select effect: $e'),
                            backgroundColor: Palette.error,
                          ),
                        );
                      }
                    }
                  },
                  icon: Icon(
                    isSelected ? Icons.check_circle : Icons.check,
                    color: Palette.textPrimary,
                  ),
                  label: Text(
                    isSelected ? 'Currently Selected' : 'Select This Effect',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Palette.textPrimary,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected ? Palette.success : color,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// Board theme preview dialog
class _BoardThemePreviewDialog extends ConsumerWidget {
  final String themeName;

  const _BoardThemePreviewDialog({required this.themeName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsControllerProvider);
    final isSelected = settingsAsync.valueOrNull?.boardTheme == themeName;
    final lightColor = Color(BoardThemeUtils.getLightColor(themeName));
    final darkColor = Color(BoardThemeUtils.getDarkColor(themeName));

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: Palette.backgroundTertiary,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Palette.glassBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      BoardThemeUtils.formatThemeName(themeName),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Palette.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: Palette.textSecondary),
                    style: IconButton.styleFrom(
                      backgroundColor: Palette.backgroundSecondary,
                      shape: const CircleBorder(),
                    ),
                  ),
                ],
              ),
            ),

            // Board preview (8x8)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  color: Palette.backgroundSecondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: GridView.count(
                  crossAxisCount: 8,
                  physics: const NeverScrollableScrollPhysics(),
                  children: List.generate(64, (index) {
                    final row = index ~/ 8;
                    final col = index % 8;
                    final isLight = (row + col) % 2 == 0;
                    return Container(
                      decoration: BoxDecoration(
                        color: isLight ? lightColor : darkColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  }),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Color info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: lightColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Palette.glassBorder),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Light',
                        style: TextStyle(
                          fontSize: 12,
                          color: Palette.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: darkColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Palette.glassBorder),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Dark',
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

            const SizedBox(height: 20),

            // Select button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    AppLogger.info('Selecting board theme from preview: $themeName',
                        tag: 'BoardThemePreview');
                    try {
                      await ref
                          .read(settingsControllerProvider.notifier)
                          .updateBoardTheme(themeName);
                      if (context.mounted) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${BoardThemeUtils.formatThemeName(themeName)} selected'),
                            backgroundColor: Palette.success,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    } catch (e) {
                      AppLogger.error('Error selecting board theme',
                          tag: 'BoardThemePreview', error: e);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to select board theme: $e'),
                            backgroundColor: Palette.error,
                          ),
                        );
                      }
                    }
                  },
                  icon: Icon(
                    isSelected ? Icons.check_circle : Icons.check,
                    color: Palette.textPrimary,
                  ),
                  label: Text(
                    isSelected ? 'Currently Selected' : 'Select This Theme',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Palette.textPrimary,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected ? Palette.success : Palette.purpleAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
