import 'package:flutter/material.dart';

class CustomSliderTrack extends RoundedRectSliderTrackShape {
  final double height;
  final double radius;

  CustomSliderTrack({this.height = 2, this.radius = 4}); // radius for corners

  @override
  void paint(
      PaintingContext context,
      Offset offset, {
        required RenderBox parentBox,
        required SliderThemeData sliderTheme,
        required Animation<double> enableAnimation,
        required Offset thumbCenter,
        bool isEnabled = false,
        bool isDiscrete = false,
        required TextDirection textDirection,
        Offset? secondaryOffset,
        double additionalActiveTrackHeight = 0,
      }) {
    final rect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    // Center our custom height vertically
    final trackRect = Rect.fromLTWH(
      rect.left,
      rect.top + (rect.height - height) / 2,
      rect.width,
      height,
    );

    final inactivePaint = Paint()..color = sliderTheme.inactiveTrackColor!;
    final activePaint = Paint()..color = sliderTheme.activeTrackColor!;

    // Draw inactive track
    context.canvas.drawRRect(
      RRect.fromRectAndRadius(trackRect, Radius.circular(radius)),
      inactivePaint,
    );

    // Draw active track (up to thumb)
    final activeRect = Rect.fromLTRB(
      trackRect.left,
      trackRect.top,
      thumbCenter.dx,
      trackRect.bottom,
    );

    context.canvas.drawRRect(
      RRect.fromRectAndRadius(activeRect, Radius.circular(radius)),
      activePaint,
    );
  }
}
