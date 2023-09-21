import 'package:flutter/material.dart';

const _borderWidth = 2.0;

class AnimatedBorder extends StatefulWidget {
  final Color beginColor;
  final Color endColor;
  final Color? backgroundColor;

  const AnimatedBorder({
    required this.beginColor,
    required this.endColor,
    this.backgroundColor,
    super.key,
  });

  @override
  AnimatedBorderState createState() => AnimatedBorderState();
}

class AnimatedBorderState extends State<AnimatedBorder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 500),
    vsync: this,
  )..repeat(reverse: true);

  late final Animation<Decoration> _animation = DecorationTween(
    begin: BoxDecoration(
      border: Border.all(color: widget.beginColor, width: _borderWidth),
      borderRadius: BorderRadius.circular(10.0),
    ),
    end: BoxDecoration(
      border: Border.all(color: widget.endColor, width: _borderWidth),
      borderRadius: BorderRadius.circular(10.0),
    ),
  ).animate(_controller);

  @override
  Widget build(BuildContext context) {
    return DecoratedBoxTransition(
      position: DecorationPosition.background,
      decoration: _animation,
      child: Container(
        margin: const EdgeInsets.all(_borderWidth),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: widget.backgroundColor,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }
}
