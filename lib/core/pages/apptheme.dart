import 'package:doctor_care/core/pages/app_color.dart';
import 'package:flutter/material.dart';

class AppTheme {
  // ========== LIGHT THEME ==========
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColor.background,
    scaffoldBackgroundColor: Colors.grey.shade50,
    fontFamily: 'Rubik',
    
    colorScheme: ColorScheme.light(
      primary: AppColor.background,
      secondary: Colors.blue.shade400,
      surface: Colors.white,
      error: Colors.red,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.black87,
      onError: Colors.white,
    ),

    textSelectionTheme: TextSelectionThemeData(
      cursorColor: Colors.blue.shade600,
      selectionColor: Colors.blue.withOpacity(0.3),
      selectionHandleColor: Colors.blue.shade600,
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: AppColor.background,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        fontFamily: 'Rubik',
      ),
    ),

    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    ),

    iconTheme: IconThemeData(
      color: Colors.black87,
    ),

    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
        fontFamily: 'Rubik',
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
        fontFamily: 'Rubik',
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Colors.black87,
        fontFamily: 'Rubik',
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: Colors.black87,
        fontFamily: 'Rubik',
      ),
    ),

    dividerColor: Colors.grey.shade300,
    
    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColor.background, width: 2),
      ),
    ),
  );

  // ========== DARK THEME ==========
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppColor.background,
    scaffoldBackgroundColor: Color(0xFF121212),
    fontFamily: 'Rubik',
    
    colorScheme: ColorScheme.dark(
      primary: AppColor.background,
      secondary: Colors.blue.shade300,
      surface: Color(0xFF1E1E1E),
      error: Colors.red.shade400,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      onError: Colors.white,
    ),

    textSelectionTheme: TextSelectionThemeData(
      cursorColor: Colors.blue.shade300,
      selectionColor: Colors.blue.withOpacity(0.3),
      selectionHandleColor: Colors.blue.shade300,
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        fontFamily: 'Rubik',
      ),
    ),

    cardTheme: CardThemeData(
      color: Color(0xFF1E1E1E),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    ),

    iconTheme: IconThemeData(
      color: Colors.white,
    ),

    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        fontFamily: 'Rubik',
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        fontFamily: 'Rubik',
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Colors.white,
        fontFamily: 'Rubik',
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: Colors.white70,
        fontFamily: 'Rubik',
      ),
    ),

    dividerColor: Colors.grey.shade800,
    
    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF2C2C2C),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade700),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColor.background, width: 2),
      ),
    ),
  );
}