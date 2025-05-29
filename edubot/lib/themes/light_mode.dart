import 'package:flutter/material.dart';

ThemeData lightmode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    surface: Color(0xFFFAFAFA),
    inverseSurface: Color(0xFF96C0CA),
    primary: Color(0xFF074F67),
    onPrimary: Color(0xFF05455B),
    secondary: Color(0xFF364B55),
    onSecondary: Color(0xFF1A1A1A),
    onSecondaryFixed: Color(0xFFECF6F9),
    error: Color(0xFFCC0000),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF23565A),
      foregroundColor: Color(0xFFFAFAFA),
      // disabledBackgroundColor: Colors.grey.shade200,
      // disabledForegroundColor: Color(0xFF1A1A1A).withValues(alpha: 0.2),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
    labelStyle: TextStyle(
      fontFamily: "Nunito",
      fontSize: 16,
      color: Color(0xFF1A1A1A).withValues(alpha: 0.75),
    ),

    // Background colour
    filled: true,
    fillColor: Color(0xFFE6E6E6),
            
    // Border management
    border: OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.circular(5),
    ),
  ),

  snackBarTheme: SnackBarThemeData(
    backgroundColor: Color(0xFF1A1A1A)
  ),

  // Alert dialog theme
  dialogTheme: DialogThemeData(
    backgroundColor: Colors.grey.shade300,
  )
);
