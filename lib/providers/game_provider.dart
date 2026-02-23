import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_model.dart';
import '../theme/app_theme.dart';

class GameProvider extends ChangeNotifier {
  final GameModel _model = GameModel();

  // Separate AudioPlayer for each sound so they never cancel each other
  final AudioPlayer _jumpPlayer = AudioPlayer();
  final AudioPlayer _demonPlayer = AudioPlayer();
  final AudioPlayer _splashPlayer = AudioPlayer();

  AppThemeMode _themeMode = AppThemeMode.light;
  bool _isAnimating = false;
  String? _message;
  int _elapsedSeconds = 0;
  bool _timerRunning = false;
  DateTime? _startTime;

  GameProvider() {
    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      await _jumpPlayer.setReleaseMode(ReleaseMode.release);
      await _demonPlayer.setReleaseMode(ReleaseMode.release);
      await _splashPlayer.setReleaseMode(ReleaseMode.release);

      await _jumpPlayer.setVolume(1.0);
      await _demonPlayer.setVolume(1.0);
      await _splashPlayer.setVolume(1.0);

      await _jumpPlayer.setSource(AssetSource('sounds/jump.mp3'));
      await _demonPlayer.setSource(AssetSource('sounds/demon_roar.mp3'));
      await _splashPlayer.setSource(AssetSource('sounds/splash.mp3'));

      debugPrint('✅ Audio initialized successfully');
    } catch (e) 
    {
      debugPrint('❌ Audio init error: $e');
    }
  }

  // Getters
  GameModel get model => _model;
  AppThemeMode get themeMode => _themeMode;
  AppTheme get theme => AppTheme.of(_themeMode);
  bool get isAnimating => _isAnimating;
  String? get message => _message;
  int get elapsedSeconds => _elapsedSeconds;
  bool get timerRunning => _timerRunning;

  void startTimer() {
    if (!_timerRunning) {
      _timerRunning = true;
      _startTime = DateTime.now();
      _tickTimer();
    }
  }

  void _tickTimer() async {
    while (_timerRunning && !_model.isGameOver) {
      await Future.delayed(const Duration(seconds: 1));
      if (_timerRunning) {
        _elapsedSeconds = DateTime.now().difference(_startTime!).inSeconds;
        notifyListeners();
      }
    }
  }

  void stopTimer() {
    _timerRunning = false;
  }

  String get timerDisplay {
    final m = _elapsedSeconds ~/ 60;
    final s = _elapsedSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void setTheme(AppThemeMode mode) {
    _themeMode = mode;
    _saveTheme();
    notifyListeners();
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final idx = prefs.getInt('theme') ?? 0;
    _themeMode = AppThemeMode.values[idx];
    notifyListeners();
  }

  Future<void> _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme', _themeMode.index);
  }

  Future<void> _playJump() async {
    try {
      await _jumpPlayer.stop();
      await _jumpPlayer.play(AssetSource('sounds/jump.mp3'));
      debugPrint('🔊 jump played');
    } catch (e) {
      debugPrint('❌ jump error: $e');
    }
  }

  Future<void> _playDemonRoar() async {
    try {
      await _demonPlayer.stop();
      await _demonPlayer.play(AssetSource('sounds/demon_roar.mp3'));
      debugPrint('🔊 demon roar played');
    } catch (e) {
      debugPrint('❌ demon roar error: $e');
    }
  }

  Future<void> _playSplash() async {
    try {
      await _splashPlayer.stop();
      await _splashPlayer.play(AssetSource('sounds/splash.mp3'));
      debugPrint('🔊 splash played');
    } catch (e) {
      debugPrint('❌ splash error: $e');
    }
  }

  bool addMonkToBoat() {
    if (_model.isGameOver) return false;
    startTimer();
    final result = _model.addMonkToBoat();
    if (result) {
      _playJump();
      _setMessage(null);
    } else {
      _setMessage(_model.boatFull ? 'Boat is full!' : 'No monks here!');
    }
    notifyListeners();
    return result;
  }

  bool removeDemonFromBoat() {
    final r = _model.removeDemonFromBoat();
    if (r) _playJump();
    notifyListeners();
    return r;
  }

  bool addDemonToBoat() {
    if (_model.isGameOver) return false;
    startTimer();
    final result = _model.addDemonToBoat();
    if (result) {
      _playDemonRoar();
      _setMessage(null);
    } else {
      _setMessage(_model.boatFull ? 'Boat is full!' : 'No demons here!');
    }
    notifyListeners();
    return result;
  }

  bool removeMonkFromBoat() {
    final r = _model.removeMonkFromBoat();
    if (r) _playJump();
    notifyListeners();
    return r;
  }

  Future<void> go() async {
    if (_isAnimating || _model.isGameOver) return;
    final err = _model.go();
    if (err != null) {
      _setMessage(err);
      return;
    }
    _isAnimating = true;
    notifyListeners();
    _playSplash();
    await Future.delayed(const Duration(milliseconds: 1500));
    _isAnimating = false;

    if (_model.isGameOver) {
      stopTimer();
      _model.recordAttempt(_elapsedSeconds);
      if (_model.isWon) {
        _setMessage('🎉 You Won! All crossed safely!');
      } else {
        _setMessage('💀 Game Over! Demons outnumbered monks!');
      }
    }
    notifyListeners();
  }

  void reset() {
    _model.reset();
    _isAnimating = false;
    _message = null;
    _elapsedSeconds = 0;
    _timerRunning = false;
    _startTime = null;
    notifyListeners();
  }

  void _setMessage(String? msg) {
    _message = msg;
  }

  @override
  void dispose() {
    _jumpPlayer.dispose();
    _demonPlayer.dispose();
    _splashPlayer.dispose();
    super.dispose();
  }
}