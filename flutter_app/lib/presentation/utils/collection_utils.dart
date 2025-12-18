import 'package:chess_rps/common/palette.dart';
import 'package:chess_rps/data/service/collection/collection_service.dart';
import 'package:flutter/material.dart';

class CollectionUtils {
  /// Map icon name to IconData
  static IconData getIconFromName(String? iconName) {
    if (iconName == null) return Icons.extension;
    
    // Map common icon names to Material icons
    switch (iconName.toLowerCase()) {
      case 'star':
      case 'star_outline':
        return Icons.star;
      case 'circle':
      case 'circle_outline':
        return Icons.circle;
      case 'square':
      case 'square_outline':
        return Icons.square;
      case 'extension':
      case 'extension_outline':
        return Icons.extension;
      case 'workspace_premium':
        return Icons.workspace_premium;
      case 'trip_origin':
        return Icons.trip_origin;
      case 'diamond':
        return Icons.diamond;
      case 'favorite':
        return Icons.favorite;
      default:
        return Icons.extension;
    }
  }

  /// Get color from hex string or rarity
  static Color getColorFromHexOrRarity(String? colorHex, CollectionRarity rarity) {
    if (colorHex != null && colorHex.isNotEmpty) {
      try {
        // Remove # if present and parse hex
        final hex = colorHex.replaceFirst('#', '');
        return Color(int.parse('FF$hex', radix: 16));
      } catch (e) {
        // If parsing fails, use rarity color
      }
    }
    
    // Default colors based on rarity
    switch (rarity) {
      case CollectionRarity.COMMON:
        return Palette.textSecondary;
      case CollectionRarity.UNCOMMON:
        return Palette.success;
      case CollectionRarity.RARE:
        return Palette.accent;
      case CollectionRarity.EPIC:
        return Palette.purpleAccent;
      case CollectionRarity.LEGENDARY:
        return Palette.gold;
    }
  }

  /// Get rarity display name
  static String getRarityDisplayName(CollectionRarity rarity) {
    switch (rarity) {
      case CollectionRarity.COMMON:
        return 'Common';
      case CollectionRarity.UNCOMMON:
        return 'Uncommon';
      case CollectionRarity.RARE:
        return 'Rare';
      case CollectionRarity.EPIC:
        return 'Epic';
      case CollectionRarity.LEGENDARY:
        return 'Legendary';
    }
  }

  /// Check if item is locked based on unlock level
  static bool isItemLocked(CollectionItem item, int? userLevel) {
    if (item.unlockLevel == null) return false;
    if (userLevel == null) return true;
    return userLevel < item.unlockLevel!;
  }
}

