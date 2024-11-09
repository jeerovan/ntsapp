

import 'package:flutter/material.dart';

class AppThemes {
  static final lightTheme = ThemeData(
    primaryColor: Colors.blue,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
        colorScheme: const ColorScheme.light(
          primary: Colors.blue,
          secondary: Colors.blueAccent,
        ),
        appBarTheme: const AppBarTheme(
          color: Colors.blue,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        textTheme: const TextTheme(
        ),
  );

  static final darkTheme = ThemeData(
    primaryColor: Colors.teal,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          primary: Colors.teal,
          secondary: Colors.tealAccent,
        ),
        appBarTheme: const AppBarTheme(
          color: Colors.teal,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        textTheme: const TextTheme(
        ),
  );
}