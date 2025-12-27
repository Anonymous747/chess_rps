import 'package:chess_rps/common/palette.dart';
import 'package:chess_rps/data/service/collection/collection_service.dart';
import 'package:flutter/material.dart';

/// Utility class for managing chess game effects
class EffectUtils {
  /// List of all available effects
  static const List<String> knownEffects = [
    'classic',
    'sparkle',
    'explosion',
    'teleport',
    'slide',
    'glow',
    'particles',
    'fire',
    'ice',
    'lightning',
    'magic',
    'rainbow',
    'shadow',
    'neon',
    'cosmic',
    'matrix',
    'golden',
    'diamond',
    'plasma',
    'void',
  ];

  /// Get all known effects
  static List<String> getKnownEffects() {
    return List.from(knownEffects);
  }

  /// Format effect name for display
  static String formatEffectName(String effect) {
    if (effect.isEmpty) return 'Classic';
    return effect.split('_').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Get icon for effect
  static IconData getEffectIcon(String effect) {
    switch (effect.toLowerCase()) {
      case 'classic':
        return Icons.casino;
      case 'sparkle':
        return Icons.auto_awesome;
      case 'explosion':
        return Icons.whatshot;
      case 'teleport':
        return Icons.flash_on;
      case 'slide':
        return Icons.swipe;
      case 'glow':
        return Icons.light_mode;
      case 'particles':
        return Icons.blur_on;
      case 'fire':
        return Icons.local_fire_department;
      case 'ice':
        return Icons.ac_unit;
      case 'lightning':
        return Icons.bolt;
      case 'magic':
        return Icons.auto_fix_high;
      case 'rainbow':
        return Icons.color_lens;
      case 'shadow':
        return Icons.dark_mode;
      case 'neon':
        return Icons.lightbulb;
      case 'cosmic':
        return Icons.stars;
      case 'matrix':
        return Icons.code;
      case 'golden':
        return Icons.workspace_premium;
      case 'diamond':
        return Icons.diamond;
      case 'plasma':
        return Icons.water_drop;
      case 'void':
        return Icons.space_dashboard;
      default:
        return Icons.extension;
    }
  }

  /// Get color for effect
  static Color getEffectColor(String effect) {
    switch (effect.toLowerCase()) {
      case 'classic':
        return Palette.textSecondary;
      case 'sparkle':
        return Palette.purpleAccent;
      case 'explosion':
        return Palette.error;
      case 'teleport':
        return Palette.accent;
      case 'slide':
        return Palette.success;
      case 'glow':
        return Colors.yellow;
      case 'particles':
        return Colors.cyan;
      case 'fire':
        return Colors.orange;
      case 'ice':
        return Colors.lightBlue;
      case 'lightning':
        return Colors.amber;
      case 'magic':
        return Colors.purple;
      case 'rainbow':
        return Colors.pink;
      case 'shadow':
        return Colors.grey;
      case 'neon':
        return Colors.lime;
      case 'cosmic':
        return Colors.deepPurple;
      case 'matrix':
        return Colors.green;
      case 'golden':
        return Colors.amber.shade700;
      case 'diamond':
        return Colors.blue;
      case 'plasma':
        return Colors.purple.shade300;
      case 'void':
        return Colors.black87;
      default:
        return Palette.textSecondary;
    }
  }

  /// Get description for effect
  static String getEffectDescription(String effect) {
    switch (effect.toLowerCase()) {
      case 'classic':
        return 'Standard chess move animation';
      case 'sparkle':
        return 'Sparkling particles on moves';
      case 'explosion':
        return 'Explosive capture effects';
      case 'teleport':
        return 'Instant teleportation moves';
      case 'slide':
        return 'Smooth sliding animations';
      case 'glow':
        return 'Glowing piece highlights';
      case 'particles':
        return 'Particle trail effects';
      case 'fire':
        return 'Fiery move animations';
      case 'ice':
        return 'Icy crystal effects';
      case 'lightning':
        return 'Lightning bolt moves';
      case 'magic':
        return 'Magical spell effects';
      case 'rainbow':
        return 'Rainbow colored moves';
      case 'shadow':
        return 'Dark shadow effects';
      case 'neon':
        return 'Neon glow animations';
      case 'cosmic':
        return 'Cosmic starfield effects';
      case 'matrix':
        return 'Matrix-style digital effects';
      case 'golden':
        return 'Golden shimmer effects';
      case 'diamond':
        return 'Diamond sparkle effects';
      case 'plasma':
        return 'Plasma energy effects';
      case 'void':
        return 'Void black hole effects';
      default:
        return 'Custom effect';
    }
  }

  /// Get rarity for effect
  static CollectionRarity getEffectRarity(String effect) {
    switch (effect.toLowerCase()) {
      case 'classic':
        return CollectionRarity.COMMON;
      case 'sparkle':
      case 'glow':
      case 'slide':
        return CollectionRarity.UNCOMMON;
      case 'particles':
      case 'fire':
      case 'ice':
      case 'lightning':
        return CollectionRarity.RARE;
      case 'magic':
      case 'rainbow':
      case 'neon':
      case 'cosmic':
        return CollectionRarity.EPIC;
      case 'explosion':
      case 'teleport':
      case 'matrix':
      case 'golden':
      case 'diamond':
      case 'plasma':
      case 'void':
        return CollectionRarity.LEGENDARY;
      default:
        return CollectionRarity.COMMON;
    }
  }
}

