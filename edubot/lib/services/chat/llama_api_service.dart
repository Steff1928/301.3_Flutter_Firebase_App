import 'dart:convert';
import 'package:http/http.dart' as http;

/*

Service class to handle Llama API

*/

class LlamaApiService {
  Future<String> sendMessageToFlask(String content) async {
    final url = Uri.parse(
      'http://10.0.2.2:5000/safe_chat' // Flask Url (Android IP: 10.0.2.2 - Web IP: localhost or 127.0.0.0)
    );

    // Headers
    final headers = {'Content-Type': 'application/json'};

    // JSON Payload
    final body = jsonEncode({
      "message": content,
      "context": [
        {"role": "user", "content": "Hi"},
        {"role": "system", "content": "You are extremely helpful and descriptive"},
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
      throw Exception("Request failed: $e");
    }

  }
}