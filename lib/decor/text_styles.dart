import 'package:flutter/material.dart';
import 'package:rPiInterface/decor/default_colors.dart';

class MyTextStyle extends TextStyle {
  final Color color;
  final FontWeight fontWeight;
  final String fontFamily;
  final double fontSize;
  final double letterSpacing;
  final TextDecoration decoration;
  final FontStyle fontStyle;

  const MyTextStyle({
    this.color = DefaultColors.textColorOnDark,
    this.fontStyle,
    this.decoration,
    this.fontWeight,
    this.letterSpacing = 1,
    this.fontSize = 16,
    this.fontFamily = 'Hind',
  }) : super(
          color: color,
          fontWeight: fontWeight,
          fontSize: fontSize,
          fontFamily: fontFamily,
          letterSpacing: letterSpacing,
          decoration: decoration,
          fontStyle: fontStyle,
        );
}
