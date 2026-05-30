import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// {@template floating_particles}
/// Animated floating particles that drift across the background.
///
/// Uses [CustomPaint] with a [Ticker] to drive 60fps particle updates
/// without rebuilding the widget tree.
/// {@endtemplate}
class FloatingParticles extends StatefulWidget {
  /// {@macro floating_particles}
  const FloatingParticles({
    super.key,
    this.particleCount = 30,
    this.colors,
    this.minRadius = 1.0,
    this.maxRadius = 3.5,
    this.speedMultiplier = 0.4,
  });

  /// Number of particles to render.
  final int particleCount;

  /// Particle colors. Defaults to futuristic cyan/teal/purple tints.
  final List<Color>? colors;

  /// Minimum particle radius.
  final double minRadius;

  /// Maximum particle radius.
  final double maxRadius;

  /// Speed multiplier for particle drift.
  final double speedMultiplier;

  @override
  State<FloatingParticles> createState() => _FloatingParticlesState();
}

class _FloatingParticlesState extends State<FloatingParticles>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final List<_Particle> _particles = [];
  final Random _random = Random();
  double _elapsed = 0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      setState(() {
        _elapsed = elapsed.inMilliseconds / 1000.0;
      });
    });
    _ticker.start();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_particles.isEmpty) {
      final size = MediaQuery.sizeOf(context);
      _particles.addAll(
        List.generate(
          widget.particleCount,
          (_) => _Particle.random(
            bounds: size,
            random: _random,
            colors: widget.colors ??
                const [
                  Color(0x6600E5FF), // cyan tint
                  Color(0x4400BCD4), // teal tint
                  Color(0x556833EA), // purple tint
                  Color(0x33FFFFFF), // white shimmer
                ],
            minRadius: widget.minRadius,
            maxRadius: widget.maxRadius,
            speedMultiplier: widget.speedMultiplier,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ParticlesPainter(
        particles: _particles,
        elapsed: _elapsed,
      ),
      size: Size.infinite,
    );
  }
}

class _Particle {
  _Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.color,
    required this.speedX,
    required this.speedY,
    required this.phase,
    required this.bounds,
  });

  factory _Particle.random({
    required Size bounds,
    required Random random,
    required List<Color> colors,
    required double minRadius,
    required double maxRadius,
    required double speedMultiplier,
  }) {
    return _Particle(
      x: random.nextDouble() * bounds.width,
      y: random.nextDouble() * bounds.height,
      radius: minRadius + random.nextDouble() * (maxRadius - minRadius),
      color: colors[random.nextInt(colors.length)],
      speedX: (random.nextDouble() - 0.5) * 20 * speedMultiplier,
      speedY: (random.nextDouble() - 0.5) * 15 * speedMultiplier,
      phase: random.nextDouble() * 2 * pi,
      bounds: bounds,
    );
  }

  double x;
  double y;
  final double radius;
  final Color color;
  final double speedX;
  final double speedY;
  final double phase;
  final Size bounds;

  void update(double elapsed) {
    x += speedX * 0.016;
    y += speedY * 0.016 + sin(elapsed + phase) * 0.3;

    // Wrap around edges
    if (x < -10) x = bounds.width + 10;
    if (x > bounds.width + 10) x = -10;
    if (y < -10) y = bounds.height + 10;
    if (y > bounds.height + 10) y = -10;
  }
}

class _ParticlesPainter extends CustomPainter {
  _ParticlesPainter({
    required this.particles,
    required this.elapsed,
  });

  final List<_Particle> particles;
  final double elapsed;

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      particle.update(elapsed);
      final paint = Paint()
        ..color = particle.color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(particle.x, particle.y), particle.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlesPainter oldDelegate) {
    return true;
  }
}
