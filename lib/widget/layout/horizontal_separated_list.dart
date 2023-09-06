import 'package:flutter/material.dart';

class HorizontalSeparatedList extends StatelessWidget {
  final List<Widget> widgets;
  final double distanceBetween;
  final MainAxisAlignment mainAxisAlignment;

  const HorizontalSeparatedList({
    required this.widgets,
    this.distanceBetween = 10,
    this.mainAxisAlignment = MainAxisAlignment.start,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: mainAxisAlignment,
        children: widgets.fold(<Widget>[], (previousValue, child) {
          previousValue.add(child);
          if (widgets.indexOf(child) != widgets.length - 1) {
            previousValue.add(SizedBox(width: distanceBetween));
          }

          return previousValue;
        }));
  }
}
