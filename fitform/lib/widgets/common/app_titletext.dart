import 'package:flutter/material.dart';

enum TitleTextStyle {
  display,
  headline,
  titleLarge,
  titleMedium,
  titleSmall,
  bodyLarge,
  bodyMedium,
  bodySmall,
}

class TitleText extends StatelessWidget {
  final String text;
  final TitleTextStyle style;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow overflow;

  const TitleText(
    this.text, {
    super.key,
    this.style = TitleTextStyle.titleMedium,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = _getTextStyle(context);

    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: textStyle,
    );
  }

  TextStyle _getTextStyle(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    switch (style) {
      case TitleTextStyle.display:
        return textTheme.displayLarge!;
      case TitleTextStyle.headline:
        return textTheme.headlineLarge!;
      case TitleTextStyle.titleLarge:
        return textTheme.titleLarge!;
      case TitleTextStyle.titleMedium:
        return textTheme.titleMedium!;
      case TitleTextStyle.titleSmall:
        return textTheme.titleSmall!;
      case TitleTextStyle.bodyLarge:
        return textTheme.bodyLarge!;
      case TitleTextStyle.bodyMedium:
        return textTheme.bodyMedium!;
      case TitleTextStyle.bodySmall:
        return textTheme.bodySmall!;
    }
  }
}