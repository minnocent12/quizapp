import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<List> fetchQuestions(Map<String, dynamic> settings) async {
    const String baseUrl = 'https://opentdb.com/api.php';

    // Construct the query parameters
    final Map<String, String> queryParams = {
      'amount': settings['numberOfQuestions'].toString(),
      if (settings['category'] != null)
        'category': settings['category'].toString(),
      if (settings['difficulty'] != null) 'difficulty': settings['difficulty'],
      if (settings['type'] != null) 'type': settings['type'],
    };

    final Uri uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data['response_code'] == 0) {
          return data['results'];
        } else {
          throw Exception('No questions available for the selected options.');
        }
      } else {
        throw Exception('Failed to fetch questions from the API.');
      }
    } catch (e) {
      throw Exception('Error fetching questions: $e');
    }
  }
}
