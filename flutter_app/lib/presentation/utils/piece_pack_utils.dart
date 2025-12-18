class PiecePackUtils {
  /// List of known piece packs from assets
  static List<String> getKnownPiecePacks() {
    return _getKnownPiecePacks();
  }

  /// List of known piece packs from assets (internal)
  static List<String> _getKnownPiecePacks() {
      return [
        'ancient',
        'california',
        'cardinal',
        'celtic',
        'condal',
        'metal',
        'modern',
        'stone',
        'tournament',
        'vintage',
        'wood',
      ];
  }

  /// Get the image path for a queen piece in a specific pack
  static String getQueenImagePath(String packName, {bool isWhite = true}) {
    final color = isWhite ? 'white' : 'black';
    return 'assets/images/figures/$packName/$color/queen.png';
  }

  /// Get all piece image paths for a pack
  static Map<String, String> getAllPieceImages(String packName, {bool isWhite = true}) {
    final color = isWhite ? 'white' : 'black';
    return {
      'king': 'assets/images/figures/$packName/$color/king.png',
      'queen': 'assets/images/figures/$packName/$color/queen.png',
      'rook': 'assets/images/figures/$packName/$color/rook.png',
      'bishop': 'assets/images/figures/$packName/$color/bishop.png',
      'knight': 'assets/images/figures/$packName/$color/knight.png',
      'pawn': 'assets/images/figures/$packName/$color/pawn.png',
    };
  }

  /// Format pack name for display (convert snake_case to Title Case)
  static String formatPackName(String packName) {
    return packName.split('_').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}
