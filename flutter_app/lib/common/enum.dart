const String _blackSide = 'black';
const String _whiteSide = 'white';

enum Side {
  light,
  dark;

  @override
  String toString() {
    return this == Side.dark ? _blackSide : _whiteSide;
  }

  Side get opposite => this == Side.dark ? Side.light : Side.dark;
  bool get isLight => this == Side.light;
}

enum Role {
  pawn,
  rook,
  knight,
  bishop,
  queen,
  king,
}
