import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/game_model.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_water.dart';
import '../widgets/boat_widget.dart';
import '../widgets/character_widget.dart';
import 'analysis_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with TickerProviderStateMixin {
  late AnimationController _boatMoveController;
  late Animation<double> _boatPositionAnim;
  bool _boatOnRight = false;

  @override
  void initState() {
    super.initState();
    _boatMoveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _boatPositionAnim = CurvedAnimation(
      parent: _boatMoveController,
      curve: Curves.easeInOut,
    );
    _boatMoveController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _boatOnRight = !_boatOnRight);
        _boatMoveController.reset();
      }
    });
  }

  @override
  void dispose() {
    _boatMoveController.dispose();
    super.dispose();
  }

  void _handleGo(GameProvider provider) async {
    final prevSide = provider.model.boatSide;
    await provider.go();
    if (provider.model.boatSide != prevSide) {
      _boatMoveController.forward(from: 0);
    }
    if (provider.model.isGameOver) {
      _showGameOverDialog(provider);
    }
  }

  void _showGameOverDialog(GameProvider provider) {
    final theme = provider.theme;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: theme.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          provider.model.isWon ? '🎉 Victory!' : '💀 Game Over',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: theme.textColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              provider.model.isWon
                  ? 'All monks and demons crossed safely!\nTime: ${provider.timerDisplay}\nMoves: ${provider.model.moveHistory.length}'
                  : 'Demons outnumbered the monks!\nThe monks were eaten! 😱',
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.textColor),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.buttonColor,
                    foregroundColor: theme.buttonText,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    provider.reset();
                    setState(() => _boatOnRight = false);
                  },
                  child: const Text('Play Again'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.buttonColor.withOpacity(0.6),
                    foregroundColor: theme.buttonText,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const AnalysisScreen()));
                  },
                  child: const Text('Analysis'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, provider, _) {
        final theme = provider.theme;
        final model = provider.model;
        final isLeft = model.boatSide == Side.left;

        return Scaffold(
          backgroundColor: theme.background,
          body: SafeArea(
            child: Stack(
              children: [
                // Sky background
                Positioned.fill(
                  child: _SkyBackground(theme: theme),
                ),

                Column(
                  children: [
                    // Top bar
                    _TopBar(provider: provider, theme: theme),
                    const SizedBox(height: 8),

                    // Game title
                    Text(
                      'Monks & Demons',
                      style: TextStyle(
                        color: theme.textColor,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        shadows: [
                          Shadow(
                            color: theme.buttonColor.withOpacity(0.5),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Message banner
                    if (provider.message != null)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 14),
                        decoration: BoxDecoration(
                          color: theme.buttonColor.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          provider.message!,
                          style: TextStyle(
                              color: theme.buttonText,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    const Spacer(),

                    // Main game area
                    _GameArea(
                      provider: provider,
                      theme: theme,
                      model: model,
                      boatPositionAnim: _boatPositionAnim,
                      boatOnRight: _boatOnRight,
                    ),

                    const Spacer(),

                    // Controls
                    _ControlPanel(
                      provider: provider,
                      theme: theme,
                      onGo: () => _handleGo(provider),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SkyBackground extends StatefulWidget {
  final AppTheme theme;
  const _SkyBackground({required this.theme});

  @override
  State<_SkyBackground> createState() => _SkyBackgroundState();
}

class _SkyBackgroundState extends State<_SkyBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => CustomPaint(
        painter: _SkyPainter(widget.theme, _ctrl.value),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _SkyPainter extends CustomPainter {
  final AppTheme theme;
  final double progress;
  _SkyPainter(this.theme, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Sky gradient
    paint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        theme.sky,
        theme.sky.withOpacity(0.5),
      ],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Clouds / stars depending on theme
    final rng = Random(12);
    paint.shader = null;

    if (theme.mode == AppThemeMode.neon || theme.mode == AppThemeMode.dark) {
      // Stars
      paint.color = Colors.white;
      for (int i = 0; i < 30; i++) {
        final x = rng.nextDouble() * size.width;
        final y = rng.nextDouble() * size.height * 0.45;
        final twinkle = sin((progress + i * 0.1) * 2 * pi) * 0.5 + 0.5;
        paint.color = Colors.white.withOpacity(0.3 + twinkle * 0.7);
        canvas.drawCircle(Offset(x, y), rng.nextDouble() * 2 + 0.5, paint);
      }
      if (theme.mode == AppThemeMode.neon) {
        // Neon aurora
        paint.shader = LinearGradient(
          colors: [
            Colors.transparent,
            Colors.cyan.withOpacity(0.1),
            Colors.transparent,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).createShader(Rect.fromLTWH(0, size.height * 0.1, size.width, size.height * 0.3));
        canvas.drawRect(
            Rect.fromLTWH(0, size.height * 0.1, size.width, size.height * 0.3), paint);
        paint.shader = null;
      }
    } else {
      // Clouds for light/pink
      paint.color = Colors.white.withOpacity(0.7);
      for (int i = 0; i < 3; i++) {
        final baseX = (progress * size.width * 0.3 + i * size.width * 0.35) % (size.width + 60) - 30;
        final baseY = size.height * (0.05 + i * 0.06);
        _drawCloud(canvas, paint, Offset(baseX, baseY), 30.0 + i * 10);
      }
    }
  }

  void _drawCloud(Canvas canvas, Paint paint, Offset center, double r) {
    canvas.drawCircle(center, r, paint);
    canvas.drawCircle(center + Offset(r * 0.6, r * 0.2), r * 0.7, paint);
    canvas.drawCircle(center - Offset(r * 0.6, r * 0.1), r * 0.7, paint);
    canvas.drawCircle(center + Offset(0, r * 0.3), r * 0.8, paint);
  }

  @override
  bool shouldRepaint(_SkyPainter old) => old.progress != progress;
}

class _GameArea extends StatelessWidget {
  final GameProvider provider;
  final AppTheme theme;
  final GameModel model;
  final Animation<double> boatPositionAnim;
  final bool boatOnRight;

  const _GameArea({
    required this.provider,
    required this.theme,
    required this.model,
    required this.boatPositionAnim,
    required this.boatOnRight,
  });

  @override
  Widget build(BuildContext context) {
    final isLeft = model.boatSide == Side.left;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          // Characters row
          SizedBox(
            height: 100,
            child: Row(
              children: [
                // Left bank
                Expanded(
                  child: _BankSection(
                    monks: model.leftMonks,
                    demons: model.leftDemons,
                    theme: theme,
                    isBoatHere: isLeft,
                    onTapMonk: provider.addMonkToBoat,
                    onTapDemon: provider.addDemonToBoat,
                    label: 'Start',
                  ),
                ),
                // River + Boat
                SizedBox(
                  width: 140,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Boat animated position
                      AnimatedBuilder(
                        animation: boatPositionAnim,
                        builder: (_, child) {
                          final progress = boatOnRight
                              ? 1.0 - boatPositionAnim.value
                              : boatPositionAnim.value;
                          final leftPercent = isLeft
                              ? (provider.isAnimating ? progress : 0.0)
                              : (provider.isAnimating ? 1.0 - progress : 1.0);
                          return Positioned(
                            left: leftPercent * 20,
                            right: (1 - leftPercent) * 20,
                            child: child!,
                          );
                        },
                        child: BoatWidget(
                          boatColor: theme.boat,
                          isMoving: provider.isAnimating,
                          onRight: !isLeft,
                          monks: model.boatMonks,
                          demons: model.boatDemons,
                          monkColor: theme.monkColor,
                          demonColor: theme.demonColor,
                          onRemoveMonk: provider.removeMonkFromBoat,
                          onRemoveDemon: provider.removeDemonFromBoat,
                        ),
                      ),
                    ],
                  ),
                ),
                // Right bank
                Expanded(
                  child: _BankSection(
                    monks: model.rightMonks,
                    demons: model.rightDemons,
                    theme: theme,
                    isBoatHere: !isLeft,
                    onTapMonk: provider.addMonkToBoat,
                    onTapDemon: provider.addDemonToBoat,
                    label: 'Goal',
                    isRight: true,
                  ),
                ),
              ],
            ),
          ),

          // Animated Water
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AnimatedWater(
              waterColor: theme.water,
              highlightColor: theme.waterHighlight,
              height: 90,
            ),
          ),

          const SizedBox(height: 8),

          // Boat count info
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
            decoration: BoxDecoration(
              color: theme.buttonColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Boat: ${model.boatMonks} monk(s) + ${model.boatDemons} demon(s) | Capacity: 2',
              style: TextStyle(
                color: theme.textColor,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BankSection extends StatelessWidget {
  final int monks;
  final int demons;
  final AppTheme theme;
  final bool isBoatHere;
  final VoidCallback onTapMonk;
  final VoidCallback onTapDemon;
  final String label;
  final bool isRight;

  const _BankSection({
    required this.monks,
    required this.demons,
    required this.theme,
    required this.isBoatHere,
    required this.onTapMonk,
    required this.onTapDemon,
    required this.label,
    this.isRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.buttonColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: isBoatHere
            ? Border.all(color: theme.buttonColor, width: 2)
            : null,
      ),
      padding: const EdgeInsets.all(4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: TextStyle(
                  color: theme.textColor.withOpacity(0.6), fontSize: 9)),
          // Monks row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < monks; i++)
                GestureDetector(
                  onTap: isBoatHere ? onTapMonk : null,
                  child: CharacterWidget(
                    type: CharacterType.monk,
                    color: theme.monkColor,
                    size: 30,
                  ),
                ),
            ],
          ),
          // Demons row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < demons; i++)
                GestureDetector(
                  onTap: isBoatHere ? onTapDemon : null,
                  child: CharacterWidget(
                    type: CharacterType.demon,
                    color: theme.demonColor,
                    size: 30,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ControlPanel extends StatelessWidget {
  final GameProvider provider;
  final AppTheme theme;
  final VoidCallback onGo;

  const _ControlPanel({
    required this.provider,
    required this.theme,
    required this.onGo,
  });

  @override
  Widget build(BuildContext context) {
    final model = provider.model;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Add/Remove buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ActionButton(
                label: '+ Monk',
                color: theme.monkColor,
                textColor: Colors.black87,
                onTap: provider.addMonkToBoat,
                icon: Icons.person,
              ),
              // GO Button (elevated)
              ElevatedButton.icon(
                onPressed: provider.isAnimating || model.isGameOver ? null : onGo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.buttonColor,
                  foregroundColor: theme.buttonText,
                  elevation: 8,
                  shadowColor: theme.buttonColor.withOpacity(0.6),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                icon: Icon(Icons.sailing, color: theme.buttonText),
                label: Text(
                  'GO',
                  style: TextStyle(
                    color: theme.buttonText,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
              _ActionButton(
                label: '+ Demon',
                color: theme.demonColor,
                textColor: Colors.white,
                onTap: provider.addDemonToBoat,
                icon: Icons.face,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ActionButton(
                label: '- Monk',
                color: theme.monkColor.withOpacity(0.5),
                textColor: Colors.black87,
                onTap: provider.removeMonkFromBoat,
                icon: Icons.remove,
              ),
              ElevatedButton.icon(
                onPressed: model.isGameOver ? () {
                  provider.reset();
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.refresh),
                label: const Text('Reset'),
              ),
              _ActionButton(
                label: '- Demon',
                color: theme.demonColor.withOpacity(0.5),
                textColor: Colors.white,
                onTap: provider.removeDemonFromBoat,
                icon: Icons.remove,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;
  final IconData icon;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.textColor,
    required this.onTap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 6,
                offset: const Offset(0, 3))
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: textColor, size: 16),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    color: textColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final GameProvider provider;
  final AppTheme theme;

  const _TopBar({required this.provider, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          // Theme selector
          PopupMenuButton<AppThemeMode>(
            icon: Icon(Icons.palette, color: theme.textColor),
            color: theme.background,
            onSelected: provider.setTheme,
            itemBuilder: (_) => AppThemeMode.values
                .map((m) => PopupMenuItem(
                      value: m,
                      child: Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: AppTheme.of(m).buttonColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(AppTheme.of(m).name,
                              style: TextStyle(color: theme.textColor)),
                        ],
                      ),
                    ))
                .toList(),
          ),
          // Analysis
          IconButton(
            icon: Icon(Icons.bar_chart, color: theme.textColor),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AnalysisScreen()),
            ),
          ),
          const Spacer(),
          // Timer
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.timerBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.timer, color: theme.buttonText, size: 16),
                const SizedBox(width: 6),
                Text(
                  provider.timerDisplay,
                  style: TextStyle(
                    color: theme.buttonText,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}