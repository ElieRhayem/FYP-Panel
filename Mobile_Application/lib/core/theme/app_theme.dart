import 'package:flutter/material.dart';

class AppTheme {
  static const Color bgDark = Color(0xFF0A0F1E);
  static const Color panel = Color(0xFF0F1730);
  static const Color border = Color(0xFF26304F);
  static const Color text = Color(0xFFEAF0FF);
  static const Color muted = Color(0xFF9FB0D1);
  static const Color primary = Color(0xFF00D1FF);
  static const Color secondary = Color(0xFF7C4DFF);
  static const Color danger = Color(0xFFFF4D6D);

  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        surface: panel,
        onSurface: text,
        primary: primary,
        secondary: secondary,
        error: danger,
      ),
      fontFamily: 'RobotoMono',
    );

    return base.copyWith(
      scaffoldBackgroundColor: bgDark,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: bgDark,
        foregroundColor: text,
        centerTitle: true,
      ),
      dividerTheme: const DividerThemeData(
        thickness: 1,
        space: 0,
        color: border,
      ),
      textTheme: base.textTheme.copyWith(
        titleLarge: base.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: text,
        ),
        titleMedium: base.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: text,
        ),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(color: text),
        bodySmall: base.textTheme.bodySmall?.copyWith(color: muted),
        labelMedium: base.textTheme.labelMedium?.copyWith(color: muted),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: panel,
        contentTextStyle: const TextStyle(color: text),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: border),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}