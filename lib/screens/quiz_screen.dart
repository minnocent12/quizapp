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
      });
      _startTimer();
    } catch (e) {
      _showError();
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
          _handleAnswer(null);
        }
      });
    });
  }

  void _handleAnswer(String? answer) {
    String correctAnswer = _questions[_currentQuestionIndex]['correct_answer'];

    if (answer == correctAnswer) {
      _score++;
      _feedback = 'Correct!';
    } else {
      _feedback = 'Incorrect! The correct answer was: $correctAnswer';
    }

    _timer?.cancel();

    Future.delayed(const Duration(seconds: 2), () {
      if (_currentQuestionIndex < _questions.length - 1) {
        setState(() {
          _currentQuestionIndex++;
          _feedback = null;
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
    var allAnswers = [
      currentQuestion['correct_answer'],
      ...currentQuestion['incorrect_answers']
    ]..shuffle();

    return Scaffold(
      appBar: AppBar(
        title:
            Text('Question ${_currentQuestionIndex + 1}/${_questions.length}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              currentQuestion['question'],
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            for (var answer in allAnswers)
              ElevatedButton(
                onPressed:
                    _feedback == null ? () => _handleAnswer(answer) : null,
                child: Text(answer),
              ),
            const Spacer(),
            if (_feedback != null)
              Text(
                _feedback!,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 16),
            Text(
              'Time Left: $_timeLeft seconds',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
