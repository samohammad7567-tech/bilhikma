import 'package:flutter/material.dart';

enum ThemeOption {
  light(label: 'theme_light', icon: Icons.light_mode, isDark: false),
  dark(label: 'theme_dark', icon: Icons.dark_mode, isDark: true);

  const ThemeOption({
    required this.label,
    required this.icon,
    required this.isDark,
  });

  final String label;

  final IconData icon;

  final bool isDark;

  static ThemeOption of(bool isDark) =>
      isDark ? ThemeOption.dark : ThemeOption.light;
}
