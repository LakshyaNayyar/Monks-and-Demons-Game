// Classic Missionaries and Cannibals (Monks and Demons) Game Logic
// AI Solution using BFS for valid state validation

enum Side { left, right }

class GameState {
  final int leftMonks;
  final int leftDemons;
  final int rightMonks;
  final int rightDemons;
  final Side boatSide;
  final bool isValid;

  const GameState({
    required this.leftMonks,
    required this.leftDemons,
    required this.rightMonks,
    required this.rightDemons,
    required this.boatSide,
    this.isValid = true,
  });

  bool get isWon => leftMonks == 0 && leftDemons == 0;

  bool get isLost {
    // Monks are eaten if outnumbered by demons on either side (when monks > 0)
    if (leftMonks > 0 && leftDemons > leftMonks) return true;
    if (rightMonks > 0 && rightDemons > rightMonks) return true;
    return false;
  }

  String get stateKey => '$leftMonks-$leftDemons-$rightMonks-$rightDemons-${boatSide.index}';

  @override
  bool operator ==(Object other) =>
      other is GameState && stateKey == other.stateKey;

  @override
  int get hashCode => stateKey.hashCode;
}

class Move {
  final int monks; // number of monks to move
  final int demons; // number of demons to move
  Move(this.monks, this.demons);
  @override
  String toString() => '${monks}M ${demons}D';
}

class AttemptRecord {
  final List<String> moves;
  final int duration; // seconds
  final bool success;
  final DateTime timestamp;

  AttemptRecord({
    required this.moves,
    required this.duration,
    required this.success,
    required this.timestamp,
  });
}

class GameModel {
  static const int totalMonks = 3;
  static const int totalDemons = 3;
  static const int boatCapacity = 2;

  int leftMonks = totalMonks;
  int leftDemons = totalDemons;
  int rightMonks = 0;
  int rightDemons = 0;
  Side boatSide = Side.left;

  // Boat contents (staged before moving)
  int boatMonks = 0;
  int boatDemons = 0;

  bool isGameOver = false;
  bool isWon = false;
  List<String> moveHistory = [];
  List<AttemptRecord> attemptHistory = [];

  // Get current state
  GameState get currentState => GameState(
        leftMonks: leftMonks,
        leftDemons: leftDemons,
        rightMonks: rightMonks,
        rightDemons: rightDemons,
        boatSide: boatSide,
      );

  int get boatTotal => boatMonks + boatDemons;
  bool get boatFull => boatTotal >= boatCapacity;
  bool get boatEmpty => boatTotal == 0;

  // How many monks/demons are on the same side as the boat
  int get availableMonks =>
      boatSide == Side.left ? leftMonks : rightMonks;
  int get availableDemons =>
      boatSide == Side.left ? leftDemons : rightDemons;

  // Try to add a monk to boat (from current boat side)
  bool addMonkToBoat() {
    if (boatFull) return false;
    if (availableMonks <= 0) return false;
    if (boatSide == Side.left) {
      leftMonks--;
    } else {
      rightMonks--;
    }
    boatMonks++;
    return true;
  }

  // Try to add a demon to boat
  bool addDemonToBoat() {
    if (boatFull) return false;
    if (availableDemons <= 0) return false;
    if (boatSide == Side.left) {
      leftDemons--;
    } else {
      rightDemons--;
    }
    boatDemons++;
    return true;
  }

  // Remove monk from boat (put back on current side)
  bool removeMonkFromBoat() {
    if (boatMonks <= 0) return false;
    if (boatSide == Side.left) {
      leftMonks++;
    } else {
      rightMonks++;
    }
    boatMonks--;
    return true;
  }

  // Remove demon from boat
  bool removeDemonFromBoat() {
    if (boatDemons <= 0) return false;
    if (boatSide == Side.left) {
      leftDemons++;
    } else {
      rightDemons++;
    }
    boatDemons--;
    return true;
  }

  // Execute crossing — returns null if invalid, else the new state
  String? go() {
    if (boatEmpty) return 'Boat is empty! Add at least one person.';

    // Move boat to other side, unload passengers
    final fromSide = boatSide;
    boatSide = boatSide == Side.left ? Side.right : Side.left;

    if (boatSide == Side.right) {
      rightMonks += boatMonks;
      rightDemons += boatDemons;
    } else {
      leftMonks += boatMonks;
      leftDemons += boatDemons;
    }

    final movStr =
        'Move: ${boatMonks}M ${boatDemons}D → ${boatSide == Side.right ? "Right" : "Left"}';
    moveHistory.add(movStr);

    boatMonks = 0;
    boatDemons = 0;

    // Check game state
    if (currentState.isLost) {
      isGameOver = true;
      isWon = false;
    } else if (currentState.isWon) {
      isGameOver = true;
      isWon = true;
    }

    return null; // success
  }

  void reset() {
    leftMonks = totalMonks;
    leftDemons = totalDemons;
    rightMonks = 0;
    rightDemons = 0;
    boatSide = Side.left;
    boatMonks = 0;
    boatDemons = 0;
    isGameOver = false;
    isWon = false;
    moveHistory = [];
  }

  void recordAttempt(int duration) {
    attemptHistory.add(AttemptRecord(
      moves: List.from(moveHistory),
      duration: duration,
      success: isWon,
      timestamp: DateTime.now(),
    ));
  }

  // BFS to find optimal solution (for hint system)
  static List<Move>? findOptimalSolution() {
    final initial = _SolveState(3, 3, 0, 0, Side.left, []);
    final queue = <_SolveState>[initial];
    final visited = <String>{};

    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      final key =
          '${current.lM}-${current.lD}-${current.rM}-${current.rD}-${current.boat.index}';
      if (visited.contains(key)) continue;
      visited.add(key);

      if (current.lM == 0 && current.lD == 0) {
        return current.moves;
      }

      // Generate all possible moves (1-2 people, at least 1)
      for (int m = 0; m <= 2; m++) {
        for (int d = 0; d <= 2; d++) {
          if (m + d == 0 || m + d > 2) continue;

          int nlM = current.lM,
              nlD = current.lD,
              nrM = current.rM,
              nrD = current.rD;

          if (current.boat == Side.left) {
            if (m > nlM || d > nlD) continue;
            nlM -= m;
            nlD -= d;
            nrM += m;
            nrD += d;
          } else {
            if (m > nrM || d > nrD) continue;
            nrM -= m;
            nrD -= d;
            nlM += m;
            nlD += d;
          }

          // Validate
          if ((nlM > 0 && nlD > nlM) || (nrM > 0 && nrD > nrM)) continue;

          final newMoves = [...current.moves, Move(m, d)];
          final nextSide =
              current.boat == Side.left ? Side.right : Side.left;
          queue.add(
              _SolveState(nlM, nlD, nrM, nrD, nextSide, newMoves));
        }
      }
    }
    return null;
  }
}

class _SolveState {
  final int lM, lD, rM, rD;
  final Side boat;
  final List<Move> moves;
  _SolveState(this.lM, this.lD, this.rM, this.rD, this.boat, this.moves);
}