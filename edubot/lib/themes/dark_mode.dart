import 'package:flutter/material.dart';

ThemeData darkmode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    surface: Color(0xFF273942),
    inverseSurface: Color(0xFF6391A8),
    primary: Color(0xFFA8D4DA),
    onPrimary: Color(0xFFA8D4DA),
    secondary: Color(0xFFFAFAFA),
    onSecondary: Color(0xFFECF6F9),
    onSecondaryFixed: Color(0xFF1A1A1A),
    error: Color(0xFFFF6B6C),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF99DAE6),
      foregroundColor: Color(0xFF1A1A1A),
    )
  ),
   inputDecorationTheme: InputDecorationTheme(
    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
    labelStyle: TextStyle(
      fontFamily: "Nunito",
      fontSize: 16,
      color: Color(0xFFECF6F9).withValues(alpha: 0.75),
    ),

    // Background colour
    filled: true,
    fillColor: Color(0xFF404B50),
            
    // Border management
    border: OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.circular(5),
    ),
  ),

  snackBarTheme: SnackBarThemeData(
    backgroundColor: Color(0xFFECF6F9)
  )
);