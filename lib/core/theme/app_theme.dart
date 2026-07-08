import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFFFF4757);
  static const Color primaryDark = Color(0xFFFF6B81);
  static const Color bgDark = Color(0xFF0F1115);
  static const Color textMain = Color(0xFFF1F2F6);
  static const Color textMuted = Color(0xFFA4B0BE);
  static const Color success = Color(0xFF2ED573);
  static const Color warning = Color(0xFFFFA502);
  static const Color danger = Color(0xFFFF4757);
  static final Color glassBg = Color(0xFF14181E).withValues(alpha: 0.65);
  static final Color glassBorder = Colors.white.withValues(alpha: 0.08);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgDark,
      primaryColor: primaryColor,
      fontFamily: 'Tajawal',
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
      ),
    );
  }

  static void showCustomSnackBar(BuildContext context, String message, {bool isError = false, int bottomOffset = 150}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Tajawal', color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: isError ? danger : success,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - bottomOffset,
          left: 20,
          right: 20,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
