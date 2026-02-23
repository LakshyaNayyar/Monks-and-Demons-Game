import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_water.dart';
import 'game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _fadeAnim =
        CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(builder: (context, provider, _) {
      final theme = provider.theme;
      return Scaffold(
        backgroundColor: theme.background,
        body: Stack(
          children: [
            // Sky
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [theme.sky, theme.background],
                ),
              ),
            ),

            // Water at bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AnimatedWater(
                waterColor: theme.water,
                highlightColor: theme.waterHighlight,
                height: 180,
              ),
            ),

            // Main content
            FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Title
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [theme.demonColor, theme.monkColor],
                        ).createShader(bounds),
                        child: Text(
                          'MONKS\n& DEMONS',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 52,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 4,
                            height: 1.1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'The Classic River Crossing Puzzle',
                        style: TextStyle(
                          color: theme.textColor.withOpacity(0.7),
                          fontSize: 14,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Characters preview
                      _CharacterPreview(theme: theme),

                      const SizedBox(height: 48),

                      // Play button
                      ElevatedButton(
                        onPressed: () => Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, a, __) => const GameScreen(),
                            transitionsBuilder: (_, anim, __, child) =>
                                FadeTransition(opacity: anim, child: child),
                            transitionDuration:
                                const Duration(milliseconds: 600),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.buttonColor,
                          foregroundColor: theme.buttonText,
                          elevation: 12,
                          shadowColor: theme.buttonColor.withOpacity(0.6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 60, vertical: 18),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                        child: Text(
                          'PLAY',
                          style: TextStyle(
                            color: theme.buttonText,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 6,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Theme switcher
                      Text('Choose Theme:',
                          style: TextStyle(
                              color: theme.textColor.withOpacity(0.6),
                              fontSize: 13)),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: AppThemeMode.values.map((m) {
                          final t = AppTheme.of(m);
                          return GestureDetector(
                            onTap: () => provider.setTheme(m),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 6),
                              width: provider.themeMode == m ? 48 : 38,
                              height: provider.themeMode == m ? 48 : 38,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: t.buttonColor,
                                border: provider.themeMode == m
                                    ? Border.all(
                                        color: theme.textColor, width: 3)
                                    : null,
                                boxShadow: [
                                  BoxShadow(
                                    color: t.buttonColor.withOpacity(0.5),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  t.name[0],
                                  style: TextStyle(
                                    color: t.buttonText,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _CharacterPreview extends StatefulWidget {
  final AppTheme theme;
  const _CharacterPreview({required this.theme});

  @override
  State<_CharacterPreview> createState() => _CharacterPreviewState();
}

class _CharacterPreviewState extends State<_CharacterPreview>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _jump;
  late Animation<double> _rotate;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: false);

    _jump = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -30.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: -30.0, end: 0.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

    _rotate = Tween<double>(begin: 0, end: 2 * pi).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < 3; i++)
          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, child) => Transform.translate(
              offset: Offset(0, _jump.value * ((i % 2 == 0) ? 1 : -1)),
              child: child,
            ),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              child: CustomPaint(
                size: const Size(40, 40),
                painter: _MonkPreview(widget.theme.monkColor),
              ),
            ),
          ),
        const SizedBox(width: 20),
        for (int i = 0; i < 3; i++)
          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, child) => Transform.translate(
              offset: Offset(0, _jump.value * ((i % 2 == 0) ? -1 : 1)),
              child: child,
            ),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              child: CustomPaint(
                size: const Size(40, 40),
                painter: _DemonPreview(widget.theme.demonColor),
              ),
            ),
          ),
      ],
    );
  }
}

class _MonkPreview extends CustomPainter {
  final Color color;
  _MonkPreview(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final s = size.width;
    paint.color = color;
    canvas.drawRect(Rect.fromLTWH(s * 0.2, s * 0.45, s * 0.6, s * 0.55), paint);
    paint.color = const Color(0xFFFFCC99);
    canvas.drawOval(Rect.fromLTWH(s * 0.28, s * 0.06, s * 0.44, s * 0.4), paint);
    paint.color = color.withOpacity(0.7);
    canvas.drawOval(Rect.fromLTWH(s * 0.27, s * 0.04, s * 0.46, s * 0.16), paint);
    paint.color = Colors.black;
    canvas.drawCircle(Offset(s * 0.38, s * 0.21), s * 0.04, paint);
    canvas.drawCircle(Offset(s * 0.62, s * 0.21), s * 0.04, paint);
  }

  @override
  bool shouldRepaint(_) => true;
}

class _DemonPreview extends CustomPainter {
  final Color color;
  _DemonPreview(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final s = size.width;
    paint.color = color;
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(s * 0.15, s * 0.42, s * 0.7, s * 0.55),
            Radius.circular(s * 0.08)),
        paint);
    canvas.drawOval(Rect.fromLTWH(s * 0.18, s * 0.04, s * 0.64, s * 0.44), paint);
    // horns
    final h = Path()
      ..moveTo(s * 0.28, s * 0.1)
      ..lineTo(s * 0.22, 0)
      ..lineTo(s * 0.34, s * 0.08)
      ..close();
    canvas.drawPath(h, paint);
    final h2 = Path()
      ..moveTo(s * 0.72, s * 0.1)
      ..lineTo(s * 0.78, 0)
      ..lineTo(s * 0.66, s * 0.08)
      ..close();
    canvas.drawPath(h2, paint);
    paint.color = Colors.red;
    canvas.drawCircle(Offset(s * 0.37, s * 0.24), s * 0.07, paint);
    canvas.drawCircle(Offset(s * 0.63, s * 0.24), s * 0.07, paint);
  }

  @override
  bool shouldRepaint(_) => true;
}