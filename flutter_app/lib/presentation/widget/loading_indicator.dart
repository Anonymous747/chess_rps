import 'package:chess_rps/common/palette.dart';
import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final String? message;
  final double? size;

  const LoadingIndicator({
    Key? key,
    this.message,
    this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size ?? 40,
          height: size ?? 40,
          child: const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Palette.white),
            strokeWidth: 3,
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 12),
          Text(
            message!,
            style: TextStyle(
              color: Palette.white,
              fontSize: size != null ? size! * 0.4 : 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}







