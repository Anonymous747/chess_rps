import 'package:chess_rps/common/palette.dart';
import 'package:flutter/material.dart';

class AnimatedBorder extends StatefulWidget {
  const AnimatedBorder({super.key});

  @override
  _AnimatedBorderState createState() => _AnimatedBorderState();
}

class _AnimatedBorderState extends State<AnimatedBorder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 500),
    vsync: this,
  )..repeat(reverse: true);

  late final Animation<Decoration> _animation = DecorationTween(
    begin: BoxDecoration(
      border: Border.all(color: Palette.white200, width: 2.0),
      borderRadius: BorderRadius.circular(10.0),
    ),
    end: BoxDecoration(
      border: Border.all(color: Colors.blue, width: 2.0),
      borderRadius: BorderRadius.circular(10.0),
    ),
  ).animate(_controller);

  @override
  Widget build(BuildContext context) {
    return DecoratedBoxTransition(
      position: DecorationPosition.background,
      decoration: _animation,
      child: const SizedBox.expand(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }
}
