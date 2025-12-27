import 'endpoint.dart';

/// Utility class for building asset URLs from the backend
class AssetUrl {
  static String get _backendEndpoint => Endpoint.apiBase;

  /// Get the base URL for assets
  static String get baseUrl {
    return '$_backendEndpoint/api/v1/assets';
  }

  /// Build URL for chess piece image
  /// 
  /// [pieceSet] - The piece set name (e.g., 'cardinal', 'wood', 'modern')
  /// [color] - The piece color ('white' or 'black')
  /// [piece] - The piece type ('pawn', 'rook', 'knight', 'bishop', 'queen', 'king')
  static String getChessPieceUrl(String pieceSet, String color, String piece) {
    return '$baseUrl/figures/$pieceSet/$color/$piece';
  }

  /// Build URL for avatar image
  /// 
  /// [avatarName] - The avatar name (e.g., 'avatar_1.png', 'avatar_10.png')
  static String getAvatarUrl(String avatarName) {
    // Ensure .png extension
    final name = avatarName.endsWith('.png') ? avatarName : '$avatarName.png';
    return '$baseUrl/avatars/$name';
  }

  /// Build URL for splash screen image
  /// 
  /// [filename] - The splash image filename
  static String getSplashUrl(String filename) {
    return '$baseUrl/splash/$filename';
  }

  /// Get URL for chess piece with common piece names
  static String getPieceUrl(String pieceSet, String color, String pieceType) {
    // Convert common piece type names to lowercase
    final normalizedPiece = pieceType.toLowerCase();
    return getChessPieceUrl(pieceSet, color, normalizedPiece);
  }
}

