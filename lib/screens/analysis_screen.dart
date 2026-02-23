import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/game_model.dart';
import '../theme/app_theme.dart';

class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final theme = provider.theme;
    final attempts = provider.model.attemptHistory;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: theme.buttonColor,
        foregroundColor: theme.buttonText,
        title: Text(
          'Analysis Report',
          style: TextStyle(
            color: theme.buttonText,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: attempts.isEmpty
          ? Center(
              child: Text(
                'No attempts yet.\nPlay the game first!',
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.textColor, fontSize: 18),
              ),
            )
          : Column(
              children: [
                _SummaryCard(attempts: attempts, theme: theme),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: attempts.length,
                    itemBuilder: (ctx, i) {
                      final a = attempts[attempts.length - 1 - i];
                      return _AttemptCard(
                        attempt: a,
                        number: attempts.length - i,
                        theme: theme,
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final List<AttemptRecord> attempts;
  final AppTheme theme;

  const _SummaryCard({required this.attempts, required this.theme});

  @override
  Widget build(BuildContext context) {
    final wins = attempts.where((a) => a.success).length;
    final bestTime = attempts
        .where((a) => a.success)
        .map((a) => a.duration)
        .fold<int?>(null, (prev, d) => prev == null || d < prev ? d : prev);
    final bestMoves = attempts
        .where((a) => a.success)
        .map((a) => a.moves.length)
        .fold<int?>(null, (prev, m) => prev == null || m < prev ? m : prev);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.buttonColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.buttonColor.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _Stat(
            icon: Icons.games,
            label: 'Total',
            value: '${attempts.length}',
            theme: theme,
          ),
          _Stat(
            icon: Icons.emoji_events,
            label: 'Wins',
            value: '$wins',
            theme: theme,
          ),
          _Stat(
            icon: Icons.timer,
            label: 'Best Time',
            value: bestTime != null ? _fmt(bestTime) : '-',
            theme: theme,
          ),
          _Stat(
            icon: Icons.directions_boat,
            label: 'Best Moves',
            value: bestMoves != null ? '$bestMoves' : '-',
            theme: theme,
          ),
        ],
      ),
    );
  }

  String _fmt(int s) {
    final m = s ~/ 60;
    final sec = s % 60;
    return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final AppTheme theme;

  const _Stat({
    required this.icon,
    required this.label,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: theme.buttonColor, size: 28),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                color: theme.textColor,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        Text(label,
            style: TextStyle(color: theme.textColor.withOpacity(0.7), fontSize: 11)),
      ],
    );
  }
}

class _AttemptCard extends StatelessWidget {
  final AttemptRecord attempt;
  final int number;
  final AppTheme theme;

  const _AttemptCard({
    required this.attempt,
    required this.number,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final m = attempt.duration ~/ 60;
    final s = attempt.duration % 60;
    final timeStr =
        '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: theme.buttonColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: attempt.success ? Colors.green.withOpacity(0.5) : Colors.red.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor:
              attempt.success ? Colors.green : Colors.red,
          child: Text(
            '$number',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          'Attempt #$number — ${attempt.success ? "SUCCESS ✓" : "FAILED ✗"}',
          style: TextStyle(
            color: theme.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          'Time: $timeStr  |  Moves: ${attempt.moves.length}',
          style: TextStyle(color: theme.textColor.withOpacity(0.7)),
        ),
        iconColor: theme.textColor,
        collapsedIconColor: theme.textColor,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Move History:',
                    style: TextStyle(
                        color: theme.textColor,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...attempt.moves.asMap().entries.map((e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: theme.buttonColor.withOpacity(0.3),
                            ),
                            alignment: Alignment.center,
                            child: Text('${e.key + 1}',
                                style: TextStyle(
                                    color: theme.textColor, fontSize: 10)),
                          ),
                          const SizedBox(width: 8),
                          Text(e.value,
                              style: TextStyle(color: theme.textColor.withOpacity(0.8))),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}