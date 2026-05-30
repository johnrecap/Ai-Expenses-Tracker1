import 'package:flutter/material.dart';

/// {@template shimmer_gradient}
/// A smoothly animated shimmer gradient background that sweeps across the
/// widget area using a diagonal linear gradient.
///
/// Designed for 60fps performance using a single [AnimationController]
/// and [CustomPaint] to avoid rebuilding the entire subtree every frame.
/// {@endtemplate}
class ShimmerGradient extends StatefulWidget {
  /// {@macro shimmer_gradient}
  const ShimmerGradient({
    super.key,
    this.child,
    this.colors,
    this.duration = const Duration(milliseconds: 2500),
  });

  /// Optional widget layered on top of the shimmer background.
  final Widget? child;

  /// Gradient colors. Defaults to a deep-purple → teal → cyan futuristic set.
  final List<Color>? colors;

  /// Duration of one full shimmer sweep.
  final Duration duration;

  @override
  State<ShimmerGradient> createState() => _ShimmerGradientState();
}

class _ShimmerGradientState extends State<ShimmerGradient>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutSine,
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: _ShimmerPainter(
            progress: _animation.value,
            colors: widget.colors ??
                const [
                  Color(0xFF2D1B69), // deep purple
                  Color(0xFF006875), // teal
                  Color(0xFF00BCD4), // cyan
                  Color(0xFF2D1B69), // deep purple (loop)
                ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _ShimmerPainter extends CustomPainter {
  _ShimmerPainter({
    required this.progress,
    required this.colors,
  });

  final double progress;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    // Shift the gradient diagonally across the rect based on progress.
    final begin = Alignment(
      -1.0 + (progress * 2.0),
      -1.0 + (progress * 2.0),
    );
    final end = Alignment(
      -0.5 + (progress * 2.0),
      -0.5 + (progress * 2.0),
    );

    final gradient = LinearGradient(
      colors: colors,
      stops: _generateStops(colors.length),
      begin: begin,
      end: end,
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;

    canvas.drawRect(rect, paint);
  }

  List<double> _generateStops(int count) {
    if (count <= 1) return const [0.0];
    final step = 1.0 / (count - 1);
    return List.generate(count, (i) => i * step);
  }

  @override
  bool shouldRepaint(covariant _ShimmerPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.colors != colors;
  }
}
