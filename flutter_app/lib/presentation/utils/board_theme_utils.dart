/// Utility class for managing chess board themes
class BoardThemeUtils {
  /// List of available board themes
  static List<String> getKnownBoardThemes() {
    return _getKnownBoardThemes();
  }

  /// List of available board themes (internal)
  static List<String> _getKnownBoardThemes() {
    return [
      'glass_dark',      // Default glass dark theme
      'classic_wood',    // Classic wood board
      'marble',          // Marble board
      'neon',            // Neon/cyberpunk theme
      'ocean',           // Ocean/water theme
      'forest',          // Forest/green theme
      'sunset',          // Sunset/orange theme
      'ice',             // Ice/frozen theme
      'metal',           // Metal/industrial theme
      'space',           // Space/galaxy theme
    ];
  }

  /// Format board theme name for display
  static String formatThemeName(String themeName) {
    return themeName.split('_').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Get light cell color for a theme
  static int getLightColor(String themeName) {
    switch (themeName) {
      case 'glass_dark':
        return 0xFFF5F5F5; // white100
      case 'classic_wood':
        return 0xFFD4A574; // Light wood
      case 'marble':
        return 0xFFE8E8E8; // Light marble
      case 'neon':
        return 0xFF00FFE5; // Cyan
      case 'ocean':
        return 0xFF87CEEB; // Sky blue
      case 'forest':
        return 0xFF90EE90; // Light green
      case 'sunset':
        return 0xFFFFB347; // Light orange
      case 'ice':
        return 0xFFE0F6FF; // Light blue
      case 'metal':
        return 0xFFC0C0C0; // Silver
      case 'space':
        return 0xFF9370DB; // Medium purple
      default:
        return 0xFFF5F5F5; // Default white
    }
  }

  /// Get dark cell color for a theme
  static int getDarkColor(String themeName) {
    switch (themeName) {
      case 'glass_dark':
        return 0xFF4A148C; // purple900
      case 'classic_wood':
        return 0xFF8B4513; // Saddle brown
      case 'marble':
        return 0xFF708090; // Slate gray
      case 'neon':
        return 0xFF8A2BE2; // Blue violet
      case 'ocean':
        return 0xFF1E90FF; // Dodger blue
      case 'forest':
        return 0xFF228B22; // Forest green
      case 'sunset':
        return 0xFFDC143C; // Crimson
      case 'ice':
        return 0xFF4682B4; // Steel blue
      case 'metal':
        return 0xFF696969; // Dim gray
      case 'space':
        return 0xFF191970; // Midnight blue
      default:
        return 0xFF4A148C; // Default purple
    }
  }

  /// Get color palette for light cells (array of colors for gradient)
  static List<int> getLightPalette(String themeName) {
    final baseLight = getLightColor(themeName);
    switch (themeName) {
      case 'glass_dark':
        return [0xFFFFFFFF, 0xFFF5F5F5, 0xFFE8E8E8, 0xFFE0E0E0, 0xFFD0D0D0];
      case 'classic_wood':
        return [
          _blendColor(baseLight, 0xFFFFFFFF, 0.2),
          _blendColor(baseLight, 0xFFFFFFFF, 0.1),
          baseLight,
          _blendColor(baseLight, 0xFF000000, 0.1),
          _blendColor(baseLight, 0xFF000000, 0.2),
        ];
      case 'marble':
        return [
          _blendColor(baseLight, 0xFFFFFFFF, 0.3),
          _blendColor(baseLight, 0xFFFFFFFF, 0.15),
          baseLight,
          _blendColor(baseLight, 0xFF000000, 0.1),
          _blendColor(baseLight, 0xFF000000, 0.2),
        ];
      case 'neon':
        return [
          _blendColor(baseLight, 0xFFFFFFFF, 0.5),
          baseLight,
          _blendColor(baseLight, 0xFF000000, 0.1),
          _blendColor(baseLight, 0xFF000000, 0.2),
          _blendColor(baseLight, 0xFF000000, 0.3),
        ];
      case 'ocean':
        return [
          _blendColor(baseLight, 0xFFFFFFFF, 0.3),
          baseLight,
          _blendColor(baseLight, 0xFF000000, 0.1),
          _blendColor(baseLight, 0xFF000000, 0.15),
          _blendColor(baseLight, 0xFF000000, 0.2),
        ];
      case 'forest':
        return [
          _blendColor(baseLight, 0xFFFFFFFF, 0.2),
          baseLight,
          _blendColor(baseLight, 0xFF000000, 0.1),
          _blendColor(baseLight, 0xFF000000, 0.15),
          _blendColor(baseLight, 0xFF000000, 0.25),
        ];
      case 'sunset':
        return [
          _blendColor(baseLight, 0xFFFFD700, 0.3),
          baseLight,
          _blendColor(baseLight, 0xFF000000, 0.1),
          _blendColor(baseLight, 0xFF000000, 0.15),
          _blendColor(baseLight, 0xFF000000, 0.2),
        ];
      case 'ice':
        return [
          _blendColor(baseLight, 0xFFFFFFFF, 0.4),
          baseLight,
          _blendColor(baseLight, 0xFF000000, 0.05),
          _blendColor(baseLight, 0xFF000000, 0.1),
          _blendColor(baseLight, 0xFF000000, 0.15),
        ];
      case 'metal':
        return [
          _blendColor(baseLight, 0xFFFFFFFF, 0.5),
          baseLight,
          _blendColor(baseLight, 0xFF000000, 0.2),
          _blendColor(baseLight, 0xFF000000, 0.3),
          _blendColor(baseLight, 0xFF000000, 0.4),
        ];
      case 'space':
        return [
          _blendColor(baseLight, 0xFFFFFFFF, 0.3),
          baseLight,
          _blendColor(baseLight, 0xFF000000, 0.2),
          _blendColor(baseLight, 0xFF000000, 0.3),
          _blendColor(baseLight, 0xFF000000, 0.4),
        ];
      default:
        return [0xFFFFFFFF, 0xFFF5F5F5, 0xFFE8E8E8, 0xFFE0E0E0, 0xFFD0D0D0];
    }
  }

  /// Get color palette for dark cells (array of colors for gradient)
  static List<int> getDarkPalette(String themeName) {
    final baseDark = getDarkColor(themeName);
    switch (themeName) {
      case 'glass_dark':
        return [0xFF7B1FA2, 0xFF6A1B9A, 0xFF4A148C, 0xFF38006B, 0xFF2D0055];
      case 'classic_wood':
        return [
          _blendColor(baseDark, 0xFFFFFFFF, 0.15),
          _blendColor(baseDark, 0xFFFFFFFF, 0.08),
          baseDark,
          _blendColor(baseDark, 0xFF000000, 0.2),
          _blendColor(baseDark, 0xFF000000, 0.35),
        ];
      case 'marble':
        return [
          _blendColor(baseDark, 0xFFFFFFFF, 0.2),
          _blendColor(baseDark, 0xFFFFFFFF, 0.1),
          baseDark,
          _blendColor(baseDark, 0xFF000000, 0.2),
          _blendColor(baseDark, 0xFF000000, 0.3),
        ];
      case 'neon':
        return [
          _blendColor(baseDark, 0xFFFFFFFF, 0.3),
          baseDark,
          _blendColor(baseDark, 0xFF000000, 0.2),
          _blendColor(baseDark, 0xFF000000, 0.35),
          _blendColor(baseDark, 0xFF000000, 0.5),
        ];
      case 'ocean':
        return [
          _blendColor(baseDark, 0xFFFFFFFF, 0.2),
          baseDark,
          _blendColor(baseDark, 0xFF000000, 0.25),
          _blendColor(baseDark, 0xFF000000, 0.35),
          _blendColor(baseDark, 0xFF000000, 0.45),
        ];
      case 'forest':
        return [
          _blendColor(baseDark, 0xFFFFFFFF, 0.15),
          baseDark,
          _blendColor(baseDark, 0xFF000000, 0.25),
          _blendColor(baseDark, 0xFF000000, 0.35),
          _blendColor(baseDark, 0xFF000000, 0.45),
        ];
      case 'sunset':
        return [
          _blendColor(baseDark, 0xFFFFD700, 0.2),
          baseDark,
          _blendColor(baseDark, 0xFF000000, 0.25),
          _blendColor(baseDark, 0xFF000000, 0.35),
          _blendColor(baseDark, 0xFF000000, 0.45),
        ];
      case 'ice':
        return [
          _blendColor(baseDark, 0xFFFFFFFF, 0.3),
          baseDark,
          _blendColor(baseDark, 0xFF000000, 0.2),
          _blendColor(baseDark, 0xFF000000, 0.3),
          _blendColor(baseDark, 0xFF000000, 0.4),
        ];
      case 'metal':
        return [
          _blendColor(baseDark, 0xFFFFFFFF, 0.25),
          baseDark,
          _blendColor(baseDark, 0xFF000000, 0.3),
          _blendColor(baseDark, 0xFF000000, 0.4),
          _blendColor(baseDark, 0xFF000000, 0.5),
        ];
      case 'space':
        return [
          _blendColor(baseDark, 0xFFFFFFFF, 0.2),
          baseDark,
          _blendColor(baseDark, 0xFF000000, 0.3),
          _blendColor(baseDark, 0xFF000000, 0.4),
          _blendColor(baseDark, 0xFF000000, 0.55),
        ];
      default:
        return [0xFF7B1FA2, 0xFF6A1B9A, 0xFF4A148C, 0xFF38006B, 0xFF2D0055];
    }
  }

  /// Blend two colors with a factor (0.0 = color1, 1.0 = color2)
  static int _blendColor(int color1, int color2, double factor) {
    final r1 = (color1 >> 16) & 0xFF;
    final g1 = (color1 >> 8) & 0xFF;
    final b1 = color1 & 0xFF;
    
    final r2 = (color2 >> 16) & 0xFF;
    final g2 = (color2 >> 8) & 0xFF;
    final b2 = color2 & 0xFF;
    
    final r = ((r1 * (1 - factor) + r2 * factor)).round().clamp(0, 255);
    final g = ((g1 * (1 - factor) + g2 * factor)).round().clamp(0, 255);
    final b = ((b1 * (1 - factor) + b2 * factor)).round().clamp(0, 255);
    
    return (0xFF << 24) | (r << 16) | (g << 8) | b;
  }
}




