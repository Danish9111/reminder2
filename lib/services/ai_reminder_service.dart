import 'dart:convert';
import 'package:http/http.dart' as http;

class AIReminderService {
  // ⚠️ SECURITY WARNING: Never hardcode API keys in production apps.
  // Use --dart-define or a .env file.
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';
  static const String _apiKey = 'AIzaSyAqRFLf4_myFL5frPfzdCYb3a3QtvDRvLQ';

  Future<AIParseResult?> parseReminder(String userMessage) async {
    try {
      final now = DateTime.now().toIso8601String();

      final prompt =
          '''
      You are a strict JSON parser. 
      Current time context: $now
      
      Extract the following fields from the user message:
      - assignee (string, or null if not found)
      - time (string in ISO 8601 format, or null if not found)
      - title (string, summary of the task)

      Return ONLY raw JSON. No markdown, no code blocks.
      
      User message: $userMessage
      ''';

      final requestBody = {
        'contents': [
          {
            'parts': [
              {'text': prompt},
            ],
          },
        ],
        'generationConfig': {
          'temperature': 0.0,
          'responseMimeType': 'application/json',
        },
      };

      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final parsedText =
            responseData['candidates'][0]['content']['parts'][0]['text'];

        print('✅ Raw AI Response: $parsedText');

        return _parseJson(parsedText);
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception occurred: $e');
      return null;
    }
  }

  AIParseResult? _parseJson(String jsonString) {
    try {
      final Map<String, dynamic> data = jsonDecode(jsonString);

      return AIParseResult(
        assignee: data['assignee'],
        time: data['time'] != null ? DateTime.tryParse(data['time']) : null,
        title: data['title'] ?? '',
      );
    } catch (e) {
      print('Error parsing JSON: $e');
      return null;
    }
  }
}

class AIParseResult {
  final String? assignee;
  final DateTime? time;
  final String title;

  AIParseResult({this.assignee, this.time, required this.title});

  @override
  String toString() => 'Title: $title, Time: $time, Assignee: $assignee';
}
