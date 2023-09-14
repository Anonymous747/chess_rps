import 'package:flutter/material.dart';

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
      border: Border.all(color: widget.beginColor, width: 2.0),
      borderRadius: BorderRadius.circular(10.0),
    ),
    end: BoxDecoration(
      border: Border.all(color: widget.endColor, width: 2.0),
      borderRadius: BorderRadius.circular(10.0),
    ),
  ).animate(_controller);

  @override
  Widget build(BuildContext context) {
    return DecoratedBoxTransition(
      position: DecorationPosition.background,
      decoration: _animation,
      child: Container(
        margin: EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
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
