import 'package:chess_rps/common/palette.dart';
import 'package:chess_rps/common/text_styles.dart';
import 'package:flutter/material.dart';

class NumbersColumn extends StatelessWidget {
  final List<String> letters;
  final double cellHeight;

  const NumbersColumn({
    required this.letters,
    required this.cellHeight,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
          letters.length,
          (i) => Container(
                alignment: Alignment.center,
                height: cellHeight,
                child: Text(
                  letters[i],
                  style:
                      TextStyles.regularNormalStyle(color: Palette.yellow150),
                ),
              )),
    );
  }
}
