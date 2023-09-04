import 'package:flutter/material.dart';

class CellWidget extends StatelessWidget {
  final bool isEven;

  const CellWidget({
    required this.isEven,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isEven ? Colors.black38 : Colors.white12,
      child: Text('cell'),
    );
  }
}
