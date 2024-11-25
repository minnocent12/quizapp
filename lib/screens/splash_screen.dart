import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'setup_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Control the opacity and scale of the logo
  double _opacity = 0.0;
  double _scale = 0.5;

  @override
  void initState() {
    super.initState();
    // Wait for a brief delay before navigating to the next screen
    _animateLogo();
    _navigateToNextScreen();
  }

  void _animateLogo() {
    // Animate the opacity and scale of the logo
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _opacity = 1.0;
        _scale = 1.0;
      });
    });
  }

  void _navigateToNextScreen() {
    // Navigate to SetupScreen after a delay
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SetupScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal, // Main background color
      body: Center(
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(seconds: 1), // Fade-in effect duration
          child: AnimatedScale(
            scale: _scale,
            duration: const Duration(seconds: 1), // Zoom-in effect duration
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Add logo or app icon here
                Image.asset(
                  'lib/assets/images/logo.png',
                  height: 120, // Adjust logo size
                ),
                const SizedBox(height: 20),
                const Text(
                  'Quiz App',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
