import 'package:flutter/material.dart';

class SummaryScreen extends StatelessWidget {
  final Map<String, dynamic> results;

  const SummaryScreen({Key? key, required this.results}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int score = results['score'];
    int total = results['total'];

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Summary')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'You scored $score out of $total!',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
              },
              child: const Text('Retake Quiz'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Return to Setup'),
            ),
          ],
        ),
      ),
    );
  }
}
