import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

class ConditionalMarqueeText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final double width;
  final double? velocity;
  final int? noOfRounds;
  final Duration startAfter;

  const ConditionalMarqueeText({
    super.key,
    required this.text,
    required this.style,
    required this.width,
    this.noOfRounds,
    this.velocity,
    this.startAfter = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Measure the width of the text
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);

    final textWidth = textPainter.width;

    if (textWidth > width) {
      return SizedBox(
        width: width,
        height: style.fontSize != null ? style.fontSize! * 1.2 : 20,
        child: Marquee(
          text: text,
          style: style,
          scrollAxis: Axis.horizontal,
          numberOfRounds: noOfRounds,
          blankSpace: 20.0,
          velocity: velocity ?? 20.0,
          startAfter: startAfter,
        ),
      );
    } else {
      return SizedBox(
        width: width,
        child: Text(
          text,
          style: style,
          maxLines: 1,
          overflow: TextOverflow.clip,
        ),
      );
    }
  }
}
