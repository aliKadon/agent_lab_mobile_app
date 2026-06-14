import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AppLoader extends StatefulHookConsumerWidget {
  const AppLoader({super.key});

  @override
  ConsumerState<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends ConsumerState<AppLoader> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color loaderColor = Colors.black;
    return Center(
      child: CustomPaint(
        size: Size(45.w, 45.h), //! size of the loader
        painter: _RotatingArcPainter(_controller, loaderColor),
      ),
    );
  }
}

class _RotatingArcPainter extends CustomPainter {
  final Animation<double> animation;
  final Color loaderColor;

  _RotatingArcPainter(this.animation, this.loaderColor) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final Paint arcPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          loaderColor.withValues(alpha: 0.0),
          loaderColor.withValues(alpha: 0.4),
          loaderColor.withValues(alpha: 0.7),
          loaderColor,
          loaderColor.withValues(alpha: 0.0),
          loaderColor.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.2, 0.4, 0.6, 0.9, 1.0],
        transform: GradientRotation(animation.value * 2 * pi),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8 //! thickness of the loader
      ..strokeCap = StrokeCap.round;

    const arcLength = 0.7 * 2 * pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      animation.value * 2 * pi,
      arcLength,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
