
import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const AIFootballCoachApp());
}

class AIFootballCoachApp extends StatelessWidget {
  const AIFootballCoachApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Football Coach',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF101710),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB7F34A),
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF101710),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
