import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const SmartHomeApp());
}

class SmartHomeApp extends StatelessWidget {
  const SmartHomeApp({super.key});

  static const Color brandBlue = Color(0xFF2F62D4);

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: brandBlue,
      primary: brandBlue,
      surface: Colors.white,
    );

    return MaterialApp(
      title: 'Smart Home Controller',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFFF3F5F9),
        appBarTheme: const AppBarTheme(
          backgroundColor: brandBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.w600,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE3E7EF)),
          ),
        ),
        switchTheme: SwitchThemeData(
          trackOutlineColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? Colors.transparent
                : const Color(0xFFC5CAD3),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
