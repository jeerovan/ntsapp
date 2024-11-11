import 'package:flutter/material.dart';

class AppThemes {
  static final lightTheme = ThemeData(
    primaryColor: Colors.blue,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    colorScheme:  ColorScheme.fromSeed(seedColor: const Color(0xff6200ee)).copyWith(
      primaryContainer: const Color(0xff6200ee),
      onPrimaryContainer: Colors.white,
      secondaryContainer: const Color(0xff03dac6),
      onSecondaryContainer: Colors.black,
      error: const Color(0xffb00020),
      onError: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      color: Colors.blue,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: Colors.black87, fontSize: 24, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(color: Colors.black87, fontSize: 22, fontWeight: FontWeight.w600),
      displaySmall: TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.w600),
      headlineMedium: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: Colors.black87, fontSize: 16),
      bodyMedium: TextStyle(color: Colors.black54, fontSize: 14),
      bodySmall: TextStyle(color: Colors.black45, fontSize: 12),
      labelLarge: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
    ),
    iconTheme: const IconThemeData(color: Colors.blueAccent),
    buttonTheme: const ButtonThemeData(
      buttonColor: Colors.blue,
      textTheme: ButtonTextTheme.primary,
    ),
  );

  static final darkTheme = ThemeData(
    primaryColor: Colors.teal,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.black,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal).copyWith(
      primaryContainer: Colors.teal,
      onPrimaryContainer: Colors.black,
      secondaryContainer: const Color(0xff03dac6),
      onSecondaryContainer: Colors.black,
      error: const Color.fromARGB(255, 255, 0, 47),
      onError: Colors.black,
    ),
    appBarTheme: const AppBarTheme(
      color: Colors.teal,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600),
      displaySmall: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
      headlineMedium: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: Colors.white70, fontSize: 16),
      bodyMedium: TextStyle(color: Colors.white60, fontSize: 14),
      bodySmall: TextStyle(color: Colors.white54, fontSize: 12),
      labelLarge: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
    ),
    iconTheme: const IconThemeData(color: Colors.tealAccent),
    buttonTheme: const ButtonThemeData(
      buttonColor: Colors.teal,
      textTheme: ButtonTextTheme.primary,
    ),
  );
}
