import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quizapp/utils/string_extensions.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({Key? key}) : super(key: key);

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final List<Map<String, dynamic>> _categories = [];
  final TextEditingController _numberController = TextEditingController();
  String? _selectedCategory;
  String? _selectedDifficulty;
  String? _selectedType;
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _numberController.text = '10';
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
        'Error',
        'Failed to fetch categories. Please try again.',
      );
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

    if (_selectedCategory == null ||
        _selectedDifficulty == null ||
        _selectedType == null) {
      _showErrorDialog(
        'Missing Selections',
        'Please select a category, difficulty, and question type.',
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
      appBar: AppBar(
        title: const Text('Quiz Setup'),
        backgroundColor: Colors.deepPurpleAccent,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.deepPurpleAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Setup Your Quiz',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildCard(
                      title: 'Number of Questions',
                      child: TextField(
                        controller: _numberController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'Enter a number (1-50)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildCard(
                      title: 'Category',
                      child: _isLoadingCategories
                          ? const Center(child: CircularProgressIndicator())
                          : DropdownButtonFormField<String>(
                              isExpanded: true,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Select category',
                              ),
                              value: _selectedCategory,
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
                    ),
                    const SizedBox(height: 16),
                    _buildCard(
                      title: 'Difficulty',
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Select difficulty',
                        ),
                        value: _selectedDifficulty,
                        items: ['easy', 'medium', 'hard'].map((difficulty) {
                          return DropdownMenuItem(
                            value: difficulty,
                            child: Text(difficulty.capitalize()),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedDifficulty = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildCard(
                      title: 'Question Type',
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Select question type',
                        ),
                        value: _selectedType,
                        items: [
                          {'value': 'multiple', 'label': 'Multiple Choice'},
                          {'value': 'boolean', 'label': 'True/False'}
                        ].map((type) {
                          return DropdownMenuItem(
                            value: type['value'],
                            child: Text(type['label']!),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedType = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _categories.isNotEmpty ? _startQuiz : null,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Start Quiz'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 28,
                          ),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white.withOpacity(0.9),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 8),
            child,
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
