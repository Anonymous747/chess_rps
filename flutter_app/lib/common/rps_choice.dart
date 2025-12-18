enum RpsChoice {
  rock,
  paper,
  scissors;

  String get displayName {
    switch (this) {
      case RpsChoice.rock:
        return 'Rock';
      case RpsChoice.paper:
        return 'Paper';
      case RpsChoice.scissors:
        return 'Scissors';
    }
  }

  /// Determines the winner between two RPS choices
  /// Returns: 1 if this choice wins, -1 if other wins, 0 if tie
  int compareTo(RpsChoice other) {
    if (this == other) return 0;

    switch (this) {
      case RpsChoice.rock:
        return other == RpsChoice.scissors ? 1 : -1;
      case RpsChoice.paper:
        return other == RpsChoice.rock ? 1 : -1;
      case RpsChoice.scissors:
        return other == RpsChoice.paper ? 1 : -1;
    }
  }

  /// Determines if this choice beats the other
  bool beats(RpsChoice other) {
    return compareTo(other) == 1;
  }
}







