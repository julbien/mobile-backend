import 'package:flutter/material.dart';
import 'dart:async';
import 'screens/sign_in.dart';
import 'screens/dashboard.dart';
import 'services/auth_service.dart';

// main entry point
void main() {
  runApp(const MyApp());
}

// root widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PathPal App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // starts with splash screen
      home: const SplashScreen(),
    );
  }
}

// splash screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  // animation controller
  late AnimationController _controller;
  // dot animations
  late Animation<double> dotOneOpacity;
  late Animation<double> dotTwoOpacity;
  late Animation<double> dotThreeOpacity;

  @override
  void initState() {
    super.initState();

    // setup animations
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    dotOneOpacity = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    dotTwoOpacity = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.6, curve: Curves.easeIn),
      ),
    );

    dotThreeOpacity = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
      ),
    );

    // after 3 seconds, check login and navigate
    Timer(const Duration(seconds: 3), () async {
      final isLoggedIn = await AuthService.isLoggedIn();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => isLoggedIn 
                ? const DashboardPage() 
                : const LoginScreen(),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    // clean up controller
    _controller.dispose();
    super.dispose();
  }

  // builds a single animated dot
  Widget buildDot(Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: const Text(
        '.',
        style: TextStyle(
          color: Colors.white,
          fontSize: 40,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0057B8),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                'assets/images/clogo.png',
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 50),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildDot(dotOneOpacity),
                    const SizedBox(width: 4),
                    buildDot(dotTwoOpacity),
                    const SizedBox(width: 4),
                    buildDot(dotThreeOpacity),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
