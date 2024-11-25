import 'package:flutter/material.dart';

class SummaryScreen extends StatelessWidget {
  final Map<String, dynamic> results;
  final Map<String, dynamic> quizSettings;

  const SummaryScreen({
    Key? key,
    required this.results,
    required this.quizSettings,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int score = results['score'];
    int total = results['total'];
    List<Map<String, dynamic>> answers = List.from(results['answers']);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Summary'),
        backgroundColor: Colors.teal,
        automaticallyImplyLeading: false, // Remove the back arrow
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Score Display
            Text(
              'You scored $score out of $total!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Display answers with correctness
            Expanded(
              child: ListView.builder(
                itemCount: answers.length,
                itemBuilder: (context, index) {
                  var answer = answers[index];
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16.0),
                      title: Text(
                        answer['question'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            // Check if the answer is null and display "Not Answered"
                            'Your answer: ${answer['user_answer'] ?? 'Not Answered'}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: answer['user_answer'] == null
                                  ? Colors.grey
                                  : (answer['is_correct']
                                      ? Colors.green
                                      : Colors.red),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Correct answer: ${answer['correct_answer']}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Horizontal layout for buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Retake Quiz Button
                ElevatedButton(
                  onPressed: () {
                    // Navigate to the Quiz screen with the same settings
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/quiz',
                      (route) => false,
                      arguments: quizSettings, // Use the same settings
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal, // Same color for both buttons
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 32.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text('Retake Quiz'),
                ),
                const SizedBox(width: 16), // Space between the buttons
                // Return to Setup Button
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/', // Navigate to the Setup screen
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal, // Same color for both buttons
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 32.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text('Return to Setup'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
