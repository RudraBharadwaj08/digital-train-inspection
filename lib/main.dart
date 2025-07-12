import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:shopping_list/screens/login_screen.dart';

void main() {
  runApp(
    DevicePreview(
      enabled: true,
      builder: (context) => const ScoreCardApp(),
    ),
  );
}

class ScoreCardApp extends StatelessWidget {
  const ScoreCardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Score Card',
      debugShowCheckedModeBanner: false,
      useInheritedMediaQuery: true,
      builder: DevicePreview.appBuilder,
      themeMode: ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFE6F0FA), // Light bluish background
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.lightBlueAccent,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFB3E5FC), // Soft blue AppBar
          foregroundColor: Colors.black87,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightBlueAccent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFFE0F7FA), // light blue input background
          border: OutlineInputBorder(),
          labelStyle: TextStyle(color: Colors.black87),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 16, color: Colors.black),
          bodyMedium: TextStyle(fontSize: 14, color: Colors.black87),
          titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
