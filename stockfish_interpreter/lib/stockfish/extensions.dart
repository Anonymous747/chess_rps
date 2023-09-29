extension MapExtension on Map {
  Map copy() {
    final temp = {};

    forEach((key, value) {
      temp.addAll({key: value});
    });

    return temp;
  }
}
