import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  ThemeData get themeData => _isDarkMode ? darkTheme : lightTheme;

  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Color(0xFF7E57C2), // Primary color for light mode
    scaffoldBackgroundColor: Colors.white, // Background color for light mode
    appBarTheme: const AppBarTheme(
      color: Color(0xFF7E57C2), // App bar color for light mode
      iconTheme: IconThemeData(color: Colors.white), // App bar icons color
      titleTextStyle: TextStyle(color: Color(0xFF212121)), // App bar title text color for light mode
    ),
  );

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF4527A0), // Primary color for dark mode
    scaffoldBackgroundColor: const Color(0xFF212121), // Background color for dark mode
    appBarTheme: const AppBarTheme(
      color: Color(0xFF4527A0), // App bar color for dark mode
      iconTheme: IconThemeData(color: Colors.white), // App bar icons color
      titleTextStyle: TextStyle(color: Colors.white), // App bar title text color for dark mode
    ),
  );
}