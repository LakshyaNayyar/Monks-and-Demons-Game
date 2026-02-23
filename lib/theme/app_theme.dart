import 'package:flutter/material.dart';

enum AppThemeMode { light, dark, neon, pink }

class AppTheme {
  final AppThemeMode mode;
  final Color background;
  final Color water;
  final Color waterHighlight;
  final Color boat;
  final Color demonColor;
  final Color monkColor;
  final Color textColor;
  final Color buttonColor;
  final Color buttonText;
  final Color timerBg;
  final Color sky;
  final String name;

  const AppTheme({
    required this.mode,
    required this.background,
    required this.water,
    required this.waterHighlight,
    required this.boat,
    required this.demonColor,
    required this.monkColor,
    required this.textColor,
    required this.buttonColor,
    required this.buttonText,
    required this.timerBg,
    required this.sky,
    required this.name,
  });

  static const Map<AppThemeMode, AppTheme> themes = {
    AppThemeMode.light: AppTheme(
      mode: AppThemeMode.light,
      background: Color(0xFFF5E6C8),
      water: Color(0xFF4A90D9),
      waterHighlight: Color(0xFF74B3F0),
      boat: Color(0xFF8B4513),
      demonColor: Color(0xFF654321),
      monkColor: Color(0xFFFFD700),
      textColor: Color(0xFF3E2723),
      buttonColor: Color(0xFF6D4C41),
      buttonText: Color(0xFFFFFFFF),
      timerBg: Color(0x886D4C41),
      sky: Color(0xFF87CEEB),
      name: 'Light',
    ),
    AppThemeMode.dark: AppTheme(
      mode: AppThemeMode.dark,
      background: Color(0xFF121212),
      water: Color(0xFF1A3A5C),
      waterHighlight: Color(0xFF2A5A8C),
      boat: Color(0xFFFFFFFF),
      demonColor: Color(0xFF2E7D32),
      monkColor: Color(0xFFFF8C00),
      textColor: Color(0xFFEEEEEE),
      buttonColor: Color(0xFF37474F),
      buttonText: Color(0xFFEEEEEE),
      timerBg: Color(0x8837474F),
      sky: Color(0xFF1A1A2E),
      name: 'Dark',
    ),
    AppThemeMode.neon: AppTheme(
      mode: AppThemeMode.neon,
      background: Color(0xFF0D0D0D),
      water: Color(0xFF003333),
      waterHighlight: Color(0xFF00FFFF),
      boat: Color(0xFF39FF14),
      demonColor: Color(0xFFDC143C),
      monkColor: Color(0xFFFF6600),
      textColor: Color(0xFF00FFFF),
      buttonColor: Color(0xFF39FF14),
      buttonText: Color(0xFF0D0D0D),
      timerBg: Color(0x8839FF14),
      sky: Color(0xFF0D001A),
      name: 'Neon',
    ),
    AppThemeMode.pink: AppTheme(
      mode: AppThemeMode.pink,
      background: Color(0xFFFCE4EC),
      water: Color(0xFFE91E8C),
      waterHighlight: Color(0xFFFF69B4),
      boat: Color(0xFFFF00FF),
      demonColor: Color(0xFF00008B),
      monkColor: Color(0xFFE6AAFF),
      textColor: Color(0xFF880E4F),
      buttonColor: Color(0xFFAD1457),
      buttonText: Color(0xFFFFFFFF),
      timerBg: Color(0x88AD1457),
      sky: Color(0xFFFCE4EC),
      name: 'Pink',
    ),
  };

  static AppTheme of(AppThemeMode mode) => themes[mode]!;
}