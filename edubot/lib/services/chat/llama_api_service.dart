import 'dart:convert';
import 'package:http/http.dart' as http;

/*

Service class to handle Llama API

*/

class LlamaApiService {
  // Get the previous user and assistant responses
  late List<String> previousUserMessages = [];
  late List<String> previousAssistantMessages = [];
  
  Future<String> sendMessageToFlask(String context) async {

    final url = Uri.parse(
      'http://10.0.2.2:5000/safe_chat' // Flask Url (Android IP: 10.0.2.2 - Web IP: localhost or 127.0.0.0)
    );

    // Headers
    final headers = {'Content-Type': 'application/json'};

    // JSON Payload
    final body = jsonEncode({
      "message": context,
      "context": [
        {"role": "user", "content": context},
        {"role": "assistant", "content": context},
        {"role": "system", "content": "You are a helpful assistant."},
      ],
    });

    // Try send post request to Flask server
    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'];
      } else {
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (e) {
      // Handle errors
      throw Exception("Request failed: $e");
    }
  }
}