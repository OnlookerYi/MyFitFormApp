import 'package:flutter/material.dart';

class TitleText extends StatelessWidget {
  final String text;
  final double size;
  final FontWeight weight;
  final Color color;
  final TextAlign align;
  final double height;
  final double letterSpacing;
  final String? fontFamily; // ✅ 字体样式
  final int? maxLines;
  final TextOverflow overflow;

  const TitleText(
    this.text, {
    super.key,
    this.size = 20,
    this.weight = FontWeight.bold,
    this.color = Colors.black,
    this.align = TextAlign.start,
    this.height = 1.4,
    this.letterSpacing = 0,
    this.fontFamily,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: align,
      maxLines: maxLines,
      overflow: overflow,
      style: TextStyle(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
        fontFamily: fontFamily, // ✅ 应用字体
      ),
    );
  }
}