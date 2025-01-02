import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppThemes {
  static final lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.cyan, brightness: Brightness.light),
    textTheme: GoogleFonts.interTextTheme().apply(
      bodyColor: Colors.black, // Default text color in light mode
      displayColor: Colors.black, // Display text color in light mode
    ),
  );

  static final darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.cyan, brightness: Brightness.dark),
    textTheme: GoogleFonts.interTextTheme().apply(
      bodyColor: Colors.grey, // Default text color in dark mode
      displayColor: Colors.grey, // Display text color in dark mode
    ),
  );
}
