import 'package:chess_rps/common/asset_url.dart';

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

  /// Get the image URL for a queen piece in a specific pack
  static String getQueenImageUrl(String packName, {bool isWhite = true}) {
    final color = isWhite ? 'white' : 'black';
    return AssetUrl.getChessPieceUrl(packName, color, 'queen');
  }

  /// Get the image path for a queen piece in a specific pack (deprecated - use getQueenImageUrl)
  /// @deprecated Use getQueenImageUrl instead
  static String getQueenImagePath(String packName, {bool isWhite = true}) {
    return getQueenImageUrl(packName, isWhite: isWhite);
  }

  /// Get all piece image URLs for a pack
  static Map<String, String> getAllPieceImageUrls(String packName, {bool isWhite = true}) {
    final color = isWhite ? 'white' : 'black';
    return {
      'king': AssetUrl.getChessPieceUrl(packName, color, 'king'),
      'queen': AssetUrl.getChessPieceUrl(packName, color, 'queen'),
      'rook': AssetUrl.getChessPieceUrl(packName, color, 'rook'),
      'bishop': AssetUrl.getChessPieceUrl(packName, color, 'bishop'),
      'knight': AssetUrl.getChessPieceUrl(packName, color, 'knight'),
      'pawn': AssetUrl.getChessPieceUrl(packName, color, 'pawn'),
    };
  }

  /// Get all piece image paths for a pack (deprecated - use getAllPieceImageUrls)
  /// @deprecated Use getAllPieceImageUrls instead
  static Map<String, String> getAllPieceImages(String packName, {bool isWhite = true}) {
    return getAllPieceImageUrls(packName, isWhite: isWhite);
  }

  /// Format pack name for display (convert snake_case to Title Case)
  static String formatPackName(String packName) {
    return packName.split('_').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}
