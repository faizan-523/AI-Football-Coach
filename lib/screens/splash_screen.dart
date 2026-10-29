
import 'package:flutter/material.dart';
import 'package:first_flutter_project/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF203D22),
              Color(0xFF101710),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 115,
              width: 115,
              decoration: BoxDecoration(
                color: const Color(0xFFB7F34A),
                borderRadius: BorderRadius.circular(32),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: Image.asset(
                  'assets/images/football_ai_logo.png',
                  width: 115,
                  height: 115,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'AI FOOTBALL COACH',
              style: TextStyle(
                color: Colors.white,
                fontSize: 27,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Train smarter. Play better.',
              style: TextStyle(
                color: Color(0xFFB7F34A),
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 45),

            const CircularProgressIndicator(
              color: Color(0xFFB7F34A),
            ),
          ],
        ),
      ),
    );
  }
}
