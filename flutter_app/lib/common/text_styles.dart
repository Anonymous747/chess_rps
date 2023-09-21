import 'package:chess_rps/common/palette.dart';
import 'package:flutter/material.dart';

class TextStyles {
  /// A size of textStyle is equel to some word:
  /// 10 - tiny
  /// 12 - small
  /// 14 - normal
  /// 16 - big
  /// 18 - huge
  /// other - irregular
  static _baseFont({
    FontWeight fontWeight = FontWeight.normal,
    FontStyle fontStyle = FontStyle.normal,
    Color color = Palette.black,
    double fontSize = 16,
    double? letterSpacing,
    TextOverflow? overflow,
    double? height,
  }) {
    return TextStyle(
      color: color,
      fontSize: fontSize,
      fontFamily: "Inter",
      fontStyle: fontStyle,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      overflow: overflow,
      height: height,
    );
  }

  /// FontSize = 10
  static regularTinyStyle({
    FontWeight fontWeight = FontWeight.normal,
    Color color = Palette.black,
    double? letterSpacing,
    TextOverflow? overflow,
    double? height,
  }) =>
      _baseFont(
        fontSize: 10,
        color: color,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        overflow: overflow,
        height: height,
      );

  /// FontSize = 12
  static regularSmallStyle({
    FontWeight fontWeight = FontWeight.normal,
    Color color = Palette.black,
    double? letterSpacing,
    TextOverflow? overflow,
    double? height,
  }) =>
      _baseFont(
        fontSize: 12,
        color: color,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        overflow: overflow,
        height: height,
      );

  /// FontSize = 14
  static regularNormalStyle({
    FontWeight fontWeight = FontWeight.normal,
    Color color = Palette.black,
    double? letterSpacing,
    TextOverflow? overflow,
    double? height,
  }) =>
      _baseFont(
        fontSize: 14,
        color: color,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        overflow: overflow,
        height: height,
      );

  /// FontSize = 16
  static regularBigStyle({
    FontWeight fontWeight = FontWeight.normal,
    Color color = Palette.black,
    double? letterSpacing,
    TextOverflow? overflow,
    double? height,
  }) =>
      _baseFont(
        fontSize: 16,
        color: color,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        overflow: overflow,
        height: height,
      );

  /// FontSize = 18
  static regularHugeStyle({
    FontWeight fontWeight = FontWeight.normal,
    Color color = Palette.black,
    double? letterSpacing,
    TextOverflow? overflow,
    double? height,
  }) =>
      _baseFont(
        fontSize: 18,
        color: color,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        overflow: overflow,
        height: height,
      );

  /// FontSize = any size
  static regularCustomSizeStyle({
    double fontSize = 20,
    FontWeight fontWeight = FontWeight.normal,
    Color color = Palette.black,
    double? letterSpacing,
    TextOverflow? overflow,
    double? height,
  }) =>
      _baseFont(
        fontSize: fontSize,
        color: color,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        overflow: overflow,
        height: height,
      );
}
