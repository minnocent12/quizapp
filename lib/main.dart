import 'package:flutter/material.dart';
import 'screens/splash_screen.dart'; // Import the SplashScreen
import 'screens/setup_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/summary_screen.dart';

void main() {
  runApp(const QuizApp());
}

class QuizApp extends StatelessWidget {
  const QuizApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/splash', // Set initial route to splash screen
      routes: {
        '/splash': (context) => const SplashScreen(), // Splash screen route
        '/': (context) => const SetupScreen(),
        '/quiz': (context) {
          final settings = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return QuizScreen(settings: settings);
        },
        '/summary': (context) {
          final arguments = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return SummaryScreen(
            results: arguments,
            quizSettings: arguments['quizSettings'], // Extract the settings
          );
        },
      },
    );
  }
}
