class AvatarUtils {
  /// Get avatar image path from icon name
  /// icon_name format: "avatar_1", "avatar_2", etc.
  static String getAvatarImagePath(String? iconName) {
    if (iconName == null || !iconName.startsWith('avatar_')) {
      return 'assets/images/avatars/avatar_1.png'; // Default avatar
    }
    return 'assets/images/avatars/$iconName.png';
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

  /// Get default avatar path
  static String getDefaultAvatarPath() {
    return 'assets/images/avatars/avatar_1.png';
  }

  /// Get all available avatar paths (1-20)
  static List<String> getAllAvatarPaths() {
    return List.generate(20, (index) => 'assets/images/avatars/avatar_${index + 1}.png');
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
