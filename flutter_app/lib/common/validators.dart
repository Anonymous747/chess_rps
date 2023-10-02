extension StringValidations on String {
  bool get isNumber => RegExp('^[0-9]+\$').hasMatch(this);
}
