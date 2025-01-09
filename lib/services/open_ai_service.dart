import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class OpenAIService {
  final String apiUrl = 'https://api.openai.com/v1/chat/completions';

  // Fetch the API key from Firestore
  Future<String> _fetchApiKey() async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('api')
          .doc('apikeyai')
          .get();

      if (docSnapshot.exists) {
        return docSnapshot.data()?['apikey'] ?? '';
      } else {
        throw Exception('API key document does not exist in Firestore.');
      }
    } catch (e) {
      throw Exception('Error fetching API key: $e');
    }
  }

  // Get AI response using the OpenAI API
  Future<String> getResponse(String prompt) async {
    final apiKey = await _fetchApiKey(); // Fetch the API key dynamically

    if (apiKey.isEmpty) {
      throw Exception('API key is missing.');
    }

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-4', // Replace with the model you're using
        'messages': [
          {'role': 'system', 'content': 'You are a helpful assistant.'},
          {'role': 'user', 'content': prompt},
        ],
      }),
    );

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes); // Decode properly
      final data = jsonDecode(decodedBody);
      return data['choices'][0]['message']['content'];
    } else {
      throw Exception('Failed to fetch AI response: ${response.statusCode}');
    }
  }
}
