import 'package:flutter/material.dart';
import 'package:quizapp/utils/string_extensions.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SetupScreen extends StatefulWidget {
  const SetupScreen({Key? key}) : super(key: key);

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final List<Map<String, dynamic>> _categories = [];
  final TextEditingController _numberController = TextEditingController();
  String? _selectedCategory;
  String _selectedDifficulty = 'easy';
  String _selectedType = 'multiple';
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _numberController.text;
  }

  Future<void> _fetchCategories() async {
    const String categoryUrl = 'https://opentdb.com/api_category.php';

    try {
      final response = await http.get(Uri.parse(categoryUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data.containsKey('trivia_categories')) {
          setState(() {
            _categories.addAll(
                List<Map<String, dynamic>>.from(data['trivia_categories']));
            _isLoadingCategories = false;
          });
        }
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      setState(() {
        _isLoadingCategories = false;
      });
      _showErrorDialog(
          'Error', 'Failed to fetch categories. Please try again.');
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _startQuiz() {
    final int numberOfQuestions = int.tryParse(_numberController.text) ?? 0;

    if (numberOfQuestions < 1 || numberOfQuestions > 50) {
      _showErrorDialog(
        'Invalid Number',
        'Please enter a number between 1 and 50.',
      );
      return;
    }

    Navigator.pushNamed(
      context,
      '/quiz',
      arguments: {
        'numberOfQuestions': numberOfQuestions,
        'category': _selectedCategory,
        'difficulty': _selectedDifficulty,
        'type': _selectedType,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Setup')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Number of Questions:'),
            TextField(
              controller: _numberController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Please enter a number between 1 and 50',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Category:'),
            _isLoadingCategories
                ? const Center(child: CircularProgressIndicator())
                : DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedCategory,
                    hint: const Text('Select the category'), // Placeholder
                    items: _categories.map((cat) {
                      return DropdownMenuItem(
                        value: cat['id'].toString(),
                        child: Text(cat['name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                  ),
            const SizedBox(height: 16),
            const Text('Difficulty:'),
            DropdownButton<String>(
              isExpanded: true,
              value: _selectedDifficulty,
              hint: const Text('Select the difficulty'), // Placeholder
              items: ['easy', 'medium', 'hard'].map((difficulty) {
                return DropdownMenuItem(
                  value: difficulty,
                  child: Text(difficulty.capitalize()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDifficulty = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text('Type:'),
            DropdownButton<String>(
              isExpanded: true,
              value: _selectedType,
              hint: const Text('Select the level'), // Placeholder
              items: ['multiple', 'boolean'].map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(
                      type == 'multiple' ? 'Multiple Choice' : 'True/False'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: _categories.isNotEmpty ? _startQuiz : null,
                child: const Text('Start Quiz'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }
}
