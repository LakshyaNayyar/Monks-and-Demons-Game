import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedWater extends StatefulWidget {
  final Color waterColor;
  final Color highlightColor;
  final double height;

  const AnimatedWater({
    super.key,
    required this.waterColor,
    required this.highlightColor,
    this.height = 120,
  });

  @override
  State<AnimatedWater> createState() => _AnimatedWaterState();
}

class _AnimatedWaterState extends State<AnimatedWater>
    with TickerProviderStateMixin {
  late AnimationController _waveController1;
  late AnimationController _waveController2;
  late AnimationController _waveController3;
  late AnimationController _bubbleController;

  @override
  void initState() {
    super.initState();
    _waveController1 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _waveController2 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    _waveController3 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    )..repeat();

    _bubbleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController1.dispose();
    _waveController2.dispose();
    _waveController3.dispose();
    _bubbleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          // Base water
          AnimatedBuilder(
            animation: _waveController1,
            builder: (_, __) => CustomPaint(
              painter: _WavePainter(
                progress: _waveController1.value,
                color: widget.waterColor,
                amplitude: 12,
                frequency: 1.5,
                phase: 0,
              ),
              child: const SizedBox.expand(),
            ),
          ),
          // Second wave layer
          AnimatedBuilder(
            animation: _waveController2,
            builder: (_, __) => CustomPaint(
              painter: _WavePainter(
                progress: _waveController2.value,
                color: widget.waterColor.withOpacity(0.6),
                amplitude: 8,
                frequency: 2.0,
                phase: pi,
              ),
              child: const SizedBox.expand(),
            ),
          ),
          // Highlight wave
          AnimatedBuilder(
            animation: _waveController3,
            builder: (_, __) => CustomPaint(
              painter: _WavePainter(
                progress: _waveController3.value,
                color: widget.highlightColor.withOpacity(0.3),
                amplitude: 5,
                frequency: 2.5,
                phase: pi / 2,
              ),
              child: const SizedBox.expand(),
            ),
          ),
          // Sparkle bubbles
          AnimatedBuilder(
            animation: _bubbleController,
            builder: (_, __) => CustomPaint(
              painter: _BubblePainter(
                progress: _bubbleController.value,
                color: widget.highlightColor,
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ],
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final double progress;
  final Color color;
  final double amplitude;
  final double frequency;
  final double phase;

  _WavePainter({
    required this.progress,
    required this.color,
    required this.amplitude,
    required this.frequency,
    required this.phase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);

    for (double x = 0; x <= size.width; x++) {
      final y = amplitude *
              sin((x / size.width * 2 * pi * frequency) +
                  (progress * 2 * pi) +
                  phase) +
          size.height * 0.25;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WavePainter old) => true;
}

class _BubblePainter extends CustomPainter {
  final double progress;
  final Color color;
  final Random _rng = Random(42);

  _BubblePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = 1.5;

    for (int i = 0; i < 8; i++) {
      final seed = i * 0.13;
      final x = _rng.nextDouble() * size.width;
      final baseY = size.height * 0.6 + _rng.nextDouble() * size.height * 0.3;
      final yOffset = ((progress + seed) % 1.0) * size.height * 0.8;
      final radius = 2.0 + _rng.nextDouble() * 4;
      final opacity = 1.0 - ((progress + seed) % 1.0);

      paint.color = color.withOpacity(opacity * 0.5);
      canvas.drawCircle(Offset(x, baseY - yOffset), radius, paint);
    }
  }

  @override
  bool shouldRepaint(_BubblePainter old) => true;
}