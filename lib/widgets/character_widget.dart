import 'package:flutter/material.dart';

enum CharacterType { monk, demon }

class CharacterWidget extends StatefulWidget {
  final CharacterType type;
  final Color color;
  final bool isJumping;
  final VoidCallback? onTap;
  final double size;

  const CharacterWidget({
    super.key,
    required this.type,
    required this.color,
    this.isJumping = false,
    this.onTap,
    this.size = 44,
  });

  @override
  State<CharacterWidget> createState() => _CharacterWidgetState();
}

class _CharacterWidgetState extends State<CharacterWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _jumpAnim;
  late Animation<double> _rotateAnim;
  bool _localJumping = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _jumpAnim = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -40.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: -40.0, end: 0.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _rotateAnim = Tween<double>(begin: 0, end: 2 * 3.14159).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _localJumping = false);
        widget.onTap?.call();
      }
    });
  }

  @override
  void didUpdateWidget(CharacterWidget old) {
    super.didUpdateWidget(old);
    if (widget.isJumping && !old.isJumping) {
      _triggerJump();
    }
  }

  void _triggerJump() {
    if (_localJumping) return;
    setState(() => _localJumping = true);
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _localJumping ? null : _triggerJump,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, child) => Transform.translate(
          offset: Offset(0, _jumpAnim.value),
          child: Transform.rotate(
            angle: _rotateAnim.value,
            child: child,
          ),
        ),
        child: CustomPaint(
          size: Size(widget.size, widget.size),
          painter: widget.type == CharacterType.monk
              ? _MonkPainter(widget.color)
              : _DemonPainter(widget.color),
        ),
      ),
    );
  }
}

class _MonkPainter extends CustomPainter {
  final Color color;
  _MonkPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final s = size.width;

    // Robe body
    paint.color = color;
    final robePath = Path();
    robePath.moveTo(s * 0.2, s * 0.45);
    robePath.lineTo(s * 0.1, s);
    robePath.lineTo(s * 0.9, s);
    robePath.lineTo(s * 0.8, s * 0.45);
    robePath.close();
    canvas.drawPath(robePath, paint);

    // Robe belt
    paint.color = color.withOpacity(0.6);
    canvas.drawRect(Rect.fromLTWH(s * 0.15, s * 0.58, s * 0.7, s * 0.07), paint);

    // Arms
    paint.color = color.withOpacity(0.8);
    // left arm
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(s * 0.02, s * 0.42, s * 0.18, s * 0.28),
            Radius.circular(s * 0.05)),
        paint);
    // right arm
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(s * 0.8, s * 0.42, s * 0.18, s * 0.28),
            Radius.circular(s * 0.05)),
        paint);

    // Head (skin tone)
    paint.color = const Color(0xFFFFCC99);
    canvas.drawOval(
        Rect.fromLTWH(s * 0.28, s * 0.06, s * 0.44, s * 0.38), paint);

    // Eyes
    paint.color = Colors.black;
    canvas.drawCircle(Offset(s * 0.38, s * 0.21), s * 0.04, paint);
    canvas.drawCircle(Offset(s * 0.62, s * 0.21), s * 0.04, paint);

    // Smile
    final smileyPath = Path();
    smileyPath.moveTo(s * 0.38, s * 0.3);
    smileyPath.quadraticBezierTo(s * 0.5, s * 0.38, s * 0.62, s * 0.3);
    final smilePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(smileyPath, smilePaint);

    // Monk top (head wrap)
    paint.color = color.withOpacity(0.7);
    canvas.drawOval(
        Rect.fromLTWH(s * 0.27, s * 0.04, s * 0.46, s * 0.16), paint);
  }

  @override
  bool shouldRepaint(_MonkPainter old) => old.color != color;
}

class _DemonPainter extends CustomPainter {
  final Color color;
  _DemonPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final s = size.width;

    // Body
    paint.color = color;
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(s * 0.15, s * 0.42, s * 0.7, s * 0.55),
            Radius.circular(s * 0.08)),
        paint);

    // Arms (wider, more menacing)
    paint.color = color.withOpacity(0.85);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(0, s * 0.4, s * 0.18, s * 0.35),
            Radius.circular(s * 0.04)),
        paint);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(s * 0.82, s * 0.4, s * 0.18, s * 0.35),
            Radius.circular(s * 0.04)),
        paint);

    // Claws
    paint.color = color.withRed((color.red + 40).clamp(0, 255));
    for (int i = 0; i < 3; i++) {
      final cx = s * (0.01 + i * 0.07);
      canvas.drawOval(Rect.fromLTWH(cx, s * 0.73, s * 0.06, s * 0.09), paint);
    }
    for (int i = 0; i < 3; i++) {
      final cx = s * (0.83 + i * 0.07);
      canvas.drawOval(Rect.fromLTWH(cx, s * 0.73, s * 0.06, s * 0.09), paint);
    }

    // Head
    paint.color = color;
    canvas.drawOval(
        Rect.fromLTWH(s * 0.18, s * 0.04, s * 0.64, s * 0.44), paint);

    // Horns
    paint.color = color.withRed((color.red + 60).clamp(0, 255));
    final horn1 = Path();
    horn1.moveTo(s * 0.28, s * 0.1);
    horn1.lineTo(s * 0.22, 0);
    horn1.lineTo(s * 0.34, s * 0.08);
    horn1.close();
    canvas.drawPath(horn1, paint);

    final horn2 = Path();
    horn2.moveTo(s * 0.72, s * 0.1);
    horn2.lineTo(s * 0.78, 0);
    horn2.lineTo(s * 0.66, s * 0.08);
    horn2.close();
    canvas.drawPath(horn2, paint);

    // Eyes (glowing red)
    paint.color = Colors.red.shade900;
    canvas.drawOval(Rect.fromLTWH(s * 0.3, s * 0.19, s * 0.14, s * 0.1), paint);
    canvas.drawOval(Rect.fromLTWH(s * 0.56, s * 0.19, s * 0.14, s * 0.1), paint);

    // Eye highlight
    paint.color = Colors.orange;
    canvas.drawCircle(Offset(s * 0.37, s * 0.22), s * 0.03, paint);
    canvas.drawCircle(Offset(s * 0.63, s * 0.22), s * 0.03, paint);

    // Menacing mouth
    final mouthPath = Path();
    mouthPath.moveTo(s * 0.3, s * 0.35);
    mouthPath.lineTo(s * 0.35, s * 0.41);
    mouthPath.lineTo(s * 0.42, s * 0.36);
    mouthPath.lineTo(s * 0.5, s * 0.42);
    mouthPath.lineTo(s * 0.58, s * 0.36);
    mouthPath.lineTo(s * 0.65, s * 0.41);
    mouthPath.lineTo(s * 0.7, s * 0.35);
    final mouthPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(mouthPath, mouthPaint);
  }

  @override
  bool shouldRepaint(_DemonPainter old) => old.color != color;
}