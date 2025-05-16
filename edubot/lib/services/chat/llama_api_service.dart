import 'dart:convert';
import 'package:edubot/services/authentication/auth_manager.dart';
import 'package:http/http.dart' as http;

/*

Service class to handle Llama API

*/

class LlamaApiService {
  // Flask Url (Android IP: 10.0.2.2 - Web IP: localhost or 127.0.0.0)
  final String uri = 'http://10.0.2.2:5001'; 


  // Send a message and recieve the full JSON response
  Future<String> sendMessageToFlask(
    List<Map<String, String>> context,
    String userMessage,
  ) async {
    final url = Uri.parse(
      '$uri/safe_chat', 
    );

    // Headers
    final headers = {'Content-Type': 'application/json'};

    // JSON Payload
    final body = jsonEncode({"message": userMessage, "context": context});

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

  // Send a message and recieve each chunk displayed as a list
  Stream<String> streamMessageFromFlask(
    List<Map<String, String>> context,
    String message,
  ) async* {
    final AuthManager authManager = AuthManager();
    final url = Uri.parse(
      '$uri/stream_chat',
    ); // Flask Url (Android IP: 10.0.2.2 - Web IP: localhost or 127.0.0.0)
    final body = {
      'context': context,
      'message': message,
      'displayName': authManager.getCurrentUser()?.displayName,
    };

    final request =
        http.Request('POST', url)
          ..headers['Content-Type'] = 'application/json'
          ..body = jsonEncode(body);

    final response = await request.send();
    final stream = response.stream.transform(utf8.decoder);

    String buffer = '';

    await for (var chunk in stream) {
      buffer += chunk;

      // Split on newlines to process full lines
      final lines = buffer.split('\n');

      // Keep the last line in buffer if it may be incomplete
      buffer = lines.removeLast();

      for (final line in lines) {
        final cleaned = line.replaceFirst(RegExp(r'^data:\s*'), '').trim();

        if (cleaned.toLowerCase().contains('[done]') || cleaned.isEmpty) {
          continue;
        }

        try {
          final jsonData = json.decode(cleaned);
          final content = jsonData['message']?['content'];
          if (content is String) yield content;
        } catch (e) {
          // Don't yield anything broken
          print('JSON parse error: $e\nLine: $cleaned');
        }
      }
    }

    // Try to process any leftover line
    if (buffer.isNotEmpty) {
      final cleaned = buffer.replaceFirst(RegExp(r'^data:\s*'), '').trim();
      try {
        final jsonData = json.decode(cleaned);
        final content = jsonData['message']?['content'];
        if (content is String) yield content;
      } catch (e) {
        print('Final JSON parse error: $e\nBuffer: $cleaned');
      }
    }
  }

  // Send a message and recieve a concise summary of the conversation
  Future<String> generateTitleFromFlask(List<Map<String, String>> context) async {
    final url = Uri.parse(
      '$uri/make_title', // Flask Url (Android IP: 10.0.2.2 - Web IP: localhost or 127.0.0.0)
    );

    // Headers
    final headers = {'Content-Type': 'application/json'};

    // JSON Payload
    final body = jsonEncode({"context": context});

    // Try send post request to Flask server
    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['title'];
      } else {
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (e) {
      // Handle errors
      throw Exception("Request failed: $e");
    }
  }
}
