import 'package:chess_rps/widget/custom/custom_gradient.dart';
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
      decoration: BoxDecoration(
          // color: isEven ? Colors.black38 : Colors.white12,
          borderRadius: BorderRadius.circular(4)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: CustomPaint(
          painter: CustomGradient(),
          child: Text('cell'),
        ),
      ),
    );
  }
}
