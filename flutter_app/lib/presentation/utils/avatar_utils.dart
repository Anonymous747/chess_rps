import 'package:chess_rps/common/asset_url.dart';

class AvatarUtils {
  /// Get avatar image URL from icon name
  /// icon_name format: "avatar_1", "avatar_2", etc.
  static String getAvatarImageUrl(String? iconName) {
    if (iconName == null || !iconName.startsWith('avatar_')) {
      return AssetUrl.getAvatarUrl('avatar_1.png'); // Default avatar
    }
    return AssetUrl.getAvatarUrl('$iconName.png');
  }

  /// Get avatar image path from icon name (deprecated - use getAvatarImageUrl)
  /// @deprecated Use getAvatarImageUrl instead
  static String getAvatarImagePath(String? iconName) {
    return getAvatarImageUrl(iconName);
  }

  /// Get avatar index from icon name
  static int? getAvatarIndex(String? iconName) {
    if (iconName == null || !iconName.startsWith('avatar_')) {
      return 1;
    }
    try {
      final indexStr = iconName.replaceFirst('avatar_', '');
      return int.parse(indexStr);
    } catch (e) {
      return 1;
    }
  }

  /// Get default avatar URL
  static String getDefaultAvatarUrl() {
    return AssetUrl.getAvatarUrl('avatar_1.png');
  }

  /// Get default avatar path (deprecated - use getDefaultAvatarUrl)
  /// @deprecated Use getDefaultAvatarUrl instead
  static String getDefaultAvatarPath() {
    return getDefaultAvatarUrl();
  }

  /// Get all available avatar URLs (1-20)
  static List<String> getAllAvatarUrls() {
    return List.generate(20, (index) => AssetUrl.getAvatarUrl('avatar_${index + 1}.png'));
  }

  /// Get all available avatar paths (deprecated - use getAllAvatarUrls)
  /// @deprecated Use getAllAvatarUrls instead
  static List<String> getAllAvatarPaths() {
    return getAllAvatarUrls();
  }

  /// Get avatar icon name from index (1-20)
  static String getAvatarIconName(int index) {
    if (index < 1 || index > 20) return 'avatar_1';
    return 'avatar_$index';
  }

  /// Get avatar name from index
  static String getAvatarName(int index) {
    final names = [
      'Happy King',
      'Cool Dude',
      'Surprised Player',
      'Laughing Master',
      'Cool Strategist',
      'Happy Cat',
      'Excited Dog',
      'Friendly Bear',
      'Cute Rabbit',
      'Sleepy Panda',
      'Party Person',
      'Wise Owl',
      'Mischievous Monkey',
      'Chess Nerd',
      'Cunning Fox',
      'Epic Champion',
      'Friendly Dragon',
      'Mystical Wizard',
      'Magical Unicorn',
      'Legendary Master',
    ];
    if (index < 1 || index > 20) return names[0];
    return names[index - 1];
  }
}
