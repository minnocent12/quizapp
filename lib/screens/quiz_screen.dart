import 'package:flutter/material.dart';
import 'dart:async';
import '../services/api_service.dart';

class QuizScreen extends StatefulWidget {
  final Map<String, dynamic> settings;

  const QuizScreen({Key? key, required this.settings}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  String? _feedback;
  Timer? _timer;
  int _timeLeft = 15;
  List<Map<String, dynamic>> _answers = [];
  List<String> _shuffledAnswers = [];

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    try {
      var fetchedQuestions = await ApiService.fetchQuestions(widget.settings);
      setState(() {
        _questions = fetchedQuestions;
        _shuffleAnswers(); // Shuffle answers for the first question
      });
      _startTimer();
    } catch (e) {
      _showError();
    }
  }

  void _shuffleAnswers() {
    if (_questions.isNotEmpty) {
      var currentQuestion = _questions[_currentQuestionIndex];
      _shuffledAnswers = [
        currentQuestion['correct_answer'],
        ...currentQuestion['incorrect_answers']
      ]..shuffle();
    }
  }

  void _showError() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content:
            const Text('Failed to fetch quiz questions. Please try again.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _startTimer() {
    _timeLeft = 15;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _timer?.cancel();
          _handleAnswer(null); // Automatically handle if time runs out
        }
      });
    });
  }

  void _handleAnswer(String? answer) {
    String correctAnswer = _questions[_currentQuestionIndex]['correct_answer'];

    bool isCorrect = answer == correctAnswer;
    if (isCorrect) {
      _score++;
      _feedback = 'Correct!';
    } else {
      _feedback = 'Incorrect! The correct answer was: $correctAnswer';
    }

    // Store the answer result
    _answers.add({
      'question': _questions[_currentQuestionIndex]['question'],
      'user_answer': answer,
      'correct_answer': correctAnswer,
      'is_correct': isCorrect,
    });

    _timer?.cancel();

    // Show feedback immediately
    setState(() {});

    Future.delayed(const Duration(seconds: 2), () {
      if (_currentQuestionIndex < _questions.length - 1) {
        setState(() {
          _currentQuestionIndex++;
          _feedback = null; // Reset feedback for the next question
          _shuffleAnswers(); // Shuffle answers for the next question
        });
        _startTimer();
      } else {
        _endQuiz();
      }
    });
  }

  void _endQuiz() {
    Navigator.pushNamed(context, '/summary', arguments: {
      'score': _score,
      'total': _questions.length,
      'answers': _answers,
      'quizSettings': widget.settings, // Pass the original settings
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    var currentQuestion = _questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Question ${_currentQuestionIndex + 1}/${_questions.length}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Question text
            Text(
              currentQuestion['question'],
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Display current score
            Text(
              'Current Score: $_score',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Display answer buttons
            for (var answer in _shuffledAnswers)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton(
                  onPressed:
                      _feedback == null ? () => _handleAnswer(answer) : null,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.teal,
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: Text(answer),
                ),
              ),

            const Spacer(),

            // Display feedback
            if (_feedback != null)
              Container(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                decoration: BoxDecoration(
                  color: _feedback == 'Correct!' ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _feedback!,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 16),

            // Display countdown timer
            Text(
              'Time Left: $_timeLeft seconds',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
