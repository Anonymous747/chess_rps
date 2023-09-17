import 'package:chess_rps/common/palette.dart';
import 'package:chess_rps/common/text_styles.dart';
import 'package:flutter/material.dart';

class LettersCollection extends StatelessWidget {
  final List<String> letters;
  final double cellWidth;

  const LettersCollection({
    required this.letters,
    required this.cellWidth,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
          letters.length,
          (i) => SizedBox(
                width: cellWidth,
                child: Text(
                  letters[i],
                  textAlign: TextAlign.center,
                  style:
                      TextStyles.regularNormalStyle(color: Palette.yellow150),
                ),
              )),
    );
  }
}
