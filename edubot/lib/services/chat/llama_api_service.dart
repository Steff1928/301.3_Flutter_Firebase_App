import 'dart:convert';
import 'package:http/http.dart' as http;

/*

Service class to handle Llama API

*/

class LlamaApiService {
  // Get the previous user and assistant responses
  late List<String> previousUserMessages = [];
  late List<String> previousAssistantMessages = [];

  Future<String> sendMessageToFlask(
    List<Map<String, String>> context,
    String userMessage,
  ) async {
    final url = Uri.parse(
      'http://10.0.2.2:5001/safe_chat', // Flask Url (Android IP: 10.0.2.2 - Web IP: localhost or 127.0.0.0)
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

  Stream<String> streamMessageFromFlask(
    List<Map<String, String>> context,
    String message,
  ) async* {
    final url = Uri.parse('http://10.0.2.2:5001/stream_chat');
    final body = {'context': context, 'message': message};

    final request =
        http.Request('POST', url)
          ..headers['Content-Type'] = 'application/json'
          ..body = jsonEncode(body);

    final response = await request.send();
    final stream = response.stream.transform(utf8.decoder);

    await for (var chunk in stream) {
      print('Raw chunk: $chunk');

      // Remove "data: " prefix if present
      final cleaned = chunk.replaceFirst(RegExp(r'^data:\s*'), '').trim();

      if (cleaned.toLowerCase().contains('[done]')) continue;

      // Skip empty chunks
      if (cleaned.isEmpty) continue;

      try {
        // Check if it starts with { and ends with } (likely JSON)
        if (cleaned.startsWith('{') && cleaned.endsWith('}')) {
          final jsonData = json.decode(cleaned);
          final content = jsonData['message']?['content'];
          if (content != null && content is String) {
            yield content;
          }
        } else {
          // Not JSON — maybe plain text, still yield it if needed
          yield cleaned;
        }
      } catch (e) {
        print('JSON parse error: $e\nChunk: $cleaned');
        // Optionally, yield raw cleaned text to avoid missing output
        // yield cleaned;
      }
    }
  }
}
