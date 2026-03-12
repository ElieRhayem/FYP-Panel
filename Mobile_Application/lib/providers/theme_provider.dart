import 'package:flutter/material.dart';
import 'package:mobile_application/core/theme/app_theme.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = true;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    // Disabled on purpose: app is now fixed to NASA dark mode only.
  }

  ThemeData get themeData => AppTheme.dark();
}