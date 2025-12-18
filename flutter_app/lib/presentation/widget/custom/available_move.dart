import 'package:chess_rps/common/palette.dart';
import 'package:flutter/material.dart';

class AvailableMove extends StatelessWidget {
  final bool isAvailable;

  const AvailableMove({
    required this.isAvailable,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: isAvailable ? constraints.maxWidth * 0.2 : 0,
        height: isAvailable ? constraints.maxWidth * 0.2 : 0,
        decoration: BoxDecoration(
          color: Palette.purple400,
          borderRadius: BorderRadius.circular(constraints.maxWidth),
          boxShadow: [
            BoxShadow(
              color: Palette.purple400.withOpacity(0.5),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
      );
    });
  }
}
