import 'package:flutter/material.dart';

/// {@template pulse_animation}
/// A reusable pulse animation widget that scales and fades a child
/// in a rhythmic loop. Ideal for action buttons, indicators, and
/// attention-grabbing UI elements.
///
/// Uses a single [AnimationController] for 60fps smoothness.
/// {@endtemplate}
class PulseAnimation extends StatefulWidget {
  /// {@macro pulse_animation}
  const PulseAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.minScale = 1.0,
    this.maxScale = 1.08,
    this.minOpacity = 0.85,
    this.maxOpacity = 1.0,
    this.delay = Duration.zero,
  });

  /// The widget to pulse.
  final Widget child;

  /// Duration of one full pulse cycle.
  final Duration duration;

  /// Minimum scale during the pulse.
  final double minScale;

  /// Maximum scale during the pulse.
  final double maxScale;

  /// Minimum opacity during the pulse.
  final double minOpacity;

  /// Maximum opacity during the pulse.
  final double maxOpacity;

  /// Optional delay before the pulse starts.
  final Duration delay;

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _scaleAnimation = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutSine,
      ),
    );

    _opacityAnimation = Tween<double>(
      begin: widget.minOpacity,
      end: widget.maxOpacity,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutSine,
      ),
    );

    if (widget.delay == Duration.zero) {
      _controller.repeat(reverse: true);
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) {
          _controller.repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
