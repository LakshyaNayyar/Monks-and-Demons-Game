import 'dart:math';
import 'package:flutter/material.dart';

class BoatWidget extends StatefulWidget {
  final Color boatColor;
  final bool isMoving;
  final bool onRight;
  final int monks;
  final int demons;
  final Color monkColor;
  final Color demonColor;
  final VoidCallback? onAddMonk;
  final VoidCallback? onAddDemon;
  final VoidCallback? onRemoveMonk;
  final VoidCallback? onRemoveDemon;

  const BoatWidget({
    super.key,
    required this.boatColor,
    required this.isMoving,
    required this.onRight,
    required this.monks,
    required this.demons,
    required this.monkColor,
    required this.demonColor,
    this.onAddMonk,
    this.onAddDemon,
    this.onRemoveMonk,
    this.onRemoveDemon,
  });

  @override
  State<BoatWidget> createState() => _BoatWidgetState();
}

class _BoatWidgetState extends State<BoatWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _rockController;
  late Animation<double> _rockAnim;
  late Animation<double> _moveAnim;

  @override
  void initState() {
    super.initState();
    _rockController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _rockAnim = Tween<double>(begin: -0.04, end: 0.04).animate(
      CurvedAnimation(parent: _rockController, curve: Curves.easeInOut),
    );

    _moveAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _rockController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _rockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _rockController,
      builder: (_, child) => Transform.rotate(
        angle: widget.isMoving ? sin(_rockController.value * 2 * pi) * 0.08 : _rockAnim.value,
        child: child,
      ),
      child: _buildBoat(),
    );
  }

  Widget _buildBoat() {
    return Container(
      width: 120,
      height: 65,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Boat hull
          CustomPaint(
            size: const Size(120, 55),
            painter: _BoatPainter(widget.boatColor),
          ),
          // Passengers inside boat
          Positioned(
            top: 4,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Monks in boat
                for (int i = 0; i < widget.monks; i++)
                  GestureDetector(
                    onTap: widget.onRemoveMonk,
                    child: _miniCharacter(widget.monkColor, isMonk: true),
                  ),
                // Demons in boat
                for (int i = 0; i < widget.demons; i++)
                  GestureDetector(
                    onTap: widget.onRemoveDemon,
                    child: _miniCharacter(widget.demonColor, isMonk: false),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniCharacter(Color color, {required bool isMonk}) {
    return Container(
      width: 22,
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: CustomPaint(
        painter: isMonk
            ? _MiniMonkPainter(color)
            : _MiniDemonPainter(color),
      ),
    );
  }
}

class _BoatPainter extends CustomPainter {
  final Color color;
  _BoatPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Shadow
    paint.color = Colors.black26;
    final shadow = Path();
    shadow.moveTo(4, size.height * 0.5 + 4);
    shadow.quadraticBezierTo(
        size.width / 2, size.height + 8, size.width - 4, size.height * 0.5 + 4);
    shadow.lineTo(size.width - 4, size.height * 0.4);
    shadow.lineTo(4, size.height * 0.4);
    shadow.close();
    canvas.drawPath(shadow, paint);

    // Boat body
    paint.color = color;
    final boatPath = Path();
    boatPath.moveTo(4, size.height * 0.4);
    boatPath.lineTo(size.width - 4, size.height * 0.4);
    boatPath.quadraticBezierTo(
        size.width - 2, size.height * 0.7, size.width * 0.5, size.height);
    boatPath.quadraticBezierTo(2, size.height * 0.7, 4, size.height * 0.4);
    canvas.drawPath(boatPath, paint);

    // Boat rim
    paint.color = color.withOpacity(0.6);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3;
    canvas.drawPath(boatPath, paint);

    // Inner boat deck
    paint.style = PaintingStyle.fill;
    paint.color = color.withOpacity(0.3);
    final deckPath = Path();
    deckPath.moveTo(10, size.height * 0.42);
    deckPath.lineTo(size.width - 10, size.height * 0.42);
    deckPath.quadraticBezierTo(
        size.width - 8, size.height * 0.65, size.width * 0.5, size.height * 0.82);
    deckPath.quadraticBezierTo(8, size.height * 0.65, 10, size.height * 0.42);
    canvas.drawPath(deckPath, paint);

    // Plank lines
    final plankPaint = Paint()
      ..color = color.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (int i = 1; i < 3; i++) {
      canvas.drawLine(Offset(size.width * (0.2 + i * 0.2), size.height * 0.43),
          Offset(size.width * (0.15 + i * 0.22), size.height * 0.75), plankPaint);
    }
  }

  @override
  bool shouldRepaint(_BoatPainter old) => old.color != color;
}

class _MiniMonkPainter extends CustomPainter {
  final Color color;
  _MiniMonkPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final s = size.shortestSide;
    paint.color = color;
    // robe
    canvas.drawRect(Rect.fromLTWH(s * 0.15, s * 0.45, s * 0.7, s * 0.55), paint);
    // head
    paint.color = const Color(0xFFFFCC99);
    canvas.drawOval(Rect.fromLTWH(s * 0.25, s * 0.05, s * 0.5, s * 0.42), paint);
  }

  @override
  bool shouldRepaint(_) => true;
}

class _MiniDemonPainter extends CustomPainter {
  final Color color;
  _MiniDemonPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final s = size.shortestSide;
    paint.color = color;
    // body
    canvas.drawRect(Rect.fromLTWH(s * 0.1, s * 0.42, s * 0.8, s * 0.58), paint);
    // head
    canvas.drawOval(Rect.fromLTWH(s * 0.2, s * 0.05, s * 0.6, s * 0.42), paint);
    // horns
    final h = Path();
    h.moveTo(s * 0.25, s * 0.1);
    h.lineTo(s * 0.2, 0);
    h.lineTo(s * 0.33, s * 0.09);
    h.close();
    canvas.drawPath(h, paint);
    final h2 = Path();
    h2.moveTo(s * 0.75, s * 0.1);
    h2.lineTo(s * 0.8, 0);
    h2.lineTo(s * 0.67, s * 0.09);
    h2.close();
    canvas.drawPath(h2, paint);
    // eyes
    paint.color = Colors.red;
    canvas.drawCircle(Offset(s * 0.36, s * 0.24), s * 0.06, paint);
    canvas.drawCircle(Offset(s * 0.64, s * 0.24), s * 0.06, paint);
  }

  @override
  bool shouldRepaint(_) => true;
}